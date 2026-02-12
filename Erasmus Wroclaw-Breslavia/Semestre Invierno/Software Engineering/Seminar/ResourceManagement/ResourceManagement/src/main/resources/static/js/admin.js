// admin.js - Admin panel functionality

document.addEventListener('DOMContentLoaded', function() {
    // User form type toggle
    const userTypeSelect = document.getElementById('userType');
    if (userTypeSelect) {
        // Set initial state based on current selection
        toggleUserTypeFields();

        // Listen for changes
        userTypeSelect.addEventListener('change', toggleUserTypeFields);
    }

    // Resource form type toggle
    const resourceTypeSelect = document.getElementById('resourceType');
    const resourceTypeDisplay = document.getElementById('resourceTypeDisplay');

    if (resourceTypeSelect) {
        // Set initial state based on current selection
        toggleResourceFields();

        // Listen for changes (only in create mode)
        resourceTypeSelect.addEventListener('change', toggleResourceFields);
    } else if (resourceTypeDisplay) {
        // In edit mode, read from the display select
        toggleResourceFields();
    }

    // Reservation form preview and validation
    const resourceSelect = document.getElementById('resourceId');
    const clientSelect = document.getElementById('clientId');
    const startTimeInput = document.getElementById('startTime');
    const endTimeInput = document.getElementById('endTime');
    const submitBtn = document.querySelector('button[type="submit"]');

    if (resourceSelect && clientSelect && startTimeInput && endTimeInput) {
        resourceSelect.addEventListener('change', updateReservationPreview);
        clientSelect.addEventListener('change', updateReservationPreview);
        startTimeInput.addEventListener('input', updateReservationPreview);
        endTimeInput.addEventListener('input', updateReservationPreview);

        // Set minimum datetime to now
        const now = new Date();
        const localNow = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
            .toISOString()
            .slice(0, 16);
        startTimeInput.min = localNow;
        endTimeInput.min = localNow;

        // Update end time minimum when start time changes
        startTimeInput.addEventListener('input', function() {
            if (this.value) {
                endTimeInput.min = this.value;

                // Clear end time if it's before start time
                if (endTimeInput.value && endTimeInput.value <= this.value) {
                    endTimeInput.value = '';
                }
            }
            validateTimeRange();
        });

        // Validate on end time change
        endTimeInput.addEventListener('input', function() {
            validateTimeRange();
        });

        // Initial validation
        validateTimeRange();
    }

    // Validate time range and show error
    function validateTimeRange() {
        const startTime = startTimeInput?.value;
        const endTime = endTimeInput?.value;
        const previewDuration = document.getElementById('preview-duration');

        if (startTime && endTime) {
            const start = new Date(startTime);
            const end = new Date(endTime);

            if (end <= start) {
                // Show error
                if (previewDuration) {
                    previewDuration.textContent = '⚠️ End time must be after start time';
                    previewDuration.style.color = 'var(--alert-red)';
                }
                if (submitBtn) {
                    submitBtn.disabled = true;
                }

                // Add error class to inputs
                if (startTimeInput) startTimeInput.classList.add('error');
                if (endTimeInput) endTimeInput.classList.add('error');
            } else {
                // Clear error
                if (submitBtn) {
                    submitBtn.disabled = false;
                }

                // Remove error class
                if (startTimeInput) startTimeInput.classList.remove('error');
                if (endTimeInput) endTimeInput.classList.remove('error');

                // Update preview will handle the duration display
                updateReservationPreview();
            }
        } else {
            // Not enough data yet
            if (submitBtn) {
                submitBtn.disabled = !startTime || !endTime;
            }
        }
    }

    // Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.opacity = '0';
            alert.style.transition = 'opacity 300ms ease';
            setTimeout(() => alert.remove(), 300);
        }, 5000);
    });
});

/**
 * Toggle visibility of admin/client specific fields based on user type selection
 */
function toggleUserTypeFields() {
    const userType = document.getElementById('userType')?.value;
    const adminFields = document.getElementById('adminFields');
    const clientFields = document.getElementById('clientFields');

    if (!adminFields || !clientFields) return;

    if (userType === 'ADMIN') {
        adminFields.style.display = 'block';
        clientFields.style.display = 'none';

        // Clear client fields
        clearFieldGroup(clientFields);

        // Remove required from client fields
        setRequired('clientType', false);
        setRequired('maxActiveLoans', false);
        setRequired('maxActiveReservations', false);
    } else if (userType === 'CLIENT') {
        adminFields.style.display = 'none';
        clientFields.style.display = 'block';

        // Clear admin fields
        clearFieldGroup(adminFields);

        // Remove required from admin fields
        setRequired('adminLevel', false);
        setRequired('departmentId', false);
        setRequired('employeeCode', false);
    } else {
        adminFields.style.display = 'none';
        clientFields.style.display = 'none';

        // Clear both
        clearFieldGroup(adminFields);
        clearFieldGroup(clientFields);
    }
}

/**
 * Toggle visibility of book/room specific fields based on resource type selection
 */
