package com.example.web.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "admin")
@DiscriminatorValue("ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Admin extends User {

    @NotNull
    @Min(value = 0, message = "adminLevel must be at least 0")
    @Column(name = "admin_level", nullable = false)
    private Integer adminLevel;
}