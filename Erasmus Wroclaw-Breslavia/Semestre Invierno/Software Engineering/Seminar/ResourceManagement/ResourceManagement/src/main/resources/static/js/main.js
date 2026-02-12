// src/main/resources/static/js/reservation-validation.js
document.addEventListener('DOMContentLoaded', function () {
  const form = document.querySelector('#reservationForm'); // use a specific id
  if (!form) return;

  const parseDateValue = (v, type) => {
    if (!v) return null;
    // datetime-local browsers expose valueAsDate
    if (type === 'datetime-local') {
      try { return new Date(v); } catch (e) { /* fallback below */ }
    }
    // try ISO-like first
    const iso = v.replace(' ', 'T');
    const dIso = new Date(iso);
    if (!isNaN(dIso)) return dIso;
    // dd/MM/yyyy HH:mm or dd-MM-yyyy HH:mm
    const m = v.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})[ T](\d{1,2}):(\d{2})(?::(\d{2}))?$/);
    if (m) {
      return new Date(
        parseInt(m[3], 10),
        parseInt(m[2], 10) - 1,
        parseInt(m[1], 10),
        parseInt(m[4], 10),
        parseInt(m[5], 10),
        m[6] ? parseInt(m[6], 10) : 0
      );
    }
    const d = new Date(v);
    return isNaN(d) ? null : d;
  };

  function validateReservationTimes(e) {
    const startEl = form.querySelector('input[name="startTime"], input[id="startTime"]');
    const endEl = form.querySelector('input[name="endTime"], input[id="endTime"]');
    if (!startEl || !endEl) return;

    const s = parseDateValue(startEl.value, startEl.type);
    const en = parseDateValue(endEl.value, endEl.type);

    // If parsing failed, do not block here; let server-side validation handle it
    if (!s || !en) {
      if (typeof endEl.setCustomValidity === 'function') endEl.setCustomValidity('');
      return;
    }

    if (en <= s) {
      e.preventDefault();
      if (typeof endEl.setCustomValidity === 'function') {
        endEl.setCustomValidity('End time must be after start time');
        endEl.reportValidity();
        endEl.addEventListener('input', () => endEl.setCustomValidity(''), { once: true });
      } else {
        alert('End time must be after start time');
      }
    } else {
      if (typeof endEl.setCustomValidity === 'function') endEl.setCustomValidity('');
    }
  }

  // Remove any existing submit listeners added earlier (debugging helper)
  const existing = (getEventListeners && getEventListeners(form).submit) || [];
  existing.forEach(l => form.removeEventListener('submit', l.listener));

  form.addEventListener('submit', validateReservationTimes);
});
