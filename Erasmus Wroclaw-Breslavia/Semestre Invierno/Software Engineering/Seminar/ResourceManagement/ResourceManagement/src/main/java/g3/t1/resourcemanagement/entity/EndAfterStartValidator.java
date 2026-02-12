package g3.t1.resourcemanagement.entity;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import g3.t1.resourcemanagement.web.ReservationForm;

import java.time.LocalDateTime;

public class EndAfterStartValidator implements ConstraintValidator<EndAfterStart, Object> {

	@Override
	public void initialize(EndAfterStart constraintAnnotation) {
	}

	@Override
	public boolean isValid(Object obj, ConstraintValidatorContext context) {
		if (obj == null)
			return true;
		LocalDateTime start = null;
		LocalDateTime end = null;

		if (obj instanceof ReservationForm form) {
			start = form.getStartTime();
			end = form.getEndTime();
		} else if (obj instanceof Reservation reservation) {
			start = reservation.getStartTime();
			end = reservation.getId().getEndTime();
		} else {
			// unsupported type
			return true;
		}

		if (start == null || end == null)
			return true;
		return end.isAfter(start);
	}

}
