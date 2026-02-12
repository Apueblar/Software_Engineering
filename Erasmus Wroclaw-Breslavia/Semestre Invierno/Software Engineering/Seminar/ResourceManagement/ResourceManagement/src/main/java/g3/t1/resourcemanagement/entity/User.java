package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "app_user") // We cant use user as it is a reserved word
@DiscriminatorColumn(name = "user_type", discriminatorType = DiscriminatorType.STRING)
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@SuperBuilder
@ToString(exclude = "password")
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public abstract class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    @EqualsAndHashCode.Include
    private Long id;

    @NotBlank(message = "name cannot be blank")
    @Size(max = 50)
    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false) // It must be hashed
    private String password;

    @NotBlank(message = "email cannot be blank")
    @Email(message = "email must be a valid address")
    @Column(unique = true, nullable = false)
    private String email;

    @NotNull(message = "accountStatus cannot be null")
    @Enumerated(EnumType.STRING)
    @Column(name = "account_status", nullable = false, length = 20)
    private AccountStatus accountStatus;

    @NotNull(message = "createdAt cannot be null")
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}