package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.service.ReservationService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
import g3.t1.resourcemanagement.web.ReservationForm;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ResourceControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ResourceService resourceService;

    @MockBean
    private ReservationService reservationService;

    @MockBean
    private UserService userService;

    private Room testRoom;
    private Book testBook;
    private Client testClient;
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @BeforeEach
    void setUp() {
        testRoom = Room.builder()
                .id(1L)
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(10)
                .location("Building 1")
                .build();

        testBook = Book.builder()
                .id(2L)
                .title("Test Book")
                .author("Author")
                .isbn("1234567890123")
                .year(2024)
                .copiesAvailable(5)
                .build();

        testClient = Client.builder()
                .id(1L)
                .name("Client User")
                .email("alvaropueblaruisanchezclient@gmail.com")
                .build();
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void viewResource_ShouldShowResourceDetail() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findById(1L)).thenReturn(testRoom);
        when(reservationService.findOverlappingActiveReservations(any(), any(), any()))
                .thenReturn(Arrays.asList());

        mockMvc.perform(get("/resources/1"))
                .andExpect(status().isOk())
                .andExpect(view().name("resource"))
                .andExpect(model().attribute("resource", testRoom));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void viewResource_ShouldRedirect_WhenNotExists() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findById(999L))
                .thenThrow(new IllegalArgumentException("Resource not found"));

        mockMvc.perform(get("/resources/999"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/?notfound"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void createReservation_ShouldCreateAndRedirect() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com"))
                .thenReturn(Optional.of(testClient));
        when(resourceService.findById(1L)).thenReturn(testRoom);
        when(reservationService.createReservationFromForm(any(), any(), any()))
                .thenReturn(new Reservation());

        // Use future dates
        LocalDateTime futureStart = LocalDateTime.now().plusDays(1).withHour(10).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime futureEnd = futureStart.plusHours(2);

        mockMvc.perform(post("/resources/1/reserve")
                        .with(csrf())
                        .param("startTime", futureStart.format(FORMATTER))
                        .param("endTime", futureEnd.format(FORMATTER)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/?reserved"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void cancelReservation_ShouldCancelSuccessfully() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        LocalDateTime endTime = LocalDateTime.now().plusDays(1).withHour(15).withMinute(0).withSecond(0).withNano(0);

        // Format the datetime properly for URL (Spring will handle the conversion)
        String formattedEndTime = endTime.format(FORMATTER);

        mockMvc.perform(post("/resources/1/" + formattedEndTime + "/cancel")
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"));

        verify(reservationService, times(1)).cancelReservation(any());
    }

    @Test
    void viewResource_ShouldRedirectToLogin_WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/resources/1"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));
    }
}