function toggleResourceFields() {
    // Check both selects (create mode and edit mode)
    const resourceTypeSelect = document.getElementById('resourceType');
    const resourceTypeDisplay = document.getElementById('resourceTypeDisplay');

    let resourceType = '';
    if (resourceTypeSelect) {
        resourceType = resourceTypeSelect.value;
    } else if (resourceTypeDisplay) {
        resourceType = resourceTypeDisplay.value;
    }

    const bookFields = document.getElementById('bookFields');
    const roomFields = document.getElementById('roomFields');

    if (!bookFields || !roomFields) return;

    if (resourceType === 'BOOK') {
        bookFields.style.display = 'block';
        roomFields.style.display = 'none';

        // Clear room fields
        clearFieldGroup(roomFields);

        // Set required attributes for book fields
        setRequired('title', true);
        setRequired('author', true);
        setRequired('isbn', true);
        setRequired('year', true);
        setRequired('copiesAvailable', true);

        // Remove required from room fields
        setRequired('roomCode', false);
        setRequired('name', false);
        setRequired('location', false);
        setRequired('capacity', false);
    } else if (resourceType === 'ROOM') {
        bookFields.style.display = 'none';
        roomFields.style.display = 'block';

        // Clear book fields
        clearFieldGroup(bookFields);

        // Set required attributes for room fields
        setRequired('roomCode', true);
        setRequired('name', true);
        setRequired('location', true);
        setRequired('capacity', true);

        // Remove required from book fields
        setRequired('title', false);
        setRequired('author', false);
        setRequired('isbn', false);
        setRequired('year', false);
        setRequired('copiesAvailable', false);
    } else {
        bookFields.style.display = 'none';
        roomFields.style.display = 'none';

        // Clear both
        clearFieldGroup(bookFields);
        clearFieldGroup(roomFields);

        // Remove all required
        setRequired('title', false);
        setRequired('author', false);
        setRequired('isbn', false);
        setRequired('year', false);
        setRequired('copiesAvailable', false);
        setRequired('roomCode', false);
        setRequired('name', false);
        setRequired('location', false);
        setRequired('capacity', false);
    }
}

/**
 * Set or remove required attribute from a field
 */
function setRequired(fieldId, required) {
    const field = document.getElementById(fieldId);
    if (field) {
        if (required) {
            field.setAttribute('required', 'required');
        } else {
            field.removeAttribute('required');
        }
    }
}

/**
 * Clear all input fields within a container
 */
function clearFieldGroup(container) {
    if (!container) return;

    const inputs = container.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
        if (input.type === 'checkbox') {
            input.checked = false;
        } else {
            input.value = '';
        }
    });
}

/**
 * Update reservation preview with selected values
 */
function updateReservationPreview() {
    const resourceSelect = document.getElementById('resourceId');
    const clientSelect = document.getElementById('clientId');
    const startTimeInput = document.getElementById('startTime');
    const endTimeInput = document.getElementById('endTime');

    const previewResource = document.getElementById('preview-resource');
    const previewClient = document.getElementById('preview-client');
    const previewDuration = document.getElementById('preview-duration');

    if (!previewResource || !previewClient || !previewDuration) return;

    // Update resource preview
    if (resourceSelect && resourceSelect.value) {
        const selectedOption = resourceSelect.options[resourceSelect.selectedIndex];
        previewResource.textContent = selectedOption.text;
        previewResource.style.color = 'var(--white)';
    } else {
        previewResource.textContent = 'Not selected';
        previewResource.style.color = 'var(--muted-white)';
    }

    // Update client preview
    if (clientSelect && clientSelect.value) {
        const selectedOption = clientSelect.options[clientSelect.selectedIndex];
        previewClient.textContent = selectedOption.text;
        previewClient.style.color = 'var(--white)';
    } else {
        previewClient.textContent = 'Not selected';
        previewClient.style.color = 'var(--muted-white)';
    }

    // Update duration preview
    if (startTimeInput && endTimeInput && startTimeInput.value && endTimeInput.value) {
        const start = new Date(startTimeInput.value);
        const end = new Date(endTimeInput.value);

        if (end > start) {
            const duration = calculateDuration(start, end);
            previewDuration.textContent = duration;
            previewDuration.style.color = 'var(--white)';
        } else {
            previewDuration.textContent = '⚠️ End time must be after start time';
            previewDuration.style.color = 'var(--alert-red)';
        }
    } else {
        previewDuration.textContent = '-';
        previewDuration.style.color = 'var(--muted-white)';
    }
}

/**
 * Calculate human-readable duration between two dates
 */
function calculateDuration(start, end) {
    const diffMs = end - start;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffDays > 0) {
        const remainingHours = diffHours % 24;
        return `${diffDays} day${diffDays > 1 ? 's' : ''}${remainingHours > 0 ? `, ${remainingHours}h` : ''}`;
    } else if (diffHours > 0) {
        const remainingMins = diffMins % 60;
        return `${diffHours} hour${diffHours > 1 ? 's' : ''}${remainingMins > 0 ? `, ${remainingMins}m` : ''}`;
    } else {
        return `${diffMins} minute${diffMins > 1 ? 's' : ''}`;
    }
}

/**
 * Format datetime for display
 */
function formatDateTime(dateString) {
    if (!dateString) return '-';

    const date = new Date(dateString);
    const options = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    };

    return date.toLocaleDateString('en-US', options);
}