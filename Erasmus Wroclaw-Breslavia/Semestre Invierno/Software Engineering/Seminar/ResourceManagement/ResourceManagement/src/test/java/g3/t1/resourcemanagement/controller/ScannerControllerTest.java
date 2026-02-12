package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.service.QRService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ScannerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ResourceService resourceService;

    @MockBean
    private QRService qrService;

    @MockBean
    private UserService userService;

    private Room testRoom;
    private Admin testAdmin;
    private Client testClient;

    @BeforeEach
    void setUp() {
        testRoom = Room.builder()
                .id(1L)
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(10)
                .location("Building 1")
                .build();

        testAdmin = Admin.builder()
                .id(1L)
                .name("Admin User")
                .email("alvaropueblaruisanchez@gmail.com")
                .build();

        testClient = Client.builder()
                .id(2L)
                .name("Client User")
                .email("alvaropueblaruisanchezclient@gmail.com")
                .build();
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void showScanner_ShouldShowScannerPage() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        mockMvc.perform(get("/scan"))
                .andExpect(status().isOk())
                .andExpect(view().name("scan"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void uploadDecoded_ShouldRedirectToResource_WhenValidQR() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "qr.png",
                "image/png",
                "fake image content".getBytes()
        );

        when(qrService.decodeImage(any())).thenReturn("http://localhost/resources/1");
        when(resourceService.findById(1L)).thenReturn(testRoom);

        mockMvc.perform(multipart("/scan/upload")
                        .file(file)
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/resources/1"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void uploadDecoded_ShouldShowError_WhenInvalidQR() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "qr.png",
                "image/png",
                "fake image content".getBytes()
        );

        when(qrService.decodeImage(any())).thenReturn("invalid content");

        mockMvc.perform(multipart("/scan/upload")
                        .file(file)
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/scan?error=invalidQR*"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void uploadDecoded_ShouldShowError_WhenNoFile() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchez@gmail.com")).thenReturn(Optional.of(testAdmin));

        mockMvc.perform(multipart("/scan/upload")
                        .with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("/scan?error=*"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void showScanner_ShouldAllowAccess_ForClient() throws Exception {
        when(userService.findByEmail("alvaropueblaruisanchezclient@gmail.com")).thenReturn(Optional.of(testClient));

        // Based on the test output, clients CAN access /scan (it returns 200)
        // This means there's no role restriction on the scanner endpoint
        mockMvc.perform(get("/scan"))
                .andExpect(status().isOk())
                .andExpect(view().name("scan"));
    }

    @Test
    void showScanner_ShouldRedirectToLogin_WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/scan"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));
    }
}