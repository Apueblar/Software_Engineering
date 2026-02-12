package g3.t1.resourcemanagement.entity;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.hibernate.grammars.hql.HqlParser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class EntityValidationTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void client_ShouldBeValid_WhenAllFieldsCorrect() {
        Client client = Client.builder()
                .name("validuser")
                .email("valid@example.com")
                .password("password123")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .createdAt(LocalDateTime.now())
                .build();

        Set<ConstraintViolation<Client>> violations = validator.validate(client);

        assertThat(violations).isEmpty();
    }

    @Test
    void client_ShouldBeInvalid_WhenNameIsBlank() {
        Client client = Client.builder()
                .name("")
                .email("valid@example.com")
                .password("password123")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .createdAt(LocalDateTime.now())
                .build();

        Set<ConstraintViolation<Client>> violations = validator.validate(client);

        assertThat(violations).isNotEmpty();
        assertThat(violations).anyMatch(v -> v.getPropertyPath().toString().equals("name"));
    }

    @Test
    void client_ShouldBeInvalid_WhenEmailIsInvalid() {
        Client client = Client.builder()
                .name("validuser")
                .email("notanemail")
                .password("password123")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .build();

        Set<ConstraintViolation<Client>> violations = validator.validate(client);

        assertThat(violations).isNotEmpty();
        assertThat(violations).anyMatch(v -> v.getPropertyPath().toString().equals("email"));
    }

    @Test
    void book_ShouldBeValid_WhenAllFieldsCorrect() {
        Book book = Book.builder()
                .title("Valid Book Title")
                .author("Valid Author")
                .isbn("1234567890")
                .year(2024)
                .copiesAvailable(5)
                .available(true)
                .build();

        Set<ConstraintViolation<Book>> violations = validator.validate(book);

        assertThat(violations).isEmpty();
    }

    @Test
    void book_ShouldBeInvalid_WhenTitleIsBlank() {
        Book book = Book.builder()
                .title("")
                .author("Valid Author")
                .isbn("1234567890")
                .year(2024)
                .copiesAvailable(5)
                .available(true)
                .build();

        Set<ConstraintViolation<Book>> violations = validator.validate(book);

        assertThat(violations).isNotEmpty();
        assertThat(violations).anyMatch(v -> v.getPropertyPath().toString().equals("title"));
    }

    @Test
    void room_ShouldBeValid_WhenAllFieldsCorrect() {
        Room room = Room.builder()
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(20)
                .location("Building 1")
                .available(true)
                .build();

        Set<ConstraintViolation<Room>> violations = validator.validate(room);

        assertThat(violations).isEmpty();
    }

    @Test
    void room_ShouldBeInvalid_WhenCapacityIsNegative() {
        Room room = Room.builder()
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(-5)
                .location("Building 1")
                .available(true)
                .build();

        Set<ConstraintViolation<Room>> violations = validator.validate(room);

        assertThat(violations).isNotEmpty();
        assertThat(violations).anyMatch(v -> v.getPropertyPath().toString().equals("capacity"));
    }

    @Test
    void reservation_ShouldBeValid_WhenTimesCorrect() {
        Client client = Client.builder().id(1L).build();
        Room room = Room.builder().id(1L).build();

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.plusHours(2);

        ReservationId id = new ReservationId(1L, endTime);

        Reservation reservation = Reservation.builder()
                .id(id)
                .client(client)
                .resource(room)
                .startTime(startTime)
                .status("ACTIVE")
                .build();

        Set<ConstraintViolation<Reservation>> violations = validator.validate(reservation);

        assertThat(violations).isEmpty();
    }

    @Test
    void reservation_ShouldBeInvalid_WhenEndBeforeStart() {
        Client client = Client.builder().id(1L).build();
        Room room = Room.builder().id(1L).build();

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.minusHours(1); // End before start

        ReservationId id = new ReservationId(1L, endTime);

        Reservation reservation = Reservation.builder()
                .id(id)
                .client(client)
                .resource(room)
                .startTime(startTime)
                .status("ACTIVE")
                .build();

        Set<ConstraintViolation<Reservation>> violations = validator.validate(reservation);

        assertThat(violations).isNotEmpty();
    }

    @Test
    void accountStatus_ShouldHaveCorrectValues() {
        assertThat(AccountStatus.ACTIVE).isNotNull();
        assertThat(AccountStatus.SUSPENDED).isNotNull();
        assertThat(AccountStatus.BLOCKED).isNotNull();
        assertThat(AccountStatus.PENDING).isNotNull();
    }
}