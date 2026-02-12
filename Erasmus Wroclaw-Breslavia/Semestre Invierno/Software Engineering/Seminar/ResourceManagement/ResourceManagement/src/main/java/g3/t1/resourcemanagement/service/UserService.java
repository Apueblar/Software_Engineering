package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.AccountStatus;
import g3.t1.resourcemanagement.entity.Admin;
import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.User;
import g3.t1.resourcemanagement.repository.AdminRepository;
import g3.t1.resourcemanagement.repository.ClientRepository;
import g3.t1.resourcemanagement.repository.UserRepository;
import g3.t1.resourcemanagement.web.UserForm;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

	private final UserRepository userRepository;
	private final ClientRepository clientRepository;
	private final AdminRepository adminRepository;
	private final PasswordEncoder passwordEncoder;

	public List<User> findAll() {
		return userRepository.findAll();
	}

	public Optional<User> findByEmail(String email) {
		return userRepository.findByEmail(email);
	}

	public Optional<User> findById(Long id) {
		return userRepository.findById(id);
	}

	public List<Client> findAllClients() {
		return clientRepository.findAll();
	}

	@Transactional
	public void createUserFromForm(UserForm form) {
		// Validate required fields
		if (form.getName() == null || form.getName().isBlank()) {
			throw new IllegalArgumentException("Name is required");
		}

		if (form.getEmail() == null || form.getEmail().isBlank()) {
			throw new IllegalArgumentException("Email is required");
		}

		if (form.getPassword() == null || form.getPassword().isBlank()) {
			throw new IllegalArgumentException("Password is required");
		}

		// Check for existing email
		Optional<User> existing = userRepository.findByEmail(form.getEmail().trim());
		if (existing.isPresent()) {
			throw new IllegalArgumentException("Email already in use");
		}

		String encoded = passwordEncoder.encode(form.getPassword());
		String fullName = form.getName().trim();

		if ("ADMIN".equalsIgnoreCase(form.getUserType())) {
			Admin admin = createAdmin(form, fullName, encoded);
			adminRepository.save(admin);
		} else if ("CLIENT".equalsIgnoreCase(form.getUserType())) {
			Client client = createClient(form, fullName, encoded);
			clientRepository.save(client);
		} else {
			throw new IllegalArgumentException("Invalid user type");
		}
	}

	@Transactional
	public void blockUser(Long userId, java.time.LocalDate blockedUntil) {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new IllegalArgumentException("User not found"));

		if (user instanceof Client) {
			Client client = (Client) user;
			client.setBlockedUntil(blockedUntil);
			clientRepository.save(client);
		} else {
			throw new IllegalArgumentException("Only clients can be blocked");
		}
	}

	@Transactional
	public void unblockUser(Long userId) {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new IllegalArgumentException("User not found"));

		if (user instanceof Client) {
			Client client = (Client) user;
			client.setBlockedUntil(null);
			clientRepository.save(client);
		}
	}

	@Transactional
	public void deleteUser(Long userId) {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new IllegalArgumentException("User not found"));

		// Optional: Check if user has active reservations
		if (user instanceof Client) {
			Client client = (Client) user;
			// You might want to check for active reservations here
			// and either prevent deletion or handle them appropriately
		}

		userRepository.delete(user);
	}

	private Client createClient(UserForm form, String fullName, String encoded) {
		Client client = new Client();
		client.setName(fullName);
		client.setEmail(form.getEmail().trim());
		client.setPassword(encoded);
		client.setAccountStatus(AccountStatus.ACTIVE);
		client.setClientType(form.getClientType() != null ? form.getClientType() : "STANDARD");
		client.setMaxActiveLoans(form.getMaxActiveLoans() != null ? form.getMaxActiveLoans() : 5);
		client.setMaxActiveReservations(form.getMaxActiveReservations() != null ? form.getMaxActiveReservations() : 3);
		client.setBlockedUntil(form.getBlockedUntil());
		return client;
	}

	private Admin createAdmin(UserForm form, String fullName, String encoded) {
		Admin admin = new Admin();
		admin.setName(fullName);
		admin.setEmail(form.getEmail().trim());
		admin.setPassword(encoded);
		admin.setAccountStatus(AccountStatus.ACTIVE);
		admin.setAdminLevel(form.getAdminLevel() != null ? form.getAdminLevel() : 1);
		admin.setActive(form.getAdminActive() != null ? form.getAdminActive() : Boolean.TRUE);
		admin.setDepartmentId(form.getDepartmentId());
		admin.setEmployeeCode(form.getEmployeeCode());
		return admin;
	}
}