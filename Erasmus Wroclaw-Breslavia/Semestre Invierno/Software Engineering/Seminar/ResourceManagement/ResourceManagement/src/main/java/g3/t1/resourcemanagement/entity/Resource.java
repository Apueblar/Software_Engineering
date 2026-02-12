package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "resource")
@DiscriminatorColumn(name = "resource_type", discriminatorType = DiscriminatorType.STRING)
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@SuperBuilder
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public abstract class Resource {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "resource_id")
    @EqualsAndHashCode.Include
    private Long id;

    /**
     * Whether this resource is currently available for reservation/loan.
     * Default true (Builder picks this up thanks to @Builder.Default).
     */
    @Builder.Default
    @NotNull
    @Column(nullable = false)
    private Boolean available = true;

    public Long getResourceId() {
        return id;
    }

    @Transient
    public String getResourceType() {
        if (this instanceof Book) {
            return "Book";
        } else if (this instanceof Room) {
            return "Room";
        }
        return "Resource";
    }
}
