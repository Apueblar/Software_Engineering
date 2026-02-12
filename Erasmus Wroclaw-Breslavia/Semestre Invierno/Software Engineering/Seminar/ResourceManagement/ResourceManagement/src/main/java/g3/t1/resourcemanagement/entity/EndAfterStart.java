package g3.t1.resourcemanagement.entity;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.TYPE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Documented
@Constraint(validatedBy = EndAfterStartValidator.class)
@Target({ TYPE })
@Retention(RUNTIME)
public @interface EndAfterStart {
    String message() default "reservation end time must be after start time";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
