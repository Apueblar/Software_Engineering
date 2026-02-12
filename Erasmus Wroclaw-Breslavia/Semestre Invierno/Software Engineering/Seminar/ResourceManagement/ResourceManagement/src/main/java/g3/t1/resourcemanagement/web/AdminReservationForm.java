package g3.t1.resourcemanagement.web;

import g3.t1.resourcemanagement.entity.EndAfterStart;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/**
 * Admin-facing reservation form: includes resourceId and clientId so admin can
 * create reservations on behalf of a user.
 */
@Data
@EndAfterStart
public class AdminReservationForm {

    @NotNull(message = "Resource is required")
    private Long resourceId;

    @NotNull(message = "Client is required")
    private Long clientId;

    @NotNull(message = "Start time is required")
    @FutureOrPresent(message = "Start time must be present or future")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime startTime;

    @NotNull(message = "End time is required")
    @FutureOrPresent(message = "End time must be present or future")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime endTime;

    @Size(max = 2000, message = "Notes cannot exceed 2000 characters")
    private String notes;
}