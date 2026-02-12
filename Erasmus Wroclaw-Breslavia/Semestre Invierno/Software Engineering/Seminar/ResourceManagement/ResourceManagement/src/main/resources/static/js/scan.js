/* =========================
   Live camera QR scanning
   Improved version with better mobile support
   Requires: <script src="https://unpkg.com/@zxing/browser@latest"></script>
   ========================= */
(() => {
	'use strict';

	const video = document.getElementById('qr-video');
	const startBtn = document.getElementById('start-scan');
	const stopBtn = document.getElementById('stop-scan');
	const statusMsg = document.getElementById('scan-status');

	if (!startBtn || !video) return;

	let codeReader = null;
	let activeControls = null;
	let isScanning = false;

	/* =========================
	   Camera OFF overlay text
	   ========================= */
	const overlay = document.createElement('div');
	overlay.className = 'camera-off-text';
	overlay.textContent = 'Camera is off';
	overlay.style.cssText = `
        position:absolute;
        inset:0;
        display:flex;
        align-items:center;
        justify-content:center;
        font-weight:700;
        color:rgba(255,255,255,0.85);
        background:rgba(0,0,0,0.35);
        pointer-events:none;
        border-radius:8px;
    `;

	const parent = video.parentElement;
	if (parent && getComputedStyle(parent).position === 'static') {
		parent.style.position = 'relative';
	}
	parent.appendChild(overlay);

	function showOverlay(show) {
		overlay.style.display = show ? 'flex' : 'none';
	}

	// initial state
	showOverlay(true);

	function showStatus(msg, isError = false) {
		if (statusMsg) {
			statusMsg.textContent = msg;
			statusMsg.hidden = !msg;
			statusMsg.className = isError ? 'scan-status error' : 'scan-status success';
		} else if (msg) {
			console.log(msg);
		}
	}

	function detectReaderClass() {
		return window.ZXing?.BrowserQRCodeReader
			|| window.BrowserQRCodeReader
			|| window.ZXingBrowser?.BrowserQRCodeReader
			|| window.BrowserBarcodeReader
			|| null;
	}

	/**
	 * Extract resource ID from QR code content
	 * Expected format: "http(s)://xxxx/resources/X" where X is a NUMERIC resource ID
	 */
	function extractResourceId(qrText) {
		if (!qrText) { return null; }

		try {
			// Try to match the pattern: /resources/X
			const match = qrText.match(/\/resources\/([^\/\?#\s]+)/i);
			if (match && match[1]) {
				const id = match[1].trim();

				// Validate that the ID is numeric
				if (!/^\d+$/.test(id)) {
					console.error('Resource ID must be numeric, got:', id);
					return null;
				}

				return id;
			}

			// If it's already just an ID (no slashes), check if it's numeric
			if (!qrText.includes('/') && !qrText.includes(':')) {
				const id = qrText.trim();

				// Validate that the ID is numeric
				if (!/^\d+$/.test(id)) {
					console.error('Resource ID must be numeric, got:', id);
					return null;
				}

				return id;
			}

			// Otherwise return null - invalid format
			return null;
		} catch (e) {
			console.error('Error extracting resource ID:', e);
			return null;
		}
	}

	async function startScan() {
		if (isScanning) {
			console.log('Already scanning, ignoring duplicate request');
			return;
		}

		// Check for camera support with detailed detection
		if (!navigator.mediaDevices) {
			showStatus('Camera API not supported. Please use file upload instead.', true);
			return;
		}

		if (!navigator.mediaDevices.getUserMedia) {
			showStatus('Camera access not available. Please use file upload instead.', true);
			return;
		}

		// Check if running in insecure context (camera requires HTTPS)
		if (location.protocol !== 'https:' && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
			showStatus('Camera requires secure connection (HTTPS). Please use file upload instead.', true);
			return;
		}

		// Wait for ZXing library to load
		let attempts = 0;
		while (!detectReaderClass() && attempts < 20) {
			await new Promise(resolve => setTimeout(resolve, 100));
			attempts++;
		}

		const ReaderClass = detectReaderClass();
		if (!ReaderClass) {
			showStatus('QR scanning library not loaded. Please refresh the page.', true);
			return;
		}

		if (!codeReader) {
			try {
				codeReader = new ReaderClass();
			} catch (e) {
				console.error('Failed to initialize QR reader:', e);
				showStatus('Failed to initialize QR reader.', true);
				return;
			}
		}

		isScanning = true;
		startBtn.disabled = true;
		if (stopBtn) stopBtn.hidden = false;
		showOverlay(false);
		showStatus('Camera active. Point at a QR code...');

		try {
			// Request camera with specific constraints for better mobile support
			const constraints = {
				video: {
					facingMode: { ideal: 'environment' }, // Prefer back camera on mobile
					width: { ideal: 1280 },
					height: { ideal: 720 }
				}
			};

			// Use decodeFromConstraints for better control
			activeControls = await codeReader.decodeFromConstraints(
				constraints,
				video,
				(result, error) => {
					if (result && !error) {
						// Stop scanning immediately
						stopScan();

						// Extract the result text
						const qrText = typeof result.getText === 'function'
							? result.getText()
							: result.text || String(result);

						console.log('QR code scanned:', qrText);

						// Extract resource ID from the QR text
						const resourceId = extractResourceId(qrText);

						// Validate the resource ID
						if (!resourceId) {
							showStatus('Invalid QR code (' + qrText + '). Expected numeric resource ID (e.g., /resources/123)', true);
							startBtn.disabled = false;
							isScanning = false;
							return;
						}

						showStatus('QR code detected! Redirecting...', false);

						// Redirect directly to the resource page
						window.location.href = '/resources/' + resourceId;
					}

					// Log errors for debugging but don't show to user (they're usually just "not found" errors)
					if (error && error.name !== 'NotFoundException') {
						console.warn('Decode error:', error);
					}
				}
			);
		} catch (e) {
			console.error('Camera error:', e);
			startBtn.disabled = false;
			isScanning = false;
			if (stopBtn) stopBtn.hidden = true;
			showOverlay(true);

			// More helpful error messages based on the error type
			if (e.name === 'NotAllowedError' || e.name === 'PermissionDeniedError') {
				showStatus('Camera permission denied. Please allow camera access in your browser settings.', true);
			} else if (e.name === 'NotFoundError' || e.name === 'DevicesNotFoundError') {
				showStatus('No camera found on this device.', true);
			} else if (e.name === 'NotReadableError' || e.name === 'TrackStartError') {
				showStatus('Camera is already in use by another application.', true);
			} else {
				showStatus('Could not start camera. Please check permissions and try again.', true);
			}
		}
	}

	function stopScan() {
		isScanning = false;

		// Stop the active controls first
		try {
			if (activeControls?.stop) {
				activeControls.stop();
			}
		} catch (e) {
			console.warn('Error stopping controls:', e);
		}

		// Stop all video tracks thoroughly
		try {
			if (video.srcObject) {
				const stream = video.srcObject;

				// Get all tracks from the stream
				if (stream.getTracks) {
					const tracks = stream.getTracks();
					tracks.forEach(track => {
						try {
							track.stop();
							console.log('Stopped track:', track.kind);
						} catch (e) {
							console.warn('Error stopping track:', e);
						}
					});
				}

				// Also try getVideoTracks specifically
				if (stream.getVideoTracks) {
					const videoTracks = stream.getVideoTracks();
					videoTracks.forEach(track => {
						try {
							track.stop();
							console.log('Stopped video track:', track.label);
						} catch (e) {
							console.warn('Error stopping video track:', e);
						}
					});
				}

				// Clear the srcObject
				video.srcObject = null;
			}
		} catch (e) {
			console.warn('Error stopping video:', e);
		}

		// Pause the video element
		try {
			video.pause();
			video.src = '';
			video.load();
		} catch (e) {
			console.warn('Error pausing video:', e);
		}

		// Reset the code reader
		try {
			if (codeReader?.reset) {
				codeReader.reset();
			}
		} catch (e) {
			console.warn('Error resetting reader:', e);
		}

		// Clear the active controls reference
		activeControls = null;

		// Update UI
		startBtn.disabled = false;
		if (stopBtn) stopBtn.hidden = true;
		showOverlay(true);
		showStatus('');
	}

	startBtn.addEventListener('click', (e) => {
		e.preventDefault();
		showStatus('');
		startScan();
	});

	stopBtn?.addEventListener('click', (e) => {
		e.preventDefault();
		stopScan();
	});

	window.addEventListener('pagehide', stopScan);
	window.addEventListener('beforeunload', stopScan);

	// Cleanup on visibility change (mobile optimization)
	document.addEventListener('visibilitychange', () => {
		if (document.hidden && isScanning) {
			stopScan();
		}
	});
})();

/* =========================
   File upload QR scanning
   ========================= */
(() => {
	'use strict';

	const form = document.getElementById('upload-form');
	const fileInput = document.getElementById('file-input');
	const dropzone = document.getElementById('dropzone');
	const selectBtn = document.getElementById('select-btn');
	const clearBtn = document.getElementById('clear-btn');
	const submitBtn = document.getElementById('submit-btn');
	const previewArea = document.getElementById('preview-area');
	const previewImage = document.getElementById('preview-image');
	const errorDiv = document.getElementById('error');

	if (!form || !fileInput || !dropzone) return;

	let selectedFile = null;

	function showError(msg) {
		if (errorDiv) {
			errorDiv.textContent = msg;
			errorDiv.hidden = false;
		} else {
			alert(msg);
		}
	}

	function clearError() {
		if (errorDiv) {
			errorDiv.hidden = true;
			errorDiv.textContent = '';
		}
	}

	function validateFile(file) {
		const maxSize = 5 * 1024 * 1024; // 5MB
		const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];

		if (!file) {
			return 'Please select a file';
		}

		if (!validTypes.includes(file.type.toLowerCase())) {
			return 'Invalid file type. Please upload PNG, JPG, GIF, or WEBP.';
		}

		if (file.size > maxSize) {
			return 'File too large. Maximum size is 5MB.';
		}

		return null;
	}

	function handleFile(file) {
		clearError();

		const error = validateFile(file);
		if (error) {
			showError(error);
			return;
		}

		selectedFile = file;

		// Show preview
		const reader = new FileReader();
		reader.onload = (e) => {
			if (previewImage) {
				previewImage.src = e.target.result;
			}
			if (previewArea) {
				previewArea.hidden = false;
			}
			if (submitBtn) {
				submitBtn.disabled = false;
			}
		};
		reader.onerror = () => {
			showError('Failed to read file. Please try again.');
		};
		reader.readAsDataURL(file);
	}

	function clearFile() {
		selectedFile = null;
		if (fileInput) fileInput.value = '';
		if (previewArea) previewArea.hidden = true;
		if (previewImage) previewImage.src = '';
		if (submitBtn) submitBtn.disabled = true;
		clearError();
	}

	// File input change
	if (fileInput) {
		fileInput.addEventListener('change', (e) => {
			const file = e.target.files[0];
			if (file) {
				handleFile(file);
			}
		});
	}

	// Select button click
	if (selectBtn) {
		selectBtn.addEventListener('click', (e) => {
			e.preventDefault();
			e.stopPropagation(); // Prevent event bubbling to dropzone
			if (fileInput) fileInput.click();
		});
	}

	// Dropzone click - only trigger if NOT clicking on interactive elements
	if (dropzone) {
		dropzone.addEventListener('click', (e) => {
			// Don't trigger if clicking the select button or file input
			if (e.target === selectBtn || selectBtn?.contains(e.target) || e.target === fileInput) {
				return;
			}
			// Don't trigger if clicking on the preview area or clear button
			if (previewArea?.contains(e.target) || e.target === clearBtn || clearBtn?.contains(e.target)) {
				return;
			}
			if (fileInput) fileInput.click();
		});

		// Drag and drop
		dropzone.addEventListener('dragover', (e) => {
			e.preventDefault();
			dropzone.classList.add('is-dragover');
		});

		dropzone.addEventListener('dragleave', () => {
			dropzone.classList.remove('is-dragover');
		});

		dropzone.addEventListener('drop', (e) => {
			e.preventDefault();
			dropzone.classList.remove('is-dragover');

			const file = e.dataTransfer?.files[0];
			if (file) {
				// Set the file to the input
				const dataTransfer = new DataTransfer();
				dataTransfer.items.add(file);
				fileInput.files = dataTransfer.files;

				handleFile(file);
			}
		});
	}

	// Clear button
	if (clearBtn) {
		clearBtn.addEventListener('click', (e) => {
			e.preventDefault();
			clearFile();
		});
	}

	// Form submit
	if (form) {
		form.addEventListener('submit', (e) => {
			if (!selectedFile) {
				e.preventDefault();
				showError('Please select a file to upload.');
				return;
			}

			const error = validateFile(selectedFile);
			if (error) {
				e.preventDefault();
				showError(error);
				return;
			}

			// Disable submit button to prevent double submission
			if (submitBtn) {
				submitBtn.disabled = true;
				submitBtn.textContent = 'Processing...';
			}
		});
	}
})();