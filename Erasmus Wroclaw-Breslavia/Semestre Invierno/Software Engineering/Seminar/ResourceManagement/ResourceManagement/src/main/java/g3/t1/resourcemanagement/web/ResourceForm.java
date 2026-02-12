package g3.t1.resourcemanagement.web;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ResourceForm {

    private Long id; // null for create, set for edit

    @NotBlank(message = "Resource type is required")
    private String resourceType; // "BOOK" or "ROOM"

    private Boolean available = true;

    /* --- Book-specific fields --- */
    @Size(max = 255, message = "Title cannot exceed 255 characters")
    private String title;

    @Size(max = 255, message = "Author cannot exceed 255 characters")
    private String author;

    @Size(max = 17, message = "ISBN cannot exceed 17 characters")
    private String isbn;

    @Min(value = 1450, message = "Year must be at least 1450")
    @Max(value = 2100, message = "Year cannot exceed 2100")
    private Integer year;

    @Min(value = 0, message = "Copies available cannot be negative")
    private Integer copiesAvailable;

    /* --- Room-specific fields --- */
    @Size(max = 255, message = "Room code cannot exceed 255 characters")
    private String roomCode;

    @Size(max = 255, message = "Name cannot exceed 255 characters")
    private String name;

    @Min(value = 1, message = "Capacity must be at least 1")
    private Integer capacity;

    @Size(max = 255, message = "Location cannot exceed 255 characters")
    private String location;
}