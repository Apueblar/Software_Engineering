package g3.t1.resourcemanagement.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithAnonymousUser;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestBuilders.formLogin;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestBuilders.logout;
import static org.springframework.security.test.web.servlet.response.SecurityMockMvcResultMatchers.authenticated;
import static org.springframework.security.test.web.servlet.response.SecurityMockMvcResultMatchers.unauthenticated;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithAnonymousUser
    void publicEndpoints_ShouldBeAccessible_WithoutAuthentication() throws Exception {
        mockMvc.perform(get("/login"))
                .andExpect(status().isOk());
    }

    @Test
    @WithAnonymousUser
    void protectedEndpoints_ShouldRedirectToLogin() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));

        mockMvc.perform(get("/resources"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/login"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void clientEndpoints_ShouldBeAccessible_WithClientRole() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void adminEndpoints_ShouldBeForbidden_ForClient() throws Exception {
        mockMvc.perform(get("/admin"))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/admin/users/new"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void adminEndpoints_ShouldBeAccessible_WithAdminRole() throws Exception {
        mockMvc.perform(get("/admin"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/admin/users/new"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com")
    void logout_ShouldLogoutUser() throws Exception {
        mockMvc.perform(logout())
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/login?logout"))
                .andExpect(unauthenticated());
    }

    @Test
    void login_WithValidCredentials_ShouldAuthenticate() throws Exception {
        mockMvc.perform(formLogin("/login")
                        .user("username", "alvaropueblaruisanchezclient@gmail.com")
                        .password("password", "goodlifegoodlife73"))
                .andExpect(status().is3xxRedirection());
    }

    @Test
    void login_WithInvalidCredentials_ShouldFail() throws Exception {
        mockMvc.perform(formLogin("/login")
                        .user("username", "invaliduser@test.com")
                        .password("password", "wrongpass"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/login?error"))
                .andExpect(unauthenticated());
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchezclient@gmail.com", roles = {"CLIENT"})
    void authenticatedUser_ShouldHaveCorrectAuthorities() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(authenticated().withUsername("alvaropueblaruisanchezclient@gmail.com"))
                .andExpect(authenticated().withRoles("CLIENT"));
    }

    @Test
    @WithMockUser(username = "alvaropueblaruisanchez@gmail.com", roles = {"ADMIN"})
    void adminUser_ShouldHaveAdminAuthorities() throws Exception {
        mockMvc.perform(get("/admin/dashboard"))
                .andExpect(authenticated().withUsername("alvaropueblaruisanchez@gmail.com"))
                .andExpect(authenticated().withRoles("ADMIN"));
    }
}