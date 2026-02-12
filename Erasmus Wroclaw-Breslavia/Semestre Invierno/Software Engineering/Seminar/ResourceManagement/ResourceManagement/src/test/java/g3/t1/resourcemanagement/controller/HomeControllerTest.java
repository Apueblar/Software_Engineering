package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.Reservation;
import g3.t1.resourcemanagement.entity.ReservationId;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.entity.Room;
import g3.t1.resourcemanagement.service.ReservationService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
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

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class HomeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private ResourceService resourceService;

    @MockBean
    private ReservationService reservationService;

    private Client testClient;
    private Resource testResource;
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @BeforeEach
    void setUp() {
        testClient = new Client();
        testClient.setId(1L);
        testClient.setEmail("alvaropueblaruisanchezclient@gmail.com");
        testClient.setName("Client User");

        // Create a test resource for reservations
        testResource = Room.builder()
                .id(201L)
                .roomCode("RM101")
                .name("Conference Room A")
                .capacity(20)
                .location("Building 1, Floor 2")
                .available(true)
                .build();
    }

    @Test
    void index_ShouldRedirectToLogin_WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void index_ShouldShowHomePage_WhenAuthenticatedAsClient() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findAll()).thenReturn(Arrays.asList());
        when(reservationService.findActiveReservationsByClientId(anyLong())).thenReturn(Arrays.asList());

        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attributeExists("resources"))
                .andExpect(model().attributeExists("userReservations"))
                .andExpect(model().attribute("userType", "client"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void index_ShouldShowHomePage_WhenAuthenticatedAsAdmin() throws Exception {
        var admin = new g3.t1.resourcemanagement.entity.Admin();
        admin.setId(2L);
        admin.setEmail("alvaropueblaruisanchez@gmail.com");
        admin.setName("Admin User");

        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(admin));
        when(resourceService.findAll()).thenReturn(Arrays.asList());

        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attributeExists("resources"))
                .andExpect(model().attribute("userType", "admin"));
    }

    @Test
    void login_ShouldShowLoginPage() throws Exception {
        mockMvc.perform(get("/login"))
                .andExpect(status().isOk())
                .andExpect(view().name("login"))
                .andExpect(model().attribute("page", "login"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void index_ShouldDisplayUserReservations_WhenClientHasReservations() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findAll()).thenReturn(Arrays.asList());

        // Create a properly initialized reservation with resource AND ReservationId
        LocalDateTime endTime = LocalDateTime.now().plusDays(1).plusHours(2);
        ReservationId reservationId = new ReservationId(testResource.getId(), endTime);

        Reservation reservation = new Reservation();
        reservation.setId(reservationId);  // Set the composite ID
        reservation.setResource(testResource);
        reservation.setClient(testClient);
        reservation.setStartTime(LocalDateTime.now().plusDays(1));
        reservation.setStatus("ACTIVE");
        reservation.setNotes("Test reservation");

        when(reservationService.findActiveReservationsByClientId(1L))
                .thenReturn(Arrays.asList(reservation));

        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attributeExists("userReservations"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void index_ShouldHandleResourceFiltering_WhenTimeParametersProvided() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findAll()).thenReturn(Arrays.asList());
        when(reservationService.findActiveReservationsByClientId(anyLong())).thenReturn(Arrays.asList());

        // Use future dates relative to now
        LocalDateTime futureStart = LocalDateTime.now().plusDays(1).withHour(10).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime futureEnd = futureStart.plusHours(2);

        mockMvc.perform(get("/")
                        .param("startTime", futureStart.format(FORMATTER))
                        .param("endTime", futureEnd.format(FORMATTER)))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attributeExists("startTime"))
                .andExpect(model().attributeExists("endTime"))
                .andExpect(model().attribute("startTime", futureStart))
                .andExpect(model().attribute("endTime", futureEnd));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void index_ShouldNullifyPastDates_WhenPastTimeParametersProvided() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findAll()).thenReturn(Arrays.asList());
        when(reservationService.findActiveReservationsByClientId(anyLong())).thenReturn(Arrays.asList());

        // Use past dates
        LocalDateTime pastStart = LocalDateTime.now().minusDays(1).withHour(10).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime pastEnd = pastStart.plusHours(2);

        mockMvc.perform(get("/")
                        .param("startTime", pastStart.format(FORMATTER))
                        .param("endTime", pastEnd.format(FORMATTER)))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attribute("startTime", (Object) null))
                .andExpect(model().attribute("endTime", (Object) null));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void index_ShouldNullifyEndTime_WhenEndTimeBeforeStartTime() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));
        when(resourceService.findAll()).thenReturn(Arrays.asList());
        when(reservationService.findActiveReservationsByClientId(anyLong())).thenReturn(Arrays.asList());

        // Use future start but end before start
        LocalDateTime futureStart = LocalDateTime.now().plusDays(1).withHour(12).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime invalidEnd = futureStart.minusHours(1);

        mockMvc.perform(get("/")
                        .param("startTime", futureStart.format(FORMATTER))
                        .param("endTime", invalidEnd.format(FORMATTER)))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attribute("startTime", futureStart))
                .andExpect(model().attribute("endTime", (Object) null));
    }
}