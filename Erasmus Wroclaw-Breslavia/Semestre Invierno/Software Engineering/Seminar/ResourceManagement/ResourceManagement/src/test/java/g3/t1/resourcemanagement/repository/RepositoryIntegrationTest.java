package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class RepositoryIntegrationTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private RoomRepository roomRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    @Test
    void userRepository_FindByEmail_ShouldWork() {
        Optional<User> found = userRepository.findByEmail("alvaropueblaruisanchezclient@gmail.com");

        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("alvaropueblaruisanchezclient@gmail.com");
    }

    @Test
    void clientRepository_SaveAndFind_ShouldWork() {
        List<Client> clients = clientRepository.findAll();

        assertThat(clients).hasSize(1);
        assertThat(clients.get(0).getName()).isEqualTo("Client User");
    }

    @Test
    void adminRepository_SaveAndFind_ShouldWork() {
        List<Admin> admins = adminRepository.findAll();

        assertThat(admins).hasSize(1);
        assertThat(admins.get(0).getName()).isEqualTo("Admin User");
    }

    @Test
    void bookRepository_FindByIsbn_ShouldWork() {
        Optional<Book> book = bookRepository.findByIsbn("9780132350884");

        assertThat(book).isPresent();
        assertThat(book.get().getTitle()).isEqualTo("Clean Code");
    }

    @Test
    void roomRepository_FindByRoomCode_ShouldWork() {
        Optional<Room> room = roomRepository.findByRoomCode("RM101");

        assertThat(room).isPresent();
        assertThat(room.get().getName()).isEqualTo("Conference Room A");
    }

    @Test
    void reservationRepository_SaveAndFind_ShouldWork() {
        Client client = clientRepository.findAll().getFirst();
        Book book = bookRepository.findByIsbn("9780132350884").get();

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.plusHours(2);

        ReservationId id = new ReservationId(book.getId(), endTime);

        Reservation reservation = Reservation.builder()
                .id(id)
                .client(client)
                .resource(book)
                .startTime(startTime)
                .status("ACTIVE")
                .build();

        reservation = reservationRepository.save(reservation);

        List<Reservation> reservations = reservationRepository.findAll();
        assertThat(reservations).hasSize(1);
    }

    @Test
    void reservationRepository_FindOverlapping_ShouldWork() {
        Client client = clientRepository.findAll().get(0);
        Room room = roomRepository.findByRoomCode("RM101").get();

        LocalDateTime start1 = LocalDateTime.now().plusDays(1);
        LocalDateTime end1 = start1.plusHours(2);

        ReservationId id1 = new ReservationId(room.getId(), end1);

        Reservation res1 = Reservation.builder()
                .id(id1)
                .client(client)
                .resource(room)
                .startTime(start1)
                .status("ACTIVE")
                .build();
        reservationRepository.save(res1);

        LocalDateTime checkStart = start1.plusHours(1);
        LocalDateTime checkEnd = start1.plusHours(3);

        List<Reservation> overlapping = reservationRepository.findOverlappingActiveReservations(
                room.getId(), checkStart, checkEnd
        );

        assertThat(overlapping).hasSize(1);
    }

    @Test
    void reservationRepository_FindByClientId_ShouldWork() {
        Client client = clientRepository.findAll().get(0);
        Book book = bookRepository.findByIsbn("9780132350884").get();

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.plusHours(1);

        ReservationId id = new ReservationId(book.getId(), endTime);

        Reservation reservation = Reservation.builder()
                .id(id)
                .client(client)
                .resource(book)
                .startTime(startTime)
                .status("ACTIVE")
                .build();
        reservationRepository.save(reservation);

        List<Reservation> clientReservations = reservationRepository.findByClientId(client.getId());

        assertThat(clientReservations).hasSize(1);
        assertThat(clientReservations.get(0).getClient().getName()).isEqualTo("Client User");
    }

    @Test
    void resourceRepository_DeleteCascade_ShouldWork() {
        Book book = bookRepository.findByIsbn("9780134685991").get();
        Long bookId = book.getId();

        bookRepository.deleteById(bookId);

        Optional<Book> deleted = bookRepository.findById(bookId);
        assertThat(deleted).isEmpty();
    }
}