package g3.t1.resourcemanagement.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "room")
@DiscriminatorValue("ROOM")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true, onlyExplicitlyIncluded = true)
public class Room extends Resource {

    @NotBlank(message = "roomCode cannot be blank")
    @Size(max = 255)
    @Column(name = "room_code", unique = true, nullable = false)
    private String roomCode;

    // display name of the room
    @NotBlank(message = "name cannot be blank")
    @Size(max = 255)
    @Column(nullable = false)
    private String name;

    @NotNull(message = "capacity cannot be null")
    @Min(value = 1, message = "capacity must be at least 1")
    @Column(nullable = false)
    private Integer capacity;

    @NotBlank(message = "location cannot be blank")
    @Size(max = 255)
    @Column(nullable = false)
    private String location;
}
