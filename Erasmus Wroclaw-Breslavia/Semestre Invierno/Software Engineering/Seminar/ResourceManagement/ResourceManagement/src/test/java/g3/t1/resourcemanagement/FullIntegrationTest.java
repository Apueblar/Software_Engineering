package g3.t1.resourcemanagement;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.repository.*;
import g3.t1.resourcemanagement.service.*;
import g3.t1.resourcemanagement.web.UserForm;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class FullIntegrationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private ResourceService resourceService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private RoomRepository roomRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    @BeforeEach
    void cleanDatabase() {
        reservationRepository.deleteAll();
        clientRepository.deleteAll();
        bookRepository.deleteAll();
        roomRepository.deleteAll();
    }

    @Test
    void completeUserWorkflow_ShouldWork() {
        UserForm uf = new UserForm();
        uf.setName("integrationuser");
        uf.setEmail("integration@test.com");
        uf.setPassword("password");
        uf.setUserType("CLIENT");
        uf.setClientType("STANDARD");
        uf.setMaxActiveLoans(5);
        uf.setMaxActiveReservations(3);
        uf.setBlockedUntil(null);

        userService.createUserFromForm(uf);

        Optional<User> savedClient = userService.findByEmail("integration@test.com");
        assertThat(savedClient).isPresent();
        assertThat(savedClient.get().getId()).isNotNull();

        List<Client> clients = userService.findAllClients();
        assertThat(clients).hasSize(1);
        assertThat(clients.get(0).getName()).isEqualTo("integrationuser");
    }

    @Test
    void completeResourceWorkflow_ShouldWork() {
        Book book = Book.builder()
                .title("Integration Book")
                .author("Test Author")
                .isbn("9876543210123")
                .year(2024)
                .copiesAvailable(5)
                .available(true)
                .build();

        book = bookRepository.save(book);
        assertThat(book.getId()).isNotNull();

        Room room = Room.builder()
                .roomCode("INT-ROOM")
                .name("Integration Room")
                .capacity(15)
                .location("Test Building")
                .available(true)
                .build();

        room = roomRepository.save(room);
        assertThat(room.getId()).isNotNull();

        List<Resource> resources = resourceService.findAll();
        assertThat(resources).hasSize(2);
    }

    @Test
    void completeReservationWorkflow_ShouldWork() {
        Client client = Client.builder()
                .name("reservationuser")
                .email("reservation@test.com")
                .password("password")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .build();
        client = clientRepository.save(client);

        Room room = Room.builder()
                .roomCode("RES-ROOM")
                .name("Reservation Room")
                .capacity(10)
                .location("Building A")
                .available(true)
                .build();
        room = roomRepository.save(room);

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.plusHours(2);

        ReservationId id = new ReservationId(room.getId(), endTime);

        Reservation reservation = Reservation.builder()
                .id(id)
                .client(client)
                .resource(room)
                .startTime(startTime)
                .status("ACTIVE")
                .build();

        reservation = reservationRepository.save(reservation);
        assertThat(reservation).isNotNull();

        Optional<Reservation> found = reservationService.findById(id);
        assertThat(found).isPresent();
    }

    @Test
    void reservationOverlapDetection_ShouldWork() {
        Client client = Client.builder()
                .name("overlapuser")
                .email("overlap@test.com")
                .password("password")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .build();
        client = clientRepository.save(client);

        Room room = Room.builder()
                .roomCode("OVR-ROOM")
                .name("Overlap Room")
                .capacity(5)
                .location("Building B")
                .available(true)
                .build();
        room = roomRepository.save(room);

        LocalDateTime start1 = LocalDateTime.now().plusDays(1).withHour(10).withMinute(0).withSecond(0).withNano(0);
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

        LocalDateTime start2 = start1.plusHours(1);
        LocalDateTime end2 = start1.plusHours(3);

        List<Reservation> overlapping = reservationRepository
                .findOverlappingActiveReservations(room.getId(), start2, end2);

        assertThat(overlapping).isNotEmpty();

        LocalDateTime start3 = start1.plusHours(3);
        LocalDateTime end3 = start1.plusHours(5);

        List<Reservation> noOverlap = reservationRepository
                .findOverlappingActiveReservations(room.getId(), start3, end3);

        assertThat(noOverlap).isEmpty();
    }

    @Test
    void cascadeDelete_ShouldWork() {
        Client client = Client.builder()
                .name("deleteuser")
                .email("delete@test.com")
                .password("password")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .build();
        client = clientRepository.save(client);

        Book book = Book.builder()
                .title("Delete Book")
                .author("Author")
                .isbn("1234567890124")
                .year(2024)
                .copiesAvailable(1)
                .available(true)
                .build();
        book = bookRepository.save(book);

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

        assertThat(reservationRepository.findAll()).hasSize(1);

        userService.deleteUser(client.getId());

        assertThat(clientRepository.findById(client.getId())).isEmpty();
    }

    @Test
    void multipleClientsAndResources_ShouldWork() {
        for (int i = 1; i <= 3; i++) {
            Client client = Client.builder()
                    .name("user" + i)
                    .email("user" + i + "@test.com")
                    .password("password" + i)
                    .accountStatus(AccountStatus.ACTIVE)
                    .clientType("STANDARD")
                    .maxActiveLoans(5)
                    .maxActiveReservations(3)
                    .build();
            clientRepository.save(client);
        }

        for (int i = 1; i <= 2; i++) {
            Book book = Book.builder()
                    .title("Book " + i)
                    .author("Author " + i)
                    .isbn("123456789012" + i)
                    .year(2024)
                    .copiesAvailable(5)
                    .available(true)
                    .build();
            bookRepository.save(book);
        }

        for (int i = 1; i <= 2; i++) {
            Room room = Room.builder()
                    .roomCode("ROOM-" + i)
                    .name("Room " + i)
                    .capacity(10 * i)
                    .location("Location " + i)
                    .available(true)
                    .build();
            roomRepository.save(room);
        }

        assertThat(userService.findAllClients()).hasSize(3);
        assertThat(resourceService.findAll()).hasSize(4);
    }
}