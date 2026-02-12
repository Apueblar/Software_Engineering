package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "client")
@DiscriminatorValue("CLIENT")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Client extends User {

    @NotBlank(message = "clientType cannot be blank")
    @Column(name = "client_type", nullable = false)
    private String clientType;

    @NotNull(message = "maxActiveLoans cannot be null")
    @PositiveOrZero(message = "maxActiveLoans cannot be negative")
    @Column(name = "max_active_loans", nullable = false)
    private Integer maxActiveLoans;

    @NotNull(message = "maxActiveReservations cannot be null")
    @PositiveOrZero(message = "maxActiveReservations cannot be negative")
    @Column(name = "max_active_reservations", nullable = false)
    private Integer maxActiveReservations;

    /**
     * If present, blockedUntil should typically be in the future.
     * Use @Future if you want to enforce it must be a future date when set.
     * Implementation will be after MVP
     */
    @Column(name = "blocked_until")
    private LocalDate blockedUntil;

}
