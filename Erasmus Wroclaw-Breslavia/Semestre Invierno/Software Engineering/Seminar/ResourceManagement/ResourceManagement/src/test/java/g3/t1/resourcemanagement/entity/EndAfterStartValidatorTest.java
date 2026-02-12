package g3.t1.resourcemanagement.entity;

import jakarta.validation.ConstraintValidatorContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Unit tests for EndAfterStartValidator - validates the custom constraint
 * that ensures reservation end times occur after start times.
 *
 * Tests cover:
 * - Valid time intervals (end > start)
 * - Invalid intervals (end <= start)
 * - Null handling for both fields
 * - Edge cases (same time, minute differences)
 */
@ExtendWith(MockitoExtension.class)
class EndAfterStartValidatorTest {

    private EndAfterStartValidator validator;

    @Mock
    private ConstraintValidatorContext context;

    private Reservation reservation;

    @BeforeEach
    void setUp() {
        validator = new EndAfterStartValidator();
        reservation = new Reservation();

        // Initialize with a valid ReservationId
        ReservationId id = new ReservationId();
        reservation.setId(id);
    }

    @Test
    void isValid_ShouldReturnTrue_WhenEndTimeIsAfterStartTime() {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 10, 0);
        LocalDateTime end = LocalDateTime.of(2024, 1, 1, 12, 0);

        reservation.setStartTime(start);
        reservation.getId().setEndTime(end);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isTrue();
    }

    @Test
    void isValid_ShouldReturnFalse_WhenEndTimeIsBeforeStartTime() {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 12, 0);
        LocalDateTime end = LocalDateTime.of(2024, 1, 1, 10, 0);

        reservation.setStartTime(start);
        reservation.getId().setEndTime(end);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isFalse();
    }

    @Test
    void isValid_ShouldReturnFalse_WhenEndTimeEqualsStartTime() {
        LocalDateTime time = LocalDateTime.of(2024, 1, 1, 10, 0);

        reservation.setStartTime(time);
        reservation.getId().setEndTime(time);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isFalse();
    }

    @Test
    void isValid_ShouldReturnTrue_WhenStartTimeIsNull() {
        LocalDateTime end = LocalDateTime.of(2024, 1, 1, 12, 0);

        reservation.setStartTime(null);
        reservation.getId().setEndTime(end);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isTrue();
    }

    @Test
    void isValid_ShouldReturnTrue_WhenEndTimeIsNull() {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 10, 0);

        reservation.setStartTime(start);
        reservation.getId().setEndTime(null);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isTrue();
    }

    @Test
    void isValid_ShouldReturnTrue_WhenBothTimesAreNull() {
        reservation.setStartTime(null);
        reservation.getId().setEndTime(null);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isTrue();
    }

    @Test
    void isValid_ShouldHandleMinutesDifference() {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 10, 0, 0);
        LocalDateTime end = LocalDateTime.of(2024, 1, 1, 10, 0, 1);

        reservation.setStartTime(start);
        reservation.getId().setEndTime(end);

        boolean result = validator.isValid(reservation, context);

        assertThat(result).isTrue();
    }

    @Test
    void isValid_ShouldReturnTrue_WhenReservationIsNull() {
        boolean result = validator.isValid(null, context);

        assertThat(result).isTrue();
    }
}