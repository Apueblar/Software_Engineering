package g3.t1.resourcemanagement.web;

import g3.t1.resourcemanagement.entity.EndAfterStart; // your custom annotation
import org.springframework.format.annotation.DateTimeFormat;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

@EndAfterStart
@Data
public class ReservationForm {

    @NotNull(message = "Start time is required")
    @FutureOrPresent(message = "Start time must be present or future")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime startTime;

    @NotNull(message = "End time is required")
    @FutureOrPresent(message = "End time must be present or future")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime endTime;

    @Size(max = 2000)
    private String notes;
}
