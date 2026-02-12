// src/main/resources/static/js/index.js

(function () {
	'use strict';

	function onReady(fn) {
		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', fn);
		} else {
			setTimeout(fn, 0);
		}
	}

	onReady(function () {
		// Grab elements defensively so the script still runs even if some nodes are missing
		const root = document.getElementById('resources-root');
		const sectionsContainer = document.getElementById('sections-container');
		const typeBar = document.getElementById('type-bar');
		const filterText = document.getElementById('filter-text');
		const filterIsbn = document.getElementById('filter-isbn');
		const filterCapacity = document.getElementById('filter-capacity');
		const filterCapacityCustom = document.getElementById('filter-capacity-custom');
		const filterAvailable = document.getElementById('filter-available');
		const clearBtn = document.getElementById('filter-clear');

		// Form starting + ending date auto send:
		const startInput = document.getElementById('filter-start');
		const endInput = document.getElementById('filter-end');
		const filtersForm = document.getElementById('filters-form');

		function nowLocalISO() {
			const d = new Date();
			d.setSeconds(0, 0);
			return d.toISOString().slice(0, 16);
		}

		let submitTimer = null;
		const DEBOUNCE_MS = 600;
		let validationErrorShown = false;

		function showValidationError(message) {
			// Remove any existing error
			const existingError = document.getElementById('time-validation-error');
			if (existingError) existingError.remove();

			// Create error message
			const errorDiv = document.createElement('div');
			errorDiv.id = 'time-validation-error';
			errorDiv.className = 'alert alert-error';
			errorDiv.setAttribute('role', 'alert');
			errorDiv.style.marginBottom = '1.5rem';
			errorDiv.innerHTML = `<strong>Invalid Time Range!</strong><p style="margin: 0.5rem 0 0 0;">${message}</p>`;

			// Insert after filters
			const filtersDiv = document.querySelector('.filters');
			if (filtersDiv && filtersDiv.parentNode) {
				filtersDiv.parentNode.insertBefore(errorDiv, filtersDiv.nextSibling);
			}

			validationErrorShown = true;
		}

		function clearValidationError() {
			const existingError = document.getElementById('time-validation-error');
			if (existingError) existingError.remove();
			validationErrorShown = false;
		}

		function validateTimeRange() {
			if (!startInput || !endInput) return true;

			const startVal = startInput.value;
			const endVal = endInput.value;

			// If either is empty, clear error and allow (server will handle)
			if (!startVal || !endVal) {
				clearValidationError();
				return true;
			}

			const startDate = new Date(startVal);
			const endDate = new Date(endVal);

			// Check if end is before or equal to start
			if (endDate <= startDate) {
				showValidationError('End time must be after start time. Please select a valid time range.');
				return false;
			}

			clearValidationError();
			return true;
		}

		function submitFilters() {
			// Validate before submitting
			if (!validateTimeRange()) {
				return; // Don't submit if validation fails
			}

			if (filtersForm) {
				filtersForm.submit();
			} else {
				const params = new URLSearchParams(window.location.search);
				if (startInput?.value) params.set('startTime', startInput.value);
				else params.delete('startTime');

				if (endInput?.value) params.set('endTime', endInput.value);
				else params.delete('endTime');

				window.location.search = params.toString();
			}
		}

		function debounceSubmit() {
			clearTimeout(submitTimer);
			submitTimer = setTimeout(() => {
				if (validateTimeRange()) {
					submitFilters();
				}
			}, DEBOUNCE_MS);
		}

		const now = nowLocalISO();

		// Track previous values to detect real changes (iOS Safari fix)
		let prevStartValue = startInput ? startInput.value : '';
		let prevEndValue = endInput ? endInput.value : '';

		if (startInput) {
			startInput.min = now;

			startInput.addEventListener('change', () => {
				// iOS Safari fix: only submit if value actually changed
				if (startInput.value === prevStartValue) {
					return;
				}
				prevStartValue = startInput.value;

				// Don't submit if value is empty (user cancelled the picker)
				if (!startInput.value) {
					return;
				}

				if (startInput.value < now) {
					startInput.value = now;
					prevStartValue = now;
					alert('You can only select present or future times.');
				}

				if (endInput && endInput.value && endInput.value < startInput.value) {
					endInput.value = startInput.value;
					prevEndValue = startInput.value;
				}

				if (endInput) endInput.min = startInput.value;

				// Validate before submitting
				if (validateTimeRange()) {
					submitFilters();
				}
			});

			startInput.addEventListener('input', () => {
				validateTimeRange(); // Show error immediately on input
				debounceSubmit();
			});
		}

		if (endInput) {
			endInput.min = now;

			endInput.addEventListener('change', () => {
				// iOS Safari fix: only submit if value actually changed
				if (endInput.value === prevEndValue) {
					return;
				}
				prevEndValue = endInput.value;

				// Don't submit if value is empty (user cancelled the picker)
				if (!endInput.value) {
					return;
				}

				if (endInput.value < now) {
					endInput.value = now;
					prevEndValue = now;
					alert('You can only select present or future times.');
				}

				if (startInput && startInput.value && endInput.value < startInput.value) {
					endInput.value = startInput.value;
					prevEndValue = startInput.value;
				}

				// Validate before submitting
				if (validateTimeRange()) {
					submitFilters();
				}
			});

			endInput.addEventListener('input', () => {
				validateTimeRange(); // Show error immediately on input
				debounceSubmit();
			});
		}


		const filterToggle = document.getElementById('filter-toggle');
		const filterPanel = document.getElementById('filter-panel');

		const capacityWrapper = document.getElementById('filter-row-3');
		const isbnRow = document.getElementById('filter-row-2');

		// If root is removed or not present, still try to find items globally so the page works
		const items = root
			? Array.from(root.querySelectorAll('.resource-item'))
			: Array.from(document.querySelectorAll('.resource-item'));

		const types = Array.from(new Set(items.map(i => i.dataset.type || 'Unknown'))).sort();

		let allBtn = null;

		function populateTypes() {
			if (!typeBar) return;
			typeBar.innerHTML = '';

			allBtn = document.createElement('button');
			allBtn.type = 'button';
			allBtn.className = 'type-btn all-types active';
			allBtn.dataset.type = 'ALL';
			allBtn.textContent = 'All types';
			allBtn.setAttribute('aria-pressed', 'true');
			typeBar.appendChild(allBtn);

			types.forEach(type => {
				const btn = document.createElement('button');
				btn.type = 'button';
				btn.className = 'type-btn';
				btn.dataset.type = type;
				btn.textContent = type;
				btn.setAttribute('aria-pressed', 'false');
				typeBar.appendChild(btn);
			});
		}

		populateTypes();

		if (sectionsContainer) {
			types.forEach(type => {
				const section = document.createElement('section');
				section.className = 'type-section';
				section.dataset.type = type;

				const heading = document.createElement('h3');
				heading.className = 'type-heading';
				heading.innerHTML = `<span class="type-name">${type}</span><span class="count"></span>`;
				section.appendChild(heading);

				const grid = document.createElement('div');
				grid.className = 'grid';
				section.appendChild(grid);

				const empty = document.createElement('div');
				empty.className = 'empty-placeholder';
				empty.textContent = 'No resources available';
				empty.style.display = 'none';
				section.appendChild(empty);

				sectionsContainer.appendChild(section);
			});
		}

		// Move items into their sections (if sections exist), otherwise leave them in place
		items.forEach(item => {
			const type = item.dataset.type || 'Unknown';
			const section = sectionsContainer ? sectionsContainer.querySelector(`.type-section[data-type="${CSS.escape(type)}"]`) : null;
			if (section) {
				const grid = section.querySelector('.grid');
				if (grid) grid.appendChild(item);
				else sectionsContainer.appendChild(item);
			} else {
				if (sectionsContainer) sectionsContainer.appendChild(item);
			}

			const available = String(item.dataset.available).toLowerCase() === 'true' || item.dataset.available === '1';
			const link = item.querySelector('.view-btn');
			if (!available && link) {
				link.addEventListener('click', function (e) {
					e.preventDefault();
				});
				link.classList.add('disabled');
				link.setAttribute('aria-disabled', 'true');
				link.tabIndex = -1;
			}

			item.classList.add('card--interactive');
		});

		// Helper: selected types
		function getSelectedType() {
			if (!typeBar) return ['ALL'];
			const activeBtns = Array.from(typeBar.querySelectorAll('.type-btn.active:not(.all-types)'));
			if (activeBtns.length === 0) return ['ALL'];
			return activeBtns.map(b => b.dataset.type);
		}

		// Show/hide filters depending on selected type
		function renderTypeSpecificFilters() {
			const selected = getSelectedType();

			if (isbnRow) isbnRow.style.display = 'none';
			if (capacityWrapper) capacityWrapper.style.display = 'none';
			if (filterCapacityCustom) filterCapacityCustom.style.display = 'none';

			if (selected.includes('ALL') || selected.length !== 1) {
				if (filterIsbn) filterIsbn.value = '';
				if (filterCapacityCustom) filterCapacityCustom.value = '';
				// If capacity control is hidden, ensure its selected value is cleared
				if (filterCapacity && capacityWrapper && capacityWrapper.style.display === 'none') {
					filterCapacity.value = '';
				}
				applyFilters();
				return;
			}

			const only = selected[0];
			if (only === 'Book') {
				if (isbnRow) isbnRow.style.display = '';
				if (capacityWrapper) {
					// hide capacity and clear its values because it's not relevant for books
					capacityWrapper.style.display = 'none';
					if (filterCapacity) filterCapacity.value = '';
					if (filterCapacityCustom) filterCapacityCustom.value = '';
					if (filterCapacityCustom) filterCapacityCustom.style.display = 'none';
				}
			} else if (only === 'Room') {
				if (capacityWrapper) capacityWrapper.style.display = '';
				if (isbnRow) {
					isbnRow.style.display = 'none';
					if (filterIsbn) filterIsbn.value = '';
				}
				// If the capacity select was previously "custom", make sure the custom input visibility matches its value
				if (filterCapacity && filterCapacity.value === 'custom' && filterCapacityCustom) {
					filterCapacityCustom.style.display = '';
				} else if (filterCapacityCustom) {
					filterCapacityCustom.style.display = 'none';
				}
			} else {
				if (isbnRow) isbnRow.style.display = 'none';
				if (capacityWrapper) {
					capacityWrapper.style.display = 'none';
					if (filterCapacity) filterCapacity.value = '';
					if (filterCapacityCustom) {
						filterCapacityCustom.value = '';
						filterCapacityCustom.style.display = 'none';
					}
				}
			}

			applyFilters();
		}


		// Apply filters to cards
		function applyFilters() {
			const typeVal = getSelectedType();
			const textVal = filterText && filterText.value ? filterText.value.trim().toLowerCase() : '';
			const isbnVal = filterIsbn && filterIsbn.style.display !== 'none' ? filterIsbn.value.trim().toLowerCase() : '';
			const capacityValRaw = (filterCapacity && filterCapacity.style.display !== 'none' && filterCapacity.value === 'custom') ? (filterCapacityCustom ? filterCapacityCustom.value : '') : (filterCapacity ? filterCapacity.value : '');
			const capacityVal = (capacityValRaw !== '' && capacityValRaw !== null) ? Number(capacityValRaw) : null;
			const onlyAvailable = filterAvailable ? filterAvailable.checked : false;

			const sections = sectionsContainer ? Array.from(sectionsContainer.querySelectorAll('.type-section')) : [];
			sections.forEach(section => {
				let anyVisibleInSection = false;
				const cards = Array.from(section.querySelectorAll('.resource-item'));
				cards.forEach(card => {
					const cardId = String(card.dataset.id || '');
					const cardType = card.dataset.type || '';
					const cardAvailable = String(card.dataset.available).toLowerCase() === 'true' || card.dataset.available === '1';

					const cardTitle = (card.dataset.title || '').toLowerCase();
					const cardAuthor = (card.dataset.author || '').toLowerCase();
					const cardIsbn = (card.dataset.isbn || '').toLowerCase();

					const cardRoomCode = (card.dataset.roomcode || '').toLowerCase();
					const cardCapacityRaw = card.dataset.capacity;
					const cardCapacity = (cardCapacityRaw !== undefined && cardCapacityRaw !== '') ? Number(cardCapacityRaw) : null;

					let visible = true;

					if (!typeVal.includes('ALL') && !typeVal.includes(cardType)) {
						visible = false;
					}

					if (onlyAvailable && !cardAvailable) visible = false;

					if (textVal) {
						const combined = (cardTitle + ' ' + cardAuthor + ' ' + cardIsbn + ' ' + cardRoomCode + ' ' + cardType + ' ' + cardId).toLowerCase();
						if (!combined.includes(textVal)) visible = false;
					}

					if (isbnVal) {
						if (cardType !== 'Book' || !cardIsbn.includes(isbnVal)) visible = false;
					}

					if (capacityVal !== null && !isNaN(capacityVal)) {
						if (cardType !== 'Room') {
							visible = false;
						} else {
							if (cardCapacity === null || isNaN(cardCapacity) || cardCapacity <= capacityVal) visible = false;
						}
					}

					card.style.display = visible ? '' : 'none';
					if (visible) anyVisibleInSection = true;
				});

				const empty = section.querySelector('.empty-placeholder');
				const grid = section.querySelector('.grid');
				if (!anyVisibleInSection) {
					if (grid) grid.style.display = 'none';
					if (empty) empty.style.display = '';
				} else {
					if (grid) grid.style.display = '';
					if (empty) empty.style.display = 'none';
				}

				const visibleCount = Array.from(section.querySelectorAll('.resource-item')).filter(c => c.style.display !== 'none').length;
				const countSpan = section.querySelector('.type-heading .count');
				if (countSpan) countSpan.textContent = visibleCount > 0 ? ` (${visibleCount})` : ' (0)';

				// Show or hide the whole section based on the currently selected types.
				// If a specific type is selected, only show sections that match it; otherwise show all.
				if (!typeVal.includes('ALL')) {
					section.style.display = typeVal.includes(section.dataset.type) ? '' : 'none';
				} else {
					section.style.display = '';
				}
			});

			const selected = getSelectedType();
			if (typeBar) {
				Array.from(typeBar.querySelectorAll('.type-btn')).forEach(b => {
					const isActive =
						(selected.includes('ALL') && b.classList.contains('all-types')) ||
						selected.includes(b.dataset.type);

					b.classList.toggle('active', isActive);
					b.setAttribute('aria-pressed', String(isActive));
				});
			}
		}

		// Type button delegation
		if (typeBar) {
			typeBar.addEventListener('click', (e) => {
				const btn = e.target.closest('.type-btn');
				if (!btn || !typeBar.contains(btn)) return;

				if (btn.classList.contains('all-types')) {
					Array.from(typeBar.querySelectorAll('.type-btn:not(.all-types)')).forEach(b => {
						b.classList.remove('active');
						b.setAttribute('aria-pressed', 'false');
					});
					btn.classList.add('active');
					btn.setAttribute('aria-pressed', 'true');
				} else {
					const isActive = btn.classList.toggle('active');
					btn.setAttribute('aria-pressed', String(isActive));

					const anyActive = typeBar.querySelectorAll('.type-btn.active:not(.all-types)').length > 0;
					if (!anyActive && allBtn) {
						allBtn.classList.add('active');
						allBtn.setAttribute('aria-pressed', 'true');
					} else if (allBtn) {
						allBtn.classList.remove('active');
						allBtn.setAttribute('aria-pressed', 'false');
					}
				}

				renderTypeSpecificFilters();
				applyFilters();
			});
		}

		// Position and toggle filter panel reliably
		function openFilterPanel() {
			if (!filterPanel || !filterToggle) return;
			const rect = filterToggle.getBoundingClientRect();
			// Use fixed positioning relative to viewport for predictable placement
			filterPanel.style.position = 'fixed';
			filterPanel.style.top = (rect.bottom + 8) + 'px';
			filterPanel.style.left = Math.max(8, rect.right - filterPanel.offsetWidth) + 'px';
			filterPanel.classList.add('open');
			filterPanel.setAttribute('aria-hidden', 'false');
			filterToggle.setAttribute('aria-expanded', 'true');
		}

		function closeFilterPanel() {
			if (!filterPanel || !filterToggle) return;
			filterPanel.classList.remove('open');
			filterPanel.setAttribute('aria-hidden', 'true');
			filterToggle.setAttribute('aria-expanded', 'false');
			filterPanel.style.left = '';
			filterPanel.style.top = '';
			filterPanel.style.position = '';
		}

		// Ensure the toggle is wired even if root was missing or removed
		if (filterToggle) {
			filterToggle.addEventListener('click', function (e) {
				e.stopPropagation();
				if (!filterPanel) return;
				if (filterPanel.classList.contains('open')) {
					closeFilterPanel();
				} else {
					renderTypeSpecificFilters();
					openFilterPanel();
					const firstInput = filterPanel.querySelector('input, select, textarea');
					if (firstInput) firstInput.focus();
				}
			});
		}

		// Close when clicking outside
		document.addEventListener('click', function (e) {
			if (!filterPanel) return;
			if (!filterPanel.classList.contains('open')) return;
			const isInside = filterPanel.contains(e.target) || (filterToggle && filterToggle.contains(e.target));
			if (!isInside) closeFilterPanel();
		});

		// Close on Escape
		document.addEventListener('keydown', function (e) {
			if (e.key === 'Escape' && filterPanel && filterPanel.classList.contains('open')) {
				closeFilterPanel();
				if (filterToggle) filterToggle.focus();
			}
		});

		// Wire inputs to apply filters
		[filterText, filterIsbn, filterCapacity, filterCapacityCustom, filterAvailable].forEach(el => {
			if (!el) return;
			el.addEventListener('input', applyFilters);
			el.addEventListener('change', applyFilters);
		});

		if (filterCapacity && filterCapacityCustom) {
			filterCapacity.addEventListener('change', () => {
				if (filterCapacity.value === 'custom') {
					filterCapacityCustom.style.display = '';
					filterCapacityCustom.focus();
				} else {
					filterCapacityCustom.style.display = 'none';
					filterCapacityCustom.value = '';
				}
				applyFilters();
			});
		}

		if (clearBtn) {
			clearBtn.addEventListener('click', () => {
				if (typeBar) {
					Array.from(typeBar.querySelectorAll('.type-btn')).forEach(b => {
						b.classList.remove('active');
						b.setAttribute('aria-pressed', 'false');
					});
				}
				if (allBtn) {
					allBtn.classList.add('active');
					allBtn.setAttribute('aria-pressed', 'true');
				}

				if (filterText) filterText.value = '';
				if (filterIsbn) filterIsbn.value = '';
				if (filterCapacity) filterCapacity.value = '';
				if (filterCapacityCustom) filterCapacityCustom.value = '';
				if (filterCapacityCustom) filterCapacityCustom.style.display = 'none';
				if (filterAvailable) filterAvailable.checked = true;

				renderTypeSpecificFilters();
				applyFilters();
			});
		}

		// Initial render
		renderTypeSpecificFilters();
		applyFilters();

		// Hide the original root only after wiring everything up.
		// This avoids the early-return / missing-element problem that made the filter button inert.
		try {
			if (root) {
				// keep it in DOM but hide visually for screen-readers if needed
				root.style.display = 'none';
				root.setAttribute('aria-hidden', 'true');
			}
		} catch (e) {
			// swallow errors — we don't want a hide failure to break the page
			console.warn('Could not hide resources-root:', e);
		}

		// Handle user reservations display
		const reservationsContainer = document.getElementById('reservations-container');
		const reservationsList = document.getElementById('reservations-list');
		const reservationsEmpty = document.getElementById('reservations-empty');

		if (reservationsContainer) {
			const reservationCards = reservationsList ? reservationsList.querySelectorAll('.reservation-card') : [];

			if (reservationCards.length > 0) {
				// Show the container and list, hide empty state
				reservationsContainer.style.display = '';
				reservationsContainer.setAttribute('aria-hidden', 'false');

				if (reservationsList) {
					reservationsList.style.display = '';
				}
				if (reservationsEmpty) {
					reservationsEmpty.style.display = 'none';
				}
			} else {
				// Hide the entire container when there are no reservations
				reservationsContainer.style.display = 'none';
				reservationsContainer.setAttribute('aria-hidden', 'true');
			}
		}
	});
})();