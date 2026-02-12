package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "book")
@DiscriminatorValue("BOOK")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Book extends Resource {

    @NotBlank(message = "author cannot be blank")
    @Size(max = 255)
    @Column(nullable = false)
    private String author;

    @NotBlank(message = "title cannot be blank")
    @Size(max = 255)
    @Column(nullable = false)
    private String title;

    /**
     * Basic ISBN format check:
     * - allows digits, hyphens, spaces and X (for ISBN-10 check digit)
     * - length between 10 and 17 chars (common when hyphens included)
     * If you need stronger validation, consider a dedicated ISBN validator.
     */
    @NotBlank(message = "isbn cannot be blank")
    @Size(min = 10, max = 17, message = "isbn length must be between 10 and 17")
    @Pattern(regexp = "^[0-9Xx\\- ]{10,17}$", message = "isbn must contain only digits, hyphens, spaces or 'X'")
    @Column(unique = true, nullable = false)
    private String isbn;

    @NotNull(message = "year cannot be null")
    @Min(value = 1450, message = "year must be realistic (>= 1450)")
    // Create a constraint but after MVP @YearNotInFuture(message = "year cannot be
    // in the future")
    @Column(nullable = false)
    private Integer year;

    @NotNull(message = "copiesAvailable cannot be null")
    @Min(value = 0, message = "copiesAvailable cannot be negative")
    @Column(name = "copies_available", nullable = false)
    private Integer copiesAvailable;
}
