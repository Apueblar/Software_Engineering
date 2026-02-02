package com.example.web.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import java.time.LocalDateTime;

@Entity
@Table(name = "client")
@DiscriminatorValue("CLIENT")
@Data
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Client extends User {

    @NotNull(message = "maxActiveLoans cannot be null")
    @PositiveOrZero(message = "maxActiveLoans cannot be negative")
    @Column(name = "max_active_loans",  nullable = false)
    private Integer maxActiveLoans;
}
