package g3.t1.resourcemanagement.web;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UserForm {

    @NotBlank(message = "Name is required")
    @Size(max = 50, message = "Name must not exceed 50 characters")
    private String name;

    @Email(message = "Enter a valid email")
    @NotBlank(message = "Email is required")
    private String email;

    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    /**
     * "CLIENT" or "ADMIN"
     */
    @NotBlank(message = "User type is required")
    private String userType;

    /* --- Admin-specific optional fields --- */
    private Integer adminLevel; // e.g. 10
    private Boolean adminActive; // e.g. true
    private Long departmentId; // e.g. 1001
    private String employeeCode; // e.g. "ADM001"

    /* --- Client-specific optional fields --- */
    private String clientType; // e.g. "STANDARD"
    private Integer maxActiveLoans; // e.g. 5
    private Integer maxActiveReservations; // e.g. 3
    private LocalDate blockedUntil; // Changed to LocalDate for proper binding
}