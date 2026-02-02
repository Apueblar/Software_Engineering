package com.example.web.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDateTime;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "app_user")
@Inheritance(strategy = InheritanceType.JOINED)
@Data
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    @EqualsAndHashCode.Include
    private Long id;

    @NotBlank(message = "name cannot be blank")
    @Size(max = 50)
    @Column(nullable = false, length = 50)
    private String name;

    @NotBlank(message = "password cannot be blank")
    @Size(min = 8, max = 100, message = "password must have at least 8 characters")
    @Column(nullable = false, length = 100)
    private String password;

    @NotBlank(message = "email cannot be blank")
    @Email(message = "email must be a valid address")
    @Column(unique = true, nullable = false)
    private String email;

    /**
     * Simple role string ("ROLE_USER" or "ROLE_ADMIN"). If you prefer many roles,
     * replace with an ElementCollection or separate Role entity.
     */
    @NotBlank
    @Column(nullable = false)
    private String role;
}
