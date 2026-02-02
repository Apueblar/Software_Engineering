package com.example.web.security;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SignUpForm {
    // common
    @NotBlank(message = "Name is required")
    private String name;
    @NotBlank(message = "Email is required")
    @Email(message = "Must be a valid email")
    private String email;
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
    private Boolean admin = false;

    // client
    private String clientType;
    @PositiveOrZero(message = "Max active loans cannot be negative")
    private Integer maxActiveLoans;
    @PositiveOrZero(message = "Max active reservations cannot be negative")
    private Integer maxActiveReservations;

    // admin
    @Min(value = 0, message = "Admin level must be at least 0")
    private Integer adminLevel;
    @Positive(message = "Department ID must be positive")
    private Long departmentId;
    @Size(min = 3, max = 50, message = "Employee code must be between 3 and 50 characters")
    private String employeeCode;
    private Boolean adminActive = true;

}
