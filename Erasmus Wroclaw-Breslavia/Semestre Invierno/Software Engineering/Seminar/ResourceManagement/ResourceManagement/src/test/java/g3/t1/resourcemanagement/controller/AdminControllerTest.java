package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.*;
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
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private ResourceService resourceService;

    @MockBean
    private ReservationService reservationService;

    private Client testClient;
    private Admin testAdmin;
    private Book testBook;
    private Room testRoom;

    @BeforeEach
    void setUp() {
        testClient = Client.builder()
                .id(1L)
                .name("client1")
                .email("client1@example.com")
                .build();

        testAdmin = Admin.builder()
                .id(2L)
                .name("admin")
                .email("alvaropueblaruisanchez@gmail.com")
                .build();

        testBook = Book.builder()
                .id(1L)
                .title("Book 1")
                .author("Author 1")
                .isbn("1234567890123")
                .year(2024)
                .copiesAvailable(5)
                .build();

        testRoom = Room.builder()
                .id(2L)
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(10)
                .location("Building 1")
                .build();
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void dashboard_ShouldShowDashboard() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        when(userService.findAll()).thenReturn(Arrays.asList(testClient, testAdmin));
        when(resourceService.findAll()).thenReturn(Arrays.asList(testBook, testRoom));
        when(reservationService.findAll()).thenReturn(Arrays.asList());

        mockMvc.perform(get("/admin"))
                .andExpect(status().isOk())
                .andExpect(view().name("admin/dashboard"))
                .andExpect(model().attributeExists("users", "resources", "reservations"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void dashboard_ShouldDenyAccess_ForNonAdmin() throws Exception {
        mockMvc.perform(get("/admin"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void showUserForm_ShouldShowForm_ForNewUser() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        mockMvc.perform(get("/admin/users/new"))
                .andExpect(status().isOk())
                .andExpect(view().name("admin/user_form"))
                .andExpect(model().attributeExists("userForm"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void createUser_ShouldCreateClientSuccessfully() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        doNothing().when(userService).createUserFromForm(any());

        mockMvc.perform(post("/admin/users")
                        .with(csrf())
                        .param("name", "newclient")
                        .param("email", "new@example.com")
                        .param("password", "password123")
                        .param("userType", "CLIENT")
                        .param("clientType", "STANDARD")
                        .param("maxActiveLoans", "5")
                        .param("maxActiveReservations", "3"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/admin?userCreated"));

        verify(userService, times(1)).createUserFromForm(any());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void deleteUser_ShouldDeleteUserSuccessfully() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        doNothing().when(userService).deleteUser(1L);

        mockMvc.perform(post("/admin/users/1/delete")
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/admin?userDeleted"));

        verify(userService, times(1)).deleteUser(1L);
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void listResources_ShouldShowAllResources() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        when(resourceService.findAll()).thenReturn(Arrays.asList(testBook, testRoom));

        mockMvc.perform(get("/admin/resources"))
                .andExpect(status().isOk())
                .andExpect(view().name("admin/resources"))
                .andExpect(model().attributeExists("resources"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void showResourceForm_ShouldShowForm_ForNewResource() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        mockMvc.perform(get("/admin/resources/new"))
                .andExpect(status().isOk())
                .andExpect(view().name("admin/resource_form"))
                .andExpect(model().attributeExists("resourceForm"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void createResource_ShouldCreateBookSuccessfully() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        doNothing().when(resourceService).createResourceFromForm(any());

        mockMvc.perform(post("/admin/resources")
                        .with(csrf())
                        .param("resourceType", "BOOK")
                        .param("title", "New Book")
                        .param("author", "Author Name")
                        .param("isbn", "1234567890124")
                        .param("year", "2024")
                        .param("copiesAvailable", "5"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/admin/resources?created"));

        verify(resourceService, times(1)).createResourceFromForm(any());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void deleteResource_ShouldDeleteSuccessfully() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));
        doNothing().when(resourceService).deleteById(1L);

        mockMvc.perform(post("/admin/resources/1/delete")
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/admin/resources?deleted"));

        verify(resourceService, times(1)).deleteById(1L);
    }

    @Test
    void dashboard_ShouldRedirectToLogin_WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/admin"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));
    }
}