package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "admin")
@DiscriminatorValue("ADMIN")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Admin extends User {

    @NotNull
    @Min(value = 0, message = "adminLevel must be at least 0")
    @Column(name = "admin_level", nullable = false)
    private Integer adminLevel;

    @NotNull
    @Column(nullable = false)
    private Boolean active;

    @NotNull
    @Positive(message = "departmentId must be positive")
    @Column(name = "department_id", nullable = false)
    private Long departmentId;

    @NotBlank(message = "employeeCode cannot be blank")
    @Size(min = 3, message = "employeeCode length must be between 3 and 50")
    @Column(name = "employee_code", unique = true, nullable = false)
    private String employeeCode;
}