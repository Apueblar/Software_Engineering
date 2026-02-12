package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.Book;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.entity.Room;
import g3.t1.resourcemanagement.repository.BookRepository;
import g3.t1.resourcemanagement.repository.ReservationRepository;
import g3.t1.resourcemanagement.repository.ResourceRepository;
import g3.t1.resourcemanagement.repository.RoomRepository;
import g3.t1.resourcemanagement.web.ResourceForm;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ResourceService {

	private final ResourceRepository resourceRepository;
	private final ReservationRepository reservationRepository;
	private final BookRepository bookRepository;
	private final RoomRepository roomRepository;

	public List<Resource> findAll() {
		return resourceRepository.findAll();
	}

	/**
	 * Find resource by ID
	 */
	public Resource findById(Long id) {
		return resourceRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Resource not found with ID: " + id));
	}

	/**
	 * Returns a list of resource IDs that are reserved at the given start time
	 */
	public List<Long> findReservedResourceIdsAt(LocalDateTime startTime) {
		return reservationRepository.findResourceIdsReservedAt(startTime);
	}

	public List<Long> findReservedResourceIdsBetween(LocalDateTime startTime, LocalDateTime endTime) {
		if (startTime == null || endTime == null || !endTime.isAfter(startTime)) {
			return List.of();
		}
		return reservationRepository.findResourceIdsReservedBetween(startTime, endTime);
	}

	public Optional<Resource> findById(String decoded) {
		if (decoded == null)
			return Optional.empty();
		String trimmed = decoded.trim();
		if (trimmed.isEmpty())
			return Optional.empty();

		String normalized = normalizePayload(trimmed);

		// Try numeric id
		try {
			Long id = Long.parseLong(normalized);
			return resourceRepository.findById(id);
		} catch (NumberFormatException ignored) {
		}
		return Optional.empty();
	}

	private String normalizePayload(String payload) {
		String p = payload.trim();
		String[] prefixes = {"RES:", "RESOURCE:", "R:", "ID:", "RES-", "RESOURCE-"};

		for (String prefix : prefixes) {
			if (p.regionMatches(true, 0, prefix, 0, prefix.length())) {
				p = p.substring(prefix.length()).trim();
				break;
			}
		}

		int lastSlash = p.lastIndexOf('/');
		if (lastSlash >= 0 && lastSlash < p.length() - 1) {
			String last = p.substring(lastSlash + 1).trim();
			if (!last.isEmpty())
				p = last;
		}

		return p;
	}

	@Transactional
	public Resource save(Resource resource) {
		return resourceRepository.save(resource);
	}

	/**
	 * Create a new resource from form data
	 */
	@Transactional
	public void createResourceFromForm(ResourceForm form) {
		if (form.getResourceType() == null || form.getResourceType().isBlank()) {
			throw new IllegalArgumentException("Resource type is required");
		}

		if ("BOOK".equalsIgnoreCase(form.getResourceType())) {
			createBook(form);
		} else if ("ROOM".equalsIgnoreCase(form.getResourceType())) {
			createRoom(form);
		} else {
			throw new IllegalArgumentException("Invalid resource type: " + form.getResourceType());
		}
	}

	/**
	 * Update an existing resource from form data
	 */
	@Transactional
	public void updateResourceFromForm(ResourceForm form) {
		if (form.getId() == null) {
			throw new IllegalArgumentException("Resource ID is required for update");
		}

		Resource resource = findById(form.getId());

		// Update availability (common field)
		resource.setAvailable(form.getAvailable() != null ? form.getAvailable() : true);

		if (resource instanceof Book) {
			updateBook((Book) resource, form);
		} else if (resource instanceof Room) {
			updateRoom((Room) resource, form);
		}
	}

	/**
	 * Convert Resource entity to ResourceForm
	 */
	public ResourceForm toResourceForm(Resource resource) {
		ResourceForm form = new ResourceForm();
		form.setId(resource.getId());
		form.setAvailable(resource.getAvailable());

		if (resource instanceof Book) {
			Book book = (Book) resource;
			form.setResourceType("BOOK");
			form.setTitle(book.getTitle());
			form.setAuthor(book.getAuthor());
			form.setIsbn(book.getIsbn());
			form.setYear(book.getYear());
			form.setCopiesAvailable(book.getCopiesAvailable());
		} else if (resource instanceof Room) {
			Room room = (Room) resource;
			form.setResourceType("ROOM");
			form.setRoomCode(room.getRoomCode());
			form.setName(room.getName());
			form.setLocation(room.getLocation());
			form.setCapacity(room.getCapacity());
		}

		return form;
	}

	@Transactional
	public void deleteById(Long id) {
		Resource resource = findById(id);
		resourceRepository.delete(resource);
	}

	// ========== PRIVATE HELPER METHODS ==========

	/**
	 * Create a new Book
	 */
	private void createBook(ResourceForm form) {
		// Validate book-specific fields
		if (form.getTitle() == null || form.getTitle().isBlank()) {
			throw new IllegalArgumentException("Title is required for books");
		}
		if (form.getAuthor() == null || form.getAuthor().isBlank()) {
			throw new IllegalArgumentException("Author is required for books");
		}
		if (form.getIsbn() == null || form.getIsbn().isBlank()) {
			throw new IllegalArgumentException("ISBN is required for books");
		}
		if (form.getYear() == null) {
			throw new IllegalArgumentException("Year is required for books");
		}
		if (form.getCopiesAvailable() == null) {
			throw new IllegalArgumentException("Copies available is required for books");
		}

		// Check ISBN uniqueness
		String isbn = form.getIsbn().trim();
		Optional<Book> existingBook = bookRepository.findByIsbn(isbn);
		if (existingBook.isPresent()) {
			throw new IllegalArgumentException("A book with ISBN '" + isbn + "' already exists");
		}

		Book book = Book.builder()
				.available(form.getAvailable() != null ? form.getAvailable() : true)
				.title(form.getTitle().trim())
				.author(form.getAuthor().trim())
				.isbn(isbn)
				.year(form.getYear())
				.copiesAvailable(form.getCopiesAvailable())
				.build();

		bookRepository.save(book);
	}

	/**
	 * Create a new Room
	 */
	private void createRoom(ResourceForm form) {
		// Validate room-specific fields
		if (form.getRoomCode() == null || form.getRoomCode().isBlank()) {
			throw new IllegalArgumentException("Room code is required for rooms");
		}
		if (form.getName() == null || form.getName().isBlank()) {
			throw new IllegalArgumentException("Room name is required for rooms");
		}
		if (form.getLocation() == null || form.getLocation().isBlank()) {
			throw new IllegalArgumentException("Location is required for rooms");
		}
		if (form.getCapacity() == null) {
			throw new IllegalArgumentException("Capacity is required for rooms");
		}

		// Check room code uniqueness
		String roomCode = form.getRoomCode().trim();
		Optional<Room> existingRoom = roomRepository.findByRoomCode(roomCode);
		if (existingRoom.isPresent()) {
			throw new IllegalArgumentException("A room with code '" + roomCode + "' already exists");
		}

		Room room = Room.builder()
				.available(form.getAvailable() != null ? form.getAvailable() : true)
				.roomCode(roomCode)
				.name(form.getName().trim())
				.location(form.getLocation().trim())
				.capacity(form.getCapacity())
				.build();

		roomRepository.save(room);
	}

	/**
	 * Update an existing Book
	 */
	private void updateBook(Book book, ResourceForm form) {
		boolean updated = false;

		if (form.getTitle() != null && !form.getTitle().isBlank()) {
			book.setTitle(form.getTitle().trim());
			updated = true;
		}

		if (form.getAuthor() != null && !form.getAuthor().isBlank()) {
			book.setAuthor(form.getAuthor().trim());
			updated = true;
		}

		if (form.getIsbn() != null && !form.getIsbn().isBlank()) {
			String newIsbn = form.getIsbn().trim();
			if (!book.getIsbn().equals(newIsbn)) {
				Optional<Book> existingBook = bookRepository.findByIsbn(newIsbn);
				if (existingBook.isPresent() && !existingBook.get().getId().equals(book.getId())) {
					throw new IllegalArgumentException("A book with ISBN '" + newIsbn + "' already exists");
				}
				book.setIsbn(newIsbn);
				updated = true;
			}
		}

		if (form.getYear() != null) {
			book.setYear(form.getYear());
			updated = true;
		}

		if (form.getCopiesAvailable() != null) {
			book.setCopiesAvailable(form.getCopiesAvailable());
			updated = true;
		}

		if (updated) {
			bookRepository.save(book);
		}
	}

	/**
	 * Update an existing Room
	 */
	private void updateRoom(Room room, ResourceForm form) {
		boolean updated = false;

		if (form.getRoomCode() != null && !form.getRoomCode().isBlank()) {
			String newRoomCode = form.getRoomCode().trim();
			if (!room.getRoomCode().equals(newRoomCode)) {
				Optional<Room> existingRoom = roomRepository.findByRoomCode(newRoomCode);
				if (existingRoom.isPresent() && !existingRoom.get().getId().equals(room.getId())) {
					throw new IllegalArgumentException("A room with code '" + newRoomCode + "' already exists");
				}
				room.setRoomCode(newRoomCode);
				updated = true;
			}
		}

		if (form.getName() != null && !form.getName().isBlank()) {
			room.setName(form.getName().trim());
			updated = true;
		}

		if (form.getLocation() != null && !form.getLocation().isBlank()) {
			room.setLocation(form.getLocation().trim());
			updated = true;
		}

		if (form.getCapacity() != null) {
			room.setCapacity(form.getCapacity());
			updated = true;
		}

		if (updated) {
			roomRepository.save(room);
		}
	}
}