package g3.t1.resourcemanagement.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.*;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class ReservationId implements Serializable {

    @NotNull(message = "resourceId cannot be null")
    @Column(name = "resource_id", nullable = false)
    private Long resourceId;

    @NotNull(message = "endTime cannot be null")
    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;
}
