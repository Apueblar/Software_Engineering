package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.repository.ClientRepository;
import g3.t1.resourcemanagement.repository.ReservationRepository;
import g3.t1.resourcemanagement.repository.ResourceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReservationServiceTest {

    @Mock
    private ReservationRepository reservationRepository;

    @Mock
    private ResourceRepository resourceRepository;

    @Mock
    private ClientRepository clientRepository;

    @InjectMocks
    private ReservationService reservationService;

    private Reservation testReservation;
    private Client testClient;
    private Room testRoom;

    @BeforeEach
    void setUp() {
        testClient = Client.builder()
                .id(1L)
                .name("testuser")
                .email("test@example.com")
                .accountStatus(AccountStatus.ACTIVE)
                .clientType("STANDARD")
                .maxActiveLoans(5)
                .maxActiveReservations(3)
                .build();

        testRoom = Room.builder()
                .id(1L)
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(10)
                .location("Building 1")
                .build();

        LocalDateTime startTime = LocalDateTime.now().plusDays(1);
        LocalDateTime endTime = startTime.plusHours(2);

        ReservationId id = new ReservationId(1L, endTime);

        testReservation = Reservation.builder()
                .id(id)
                .client(testClient)
                .resource(testRoom)
                .startTime(startTime)
                .status("ACTIVE")
                .build();
    }

    @Test
    void findAll_ShouldReturnAllReservations() {
        when(reservationRepository.findAll()).thenReturn(Arrays.asList(testReservation));

        List<Reservation> result = reservationService.findAll();

        assertThat(result).hasSize(1);
        assertThat(result.get(0)).isEqualTo(testReservation);
        verify(reservationRepository, times(1)).findAll();
    }

    @Test
    void findById_ShouldReturnReservation_WhenExists() {
        ReservationId id = testReservation.getId();
        when(reservationRepository.findById(id)).thenReturn(Optional.of(testReservation));

        Optional<Reservation> result = reservationService.findById(id);

        assertThat(result).isPresent();
        assertThat(result.get()).isEqualTo(testReservation);
        verify(reservationRepository, times(1)).findById(id);
    }

    @Test
    void createReservation_ShouldSaveReservation_WhenValid() {
        when(resourceRepository.findById(1L)).thenReturn(Optional.of(testRoom));
        when(clientRepository.findById(1L)).thenReturn(Optional.of(testClient));
        when(reservationRepository.findOverlappingActiveReservations(any(), any(), any()))
                .thenReturn(Arrays.asList());
        when(reservationRepository.countActiveReservationsByClient(1L)).thenReturn(0L);
        when(reservationRepository.findReservationsByResourceIdAndEnd(any(), any()))
                .thenReturn(Optional.empty());
        when(reservationRepository.save(any(Reservation.class))).thenReturn(testReservation);

        Reservation result = reservationService.createReservation(testReservation);

        assertThat(result).isNotNull();
        verify(reservationRepository, times(1)).save(any(Reservation.class));
    }

    @Test
    void cancelReservation_ShouldUpdateStatus() {
        ReservationId id = testReservation.getId();
        when(reservationRepository.findById(id)).thenReturn(Optional.of(testReservation));
        when(reservationRepository.save(any(Reservation.class))).thenReturn(testReservation);

        reservationService.cancelReservation(id);

        verify(reservationRepository, times(1)).findById(id);
        verify(reservationRepository, times(1)).save(any(Reservation.class));
        assertThat(testReservation.getStatus()).isEqualTo("CANCELLED");
    }

    @Test
    void findActiveReservationsByClientId_ShouldReturnActiveReservations() {
        when(reservationRepository.findActiveReservationsByClient(any(), any()))
                .thenReturn(Arrays.asList(testReservation));

        List<Reservation> result = reservationService.findActiveReservationsByClientId(1L);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getStatus()).isEqualTo("ACTIVE");
    }
}