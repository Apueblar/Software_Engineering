package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.*;
import g3.t1.resourcemanagement.service.ReservationService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
import g3.t1.resourcemanagement.web.AdminReservationForm;
import g3.t1.resourcemanagement.web.ResourceForm;
import g3.t1.resourcemanagement.web.UserForm;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.transaction.annotation.Transactional;
import org.hibernate.Hibernate;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
	private final UserService userService;
	private final ResourceService resourceService;
	private final ReservationService reservationService;

	@GetMapping("")
	public String dashboard(Model model) {
		model.addAttribute("users", userService.findAll());
		model.addAttribute("resources", resourceService.findAll());
		model.addAttribute("reservations", reservationService.findAll());
		model.addAttribute("page", "admin");
		return "admin/dashboard";
	}

	// ========== USER MANAGEMENT ==========

	@GetMapping("/users/new")
	public String newUserForm(Model m) {
		m.addAttribute("userForm", new UserForm());
		m.addAttribute("page", "admin");
		return "admin/user_form";
	}

	@PostMapping("/users")
	public String createUser(@ModelAttribute("userForm") @Valid UserForm form,
							 BindingResult br,
							 Model model,
							 RedirectAttributes redirectAttributes) {
		model.addAttribute("page", "admin");

		if (br.hasErrors()) {
			return "admin/user_form";
		}

		try {
			userService.createUserFromForm(form);
			redirectAttributes.addFlashAttribute("page", "admin");
			return "redirect:/admin?userCreated";
		} catch (IllegalArgumentException ex) {
			br.reject("user.error", ex.getMessage());
			return "admin/user_form";
		}
	}

	@PostMapping("/users/{id}/block")
	public String blockUser(@PathVariable Long id,
							@RequestParam("blockedUntil") String blockedUntilStr,
							RedirectAttributes redirectAttributes) {
		redirectAttributes.addFlashAttribute("page", "admin");

		try {
			java.time.LocalDate blockedUntil = java.time.LocalDate.parse(blockedUntilStr);
			userService.blockUser(id, blockedUntil);
			return "redirect:/admin?userBlocked";
		} catch (IllegalArgumentException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin?error&message=" + ex.getMessage();
		}
	}

	@PostMapping("/users/{id}/unblock")
	public String unblockUser(@PathVariable Long id, RedirectAttributes redirectAttributes) {
		redirectAttributes.addFlashAttribute("page", "admin");

		try {
			userService.unblockUser(id);
			return "redirect:/admin?userUnblocked";
		} catch (IllegalArgumentException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin?error&message=" + ex.getMessage();
		}
	}

	@PostMapping("/users/{id}/delete")
	public String deleteUser(@PathVariable Long id,
							 RedirectAttributes redirectAttributes,
							 java.security.Principal principal) {
		redirectAttributes.addFlashAttribute("page", "admin");

		try {
			// Prevent admin from deleting themselves
			var currentUser = userService.findByEmail(principal.getName());
			if (currentUser.isPresent() && currentUser.get().getId().equals(id)) {
				redirectAttributes.addFlashAttribute("error", "You cannot delete your own account");
				return "redirect:/admin?error&message=Cannot+delete+yourself";
			}

			userService.deleteUser(id);
			return "redirect:/admin?userDeleted";
		} catch (IllegalArgumentException | IllegalStateException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin?error&message=" + ex.getMessage();
		}
	}

	// ========== RESERVATION MANAGEMENT ==========

	@GetMapping("/reservations/new")
	public String newReservationForm(Model m) {
		m.addAttribute("resources", resourceService.findAll());
		m.addAttribute("users", userService.findAllClients());
		m.addAttribute("reservationForm", new AdminReservationForm());
		m.addAttribute("page", "admin");
		return "admin/reservation_form";
	}

	@PostMapping("/reservations")
	public String createReservation(@ModelAttribute("reservationForm") @Valid AdminReservationForm form,
									BindingResult br,
									Model model,
									RedirectAttributes redirectAttributes,
									Authentication authentication) {
		// Repopulate lists for redisplay on error
		model.addAttribute("resources", resourceService.findAll());
		model.addAttribute("users", userService.findAllClients());
		model.addAttribute("page", "admin");

		if (br.hasErrors()) {
			return "admin/reservation_form";
		}

		try {
			// Get the current admin user
			String username = authentication.getName();
			User currentUser = userService.findByEmail(username)
					.orElseThrow(() -> new IllegalArgumentException("Admin user not found"));

			if (!(currentUser instanceof Admin)) {
				br.reject("reservation.error", "Only admins can create reservations on behalf of users");
				return "admin/reservation_form";
			}

			Admin admin = (Admin) currentUser;
			reservationService.createReservationFromForm(form, admin);
			redirectAttributes.addFlashAttribute("page", "admin");
			return "redirect:/admin?reservationCreated";
		} catch (IllegalArgumentException | IllegalStateException ex) {
			br.reject("reservation.error", ex.getMessage());
			return "admin/reservation_form";
		}
	}

	@PostMapping("/reservations/{resourceId}/{endTime}/cancel")
	public String cancelReservation(@PathVariable Long resourceId,
									@PathVariable @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") java.time.LocalDateTime endTime,
									RedirectAttributes redirectAttributes) {
		redirectAttributes.addFlashAttribute("page", "admin");

		try {
			ReservationId reservationId =
					new ReservationId(resourceId, endTime);
			reservationService.cancelReservation(reservationId);
			return "redirect:/admin?reservationCancelled";
		} catch (IllegalArgumentException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin?error&message=" + ex.getMessage();
		}
	}

	/**
	 * Helper method to unproxy Hibernate entities and force initialization.
	 * This ensures all lazy-loaded fields are accessible outside the transaction.
	 */
	@SuppressWarnings("ResultOfMethodCallIgnored")
	private Resource unproxyResource(Resource resource) {
		// Force Hibernate to initialize the proxy and load all data
		Hibernate.initialize(resource);

		// Get the real underlying object (unwrap the proxy)
		Resource real = (Resource) Hibernate.unproxy(resource);

		// Touch all fields to ensure they're loaded within the transaction boundary
		// The @SuppressWarnings above silences "result ignored" warnings
		if (real instanceof Book) {
			Book book = (Book) real;
			book.getTitle();
			book.getAuthor();
			book.getIsbn();
			book.getYear();
			book.getCopiesAvailable();
		} else if (real instanceof Room) {
			Room room = (Room) real;
			room.getName();
			room.getRoomCode();
			room.getLocation();
			room.getCapacity();
		}

		return real;
	}

	@Transactional(readOnly = true)
	@GetMapping("/reservations/{resourceId}/{endTime}/edit")
	public String editReservationForm(@PathVariable Long resourceId,
									  @PathVariable @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
									  Model model,
									  RedirectAttributes redirectAttributes) {
		try {
			ReservationId reservationId =
					new ReservationId(resourceId, endTime);
			Reservation reservation = reservationService.findById(reservationId)
					.orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

			// CRITICAL: Unproxy the resource and force full initialization
			Resource resource = unproxyResource(reservation.getResource());
			reservation.setResource(resource); // Replace with unproxied version

			// Force initialization of client
			Hibernate.initialize(reservation.getClient());
			reservation.getClient().getName();
			reservation.getClient().getEmail();

			// Populate the form with existing data
			AdminReservationForm form = new AdminReservationForm();
			form.setResourceId(resource.getId());
			form.setClientId(reservation.getClient().getId());
			form.setStartTime(reservation.getStartTime());
			form.setEndTime(reservation.getId().getEndTime());
			form.setNotes(reservation.getNotes());

			// Get upcoming reservations for this resource (next 30 days)
			LocalDateTime now = LocalDateTime.now();
			LocalDateTime futureLimit = now.plusDays(30);
			List<Reservation> upcomingReservations =
					reservationService.findOverlappingActiveReservations(resourceId, now, futureLimit);

			// Unproxy all resources in upcoming reservations
			for (Reservation res : upcomingReservations) {
				Resource upcomingResource = unproxyResource(res.getResource());
				res.setResource(upcomingResource);

				// Initialize client
				Hibernate.initialize(res.getClient());
				res.getClient().getId();
			}

			model.addAttribute("reservationForm", form);
			model.addAttribute("reservation", reservation);
			model.addAttribute("upcomingReservations", upcomingReservations);
			model.addAttribute("now", now);
			model.addAttribute("page", "admin");
			model.addAttribute("isEdit", true);
			return "admin/reservation_edit";

		} catch (IllegalArgumentException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin?error&message=" + ex.getMessage();
		}
	}

	@PostMapping("/reservations/{resourceId}/{endTime}/edit")
	public String updateReservation(@PathVariable Long resourceId,
									@PathVariable @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
									@ModelAttribute("reservationForm") @Valid AdminReservationForm form,
									BindingResult br,
									Model model,
									RedirectAttributes redirectAttributes,
									Authentication authentication) {
		model.addAttribute("page", "admin");
		model.addAttribute("isEdit", true);

		// Get the existing reservation for redisplay on error
		Reservation existingReservation = null;
		try {
			ReservationId reservationId =
					new ReservationId(resourceId, endTime);
			existingReservation = reservationService.findById(reservationId)
					.orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

			// CRITICAL: Unproxy resource
			Resource resource = unproxyResource(existingReservation.getResource());
			existingReservation.setResource(resource);

			// Initialize client
			Hibernate.initialize(existingReservation.getClient());
			existingReservation.getClient().getName();
			existingReservation.getClient().getEmail();

			model.addAttribute("reservation", existingReservation);

			// Get upcoming reservations for display on error
			LocalDateTime now = LocalDateTime.now();
			LocalDateTime futureLimit = now.plusDays(30);
			List<Reservation> upcomingReservations =
					reservationService.findOverlappingActiveReservations(resourceId, now, futureLimit);

			// Unproxy all resources
			for (Reservation res : upcomingReservations) {
				Resource upcomingResource = unproxyResource(res.getResource());
				res.setResource(upcomingResource);

				Hibernate.initialize(res.getClient());
				res.getClient().getId();
			}

			model.addAttribute("upcomingReservations", upcomingReservations);
			model.addAttribute("now", now);
		} catch (Exception e) {
			redirectAttributes.addFlashAttribute("error", "Reservation not found");
			return "redirect:/admin?error&message=Reservation+not+found";
		}

		// CRITICAL: Ensure resource and client IDs match the original reservation
		form.setResourceId(existingReservation.getResource().getId());
		form.setClientId(existingReservation.getClient().getId());

		if (br.hasErrors()) {
			return "admin/reservation_edit";
		}

		try {
			// Get the current admin user
			String username = authentication.getName();
			User currentUser = userService.findByEmail(username)
					.orElseThrow(() -> new IllegalArgumentException("Admin user not found"));

			if (!(currentUser instanceof Admin)) {
				br.reject("reservation.error", "Only admins can modify reservations");
				return "admin/reservation_edit";
			}

			Admin admin = (Admin) currentUser;

			// If end time changed, we need to cancel old and create new (composite key change)
			if (!endTime.equals(form.getEndTime())) {
				ReservationId oldId =
						new ReservationId(resourceId, endTime);
				reservationService.cancelReservation(oldId);
				reservationService.createReservationFromForm(form, admin);
				redirectAttributes.addFlashAttribute("successMessage", "Reservation updated successfully");
			} else {
				// Same end time, update in place (only start time and notes changed)
				existingReservation.setStartTime(form.getStartTime());
				existingReservation.setNotes(form.getNotes());
				existingReservation.setStatus("ACTIVE");

				reservationService.createReservation(existingReservation);
				redirectAttributes.addFlashAttribute("successMessage", "Reservation updated successfully");
			}

			return "redirect:/admin?reservationUpdated";

		} catch (IllegalArgumentException | IllegalStateException ex) {
			br.reject("reservation.error", ex.getMessage());
			return "admin/reservation_edit";
		}
	}

	// ========== RESOURCE MANAGEMENT ==========

	@GetMapping("/resources")
	public String listResources(Model model) {
		model.addAttribute("resources", resourceService.findAll());
		model.addAttribute("page", "admin");
		return "admin/resources";
	}

	@GetMapping("/resources/new")
	public String newResourceForm(Model model) {
		model.addAttribute("resourceForm", new ResourceForm());
		model.addAttribute("page", "admin");
		return "admin/resource_form";
	}

	@PostMapping("/resources")
	public String createResource(@ModelAttribute("resourceForm") @Valid ResourceForm form,
								 BindingResult br,
								 Model model,
								 RedirectAttributes redirectAttributes) {
		model.addAttribute("page", "admin");

		if (br.hasErrors()) {
			return "admin/resource_form";
		}

		try {
			resourceService.createResourceFromForm(form);
			redirectAttributes.addFlashAttribute("page", "admin");
			return "redirect:/admin/resources?created";
		} catch (IllegalArgumentException ex) {
			br.reject("resource.error", ex.getMessage());
			return "admin/resource_form";
		}
	}

	@GetMapping("/resources/{id}/edit")
	public String editResourceForm(@PathVariable Long id,
								   Model model,
								   RedirectAttributes redirectAttributes) {
		try {
			Resource resource = resourceService.findById(id);
			ResourceForm form = resourceService.toResourceForm(resource);
			model.addAttribute("resourceForm", form);
			model.addAttribute("page", "admin");
			return "admin/resource_form";
		} catch (IllegalArgumentException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			redirectAttributes.addFlashAttribute("page", "admin");
			return "redirect:/admin/resources?error&message=" + ex.getMessage();
		}
	}

	@PostMapping("/resources/{id}/edit")
	public String updateResource(@PathVariable Long id,
								 @ModelAttribute("resourceForm") @Valid ResourceForm form,
								 BindingResult br,
								 Model model,
								 RedirectAttributes redirectAttributes) {
		model.addAttribute("page", "admin");

		// Ensure ID is set in the form
		form.setId(id);

		if (br.hasErrors()) {
			return "admin/resource_form";
		}

		try {
			resourceService.updateResourceFromForm(form);
			redirectAttributes.addFlashAttribute("page", "admin");
			return "redirect:/admin/resources?updated";
		} catch (IllegalArgumentException ex) {
			br.reject("resource.error", ex.getMessage());
			return "admin/resource_form";
		}
	}

	@PostMapping("/resources/{id}/delete")
	public String deleteResource(@PathVariable Long id,
								 RedirectAttributes redirectAttributes) {
		redirectAttributes.addFlashAttribute("page", "admin");

		try {
			resourceService.deleteById(id);
			return "redirect:/admin/resources?deleted";
		} catch (IllegalArgumentException | IllegalStateException ex) {
			redirectAttributes.addFlashAttribute("error", ex.getMessage());
			return "redirect:/admin/resources?error&message=" + ex.getMessage();
		}
	}
}