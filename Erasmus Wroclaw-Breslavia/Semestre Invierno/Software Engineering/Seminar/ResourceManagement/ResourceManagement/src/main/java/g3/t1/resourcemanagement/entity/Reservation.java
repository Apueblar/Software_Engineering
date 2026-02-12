package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "reservation")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@EndAfterStart
public class Reservation {

    @EqualsAndHashCode.Include
    @EmbeddedId
    @Valid
    @NotNull(message = "id cannot be null")
    private ReservationId id;

    @MapsId("resourceId") // binds id.resourceId to this FK
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "resource_id", nullable = false)
    @ToString.Exclude
    @NotNull(message = "resource cannot be null")
    private Resource resource;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id")
    @ToString.Exclude
    private Admin admin;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    @ToString.Exclude
    @NotNull(message = "client cannot be null")
    private Client client;

    @NotNull(message = "startTime cannot be null")
    @FutureOrPresent(message = "startTime must be present or in the future")
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @NotBlank(message = "status cannot be blank")
    @Column(nullable = false)
    private String status;

    @Size(max = 2000, message = "notes cannot exceed 2000 characters")
    @Column(length = 2000)
    private String notes;

    @PrePersist
    @PreUpdate
    private void syncId() {
        if (id == null) {
            id = new ReservationId();
        }
        // Use the Resource's id getter that your code uses elsewhere (getId())
        if (resource != null && resource.getId() != null) {
            id.setResourceId(resource.getId());
        }
        // Ensure endTime is present in id (do not override if already set)
        if (id.getEndTime() == null && startTime != null) {
            // optional fallback: set endTime to something sensible or throw
            // Better: don't set it here; require caller to set id.endTime explicitly.
        }
    }
}