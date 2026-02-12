package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.repository.AdminRepository;
import g3.t1.resourcemanagement.repository.ClientRepository;
import g3.t1.resourcemanagement.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private ClientRepository clientRepository;

    @Mock
    private AdminRepository adminRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private Client testClient;
    private Admin testAdmin;

    @BeforeEach
    void setUp() {
        testClient = new Client();
        testClient.setId(1L);
        testClient.setName("testuser");
        testClient.setEmail("test@example.com");
        testClient.setPassword("encodedPassword");
        testClient.setAccountStatus(AccountStatus.ACTIVE);
        testClient.setClientType("STANDARD");
        testClient.setMaxActiveLoans(5);
        testClient.setMaxActiveReservations(3);

        testAdmin = new Admin();
        testAdmin.setId(2L);
        testAdmin.setName("admin");
        testAdmin.setEmail("admin@example.com");
        testAdmin.setPassword("encodedPassword");
        testAdmin.setAccountStatus(AccountStatus.ACTIVE);
        testAdmin.setAdminLevel(1);
        testAdmin.setActive(true);
        testAdmin.setDepartmentId(1L);
        testAdmin.setEmployeeCode("ADM001");
    }

    @Test
    void findByEmail_ShouldReturnUser_WhenExists() {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testClient));

        Optional<User> result = userService.findByEmail("test@example.com");

        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo("test@example.com");
        verify(userRepository, times(1)).findByEmail("test@example.com");
    }

    @Test
    void findByEmail_ShouldReturnEmpty_WhenNotExists() {
        when(userRepository.findByEmail("nonexistent@example.com")).thenReturn(Optional.empty());

        Optional<User> result = userService.findByEmail("nonexistent@example.com");

        assertThat(result).isEmpty();
        verify(userRepository, times(1)).findByEmail("nonexistent@example.com");
    }

    @Test
    void findAllClients_ShouldReturnAllClients() {
        Client client2 = new Client();
        client2.setId(3L);
        client2.setName("client2");

        when(clientRepository.findAll()).thenReturn(Arrays.asList(testClient, client2));

        List<Client> result = userService.findAllClients();

        assertThat(result).hasSize(2);
        assertThat(result).contains(testClient, client2);
        verify(clientRepository, times(1)).findAll();
    }

    @Test
    void findById_ShouldReturnUser_WhenExists() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testClient));

        Optional<User> result = userService.findById(1L);

        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo(1L);
        verify(userRepository, times(1)).findById(1L);
    }

    @Test
    void deleteUser_ShouldCallRepository() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testClient));
        doNothing().when(userRepository).delete(testClient);

        userService.deleteUser(1L);

        verify(userRepository, times(1)).findById(1L);
        verify(userRepository, times(1)).delete(testClient);
    }
}