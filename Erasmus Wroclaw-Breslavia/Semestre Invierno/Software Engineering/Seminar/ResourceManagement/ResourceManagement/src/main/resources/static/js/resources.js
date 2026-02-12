// resources.js - Interactive reservation schedule features

document.addEventListener('DOMContentLoaded', function () {

    // Highlight conflicting times in the form
    const startInput = document.querySelector('input[name="startTime"]');
    const endInput = document.querySelector('input[name="endTime"]');
    const submitBtn = document.getElementById('submitBtn');

    if (startInput && endInput) {
        const checkConflicts = () => {
            const start = new Date(startInput.value);
            const end = new Date(endInput.value);

            if (!startInput.value || !endInput.value || isNaN(start.getTime()) || isNaN(end.getTime())) {
                clearWarnings();
                disableSubmitButton('Please fill in both start and end times');
                return;
            }

            if (end <= start) {
                showWarning('End time must be after start time');
                disableSubmitButton('Invalid time range');
                return;
            }

            // Check against existing reservations (excluding current if editing)
            const reservations = getExistingReservations();
            const conflicts = reservations.filter(res => {
                return start < res.end && end > res.start && !res.isCurrentEdit;
            });

            if (conflicts.length > 0) {
                showConflictWarning(conflicts);
                disableSubmitButton('Resolve conflicts before updating');
            } else {
                clearWarnings();
                enableSubmitButton();
            }
        };

        startInput.addEventListener('change', checkConflicts);
        endInput.addEventListener('change', checkConflicts);

        // Also check on input to provide real-time feedback
        startInput.addEventListener('input', checkConflicts);
        endInput.addEventListener('input', checkConflicts);

        // Initial check on page load
        checkConflicts();
    }

    // Add visual indicators to the schedule
    highlightCurrentReservation();

    // Auto-scroll to current reservation if exists
    scrollToCurrentReservation();
});

function getExistingReservations() {
    const reservations = [];
    const rows = document.querySelectorAll('.schedule-table tbody tr');

    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 2) {
            // Parse dates - handle format "yyyy-MM-dd HH:mm"
            const startText = cells[0].textContent.trim();
            const endText = cells[1].textContent.trim();

            const start = new Date(startText.replace(' ', 'T'));
            const end = new Date(endText.replace(' ', 'T'));

            // Check if this is the reservation being edited (marked with data-is-current="true")
            const isCurrentEdit = row.getAttribute('data-is-current') === 'true';

            // Only add if status is ACTIVE (not CANCELLED)
            const statusBadge = cells[2].querySelector('.status-badge');
            const status = statusBadge ? statusBadge.textContent.trim() : '';

            if (status === 'ACTIVE' && !isNaN(start.getTime()) && !isNaN(end.getTime())) {
                reservations.push({ start, end, row, isCurrentEdit });
            }
        }
    });

    return reservations;
}

function showWarning(message) {
    clearWarnings();

    const warning = document.createElement('div');
    warning.className = 'time-warning';
    warning.textContent = message;

    const form = document.querySelector('.reservation-form form');
    form.insertBefore(warning, form.firstChild);
}

function showConflictWarning(conflicts) {
    clearWarnings();

    const warning = document.createElement('div');
    warning.className = 'time-conflict';
    warning.innerHTML = `
        <strong>⚠️ Time Conflict Detected</strong>
        <p>The selected time overlaps with ${conflicts.length} existing reservation(s). 
        Please choose a different time slot to update your reservation.</p>
    `;

    const form = document.querySelector('.reservation-form form');
    form.insertBefore(warning, form.firstChild);

    // Highlight conflicting rows
    conflicts.forEach(conflict => {
        conflict.row.classList.add('conflict-highlight');
    });
}

function clearWarnings() {
    const warnings = document.querySelectorAll('.time-warning, .time-conflict');
    warnings.forEach(w => w.remove());

    const highlighted = document.querySelectorAll('.conflict-highlight');
    highlighted.forEach(row => row.classList.remove('conflict-highlight'));
}

function disableSubmitButton(reason) {
    const submitBtn = document.getElementById('submitBtn');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.setAttribute('title', reason || 'Cannot submit with conflicts');
        submitBtn.style.cursor = 'not-allowed';
    }
}

function enableSubmitButton() {
    const submitBtn = document.getElementById('submitBtn');
    if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.removeAttribute('title');
        submitBtn.style.cursor = 'pointer';
    }
}

function highlightCurrentReservation() {
    const now = new Date();
    const reservations = getExistingReservations();

    reservations.forEach(res => {
        if (now >= res.start && now < res.end) {
            res.row.classList.add('current-reservation');
        }
    });
}

function scrollToCurrentReservation() {
    // First try to scroll to the reservation being edited (on edit page)
    const currentEdit = document.querySelector('tr[data-is-current="true"]');
    if (currentEdit) {
        setTimeout(() => {
            currentEdit.scrollIntoView({ behavior: 'smooth', block: 'center' });
            // Add a temporary highlight
            currentEdit.style.backgroundColor = 'rgba(251, 191, 36, 0.25)';
            setTimeout(() => {
                currentEdit.style.backgroundColor = '';
            }, 2000);
        }, 300);
        return;
    }

    // Otherwise scroll to current active reservation
    const current = document.querySelector('.current-reservation');
    if (current) {
        setTimeout(() => {
            current.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }, 300);
    }
}

// Set minimum datetime for reservation inputs to now
const now = new Date();
const offset = now.getTimezoneOffset();
const localNow = new Date(now.getTime() - (offset * 60 * 1000));
const minDateTime = localNow.toISOString().slice(0, 16);

const startTimeInput = document.querySelector('input[name="startTime"]');
const endTimeInput = document.querySelector('input[name="endTime"]');

if (startTimeInput) {
    startTimeInput.setAttribute('min', minDateTime);
}

if (endTimeInput) {
    endTimeInput.setAttribute('min', minDateTime);
}