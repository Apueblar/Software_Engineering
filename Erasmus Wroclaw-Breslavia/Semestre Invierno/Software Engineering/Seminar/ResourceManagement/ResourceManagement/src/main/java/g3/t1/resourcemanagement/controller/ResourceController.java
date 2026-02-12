package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.Reservation;
import g3.t1.resourcemanagement.entity.ReservationId;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.service.ReservationService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
import g3.t1.resourcemanagement.web.ReservationForm;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.hibernate.Hibernate;

import jakarta.validation.Valid;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/resources")
@RequiredArgsConstructor
public class ResourceController {

    private final ResourceService resourceService;
    private final ReservationService reservationService;
    private final UserService userService;

    private String userType(Authentication authentication) {
        String userType = "guest";
        if (authentication != null && authentication.isAuthenticated()) {
            String username = authentication.getName();
            var userOpt = userService.findByEmail(username);
            if (userOpt.isPresent()) {
                var user = userOpt.get();
                if (user instanceof Client) {
                    userType = "client";
                } else {
                    userType = "admin";
                }
            }
        }
        return userType;
    }

    @GetMapping("/{id}")
    public String viewResource(@PathVariable("id") Long id, Model model, Authentication authentication) {
        Resource resource;
        try {
            resource = resourceService.findById(id);
            // Unproxy the resource to avoid Hibernate proxy issues
            resource = (Resource) Hibernate.unproxy(resource);
        } catch (IllegalArgumentException ex) {
            return "redirect:/?notfound";
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime futureLimit = now.plusMonths(1);

        List<Reservation> upcomingReservations = reservationService.findOverlappingActiveReservations(id, now, futureLimit);

        model.addAttribute("resource", resource);
        model.addAttribute("reservationForm", new ReservationForm());
        model.addAttribute("upcomingReservations", upcomingReservations);
        model.addAttribute("now", now);
        model.addAttribute("page", "resource");
        model.addAttribute("userType", userType(authentication));

        return "resource";
    }

    @PostMapping("/{id}/reserve")
    public String reserveResource(@PathVariable("id") Long id,
                                  @ModelAttribute("reservationForm") @Valid ReservationForm form,
                                  BindingResult bindingResult,
                                  Authentication authentication,
                                  Model model,
                                  RedirectAttributes redirectAttributes) {

        // Validation errors - return to form with errors
        if (bindingResult.hasErrors()) {
            Resource resource;
            try {
                resource = resourceService.findById(id);
                resource = (Resource) Hibernate.unproxy(resource);
            } catch (IllegalArgumentException ex) {
                redirectAttributes.addFlashAttribute("errorMessage", "Resource not found");
                return "redirect:/";
            }

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime futureLimit = now.plusMonths(1);
            List<Reservation> upcomingReservations = reservationService.findOverlappingActiveReservations(id, now, futureLimit);

            model.addAttribute("resource", resource);
            model.addAttribute("upcomingReservations", upcomingReservations);
            model.addAttribute("now", now);
            model.addAttribute("page", "resource");
            model.addAttribute("userType", userType(authentication));
            return "resource";
        }

        // Get and unproxy the resource
        Resource resource;
        try {
            resource = resourceService.findById(id);
            resource = (Resource) Hibernate.unproxy(resource);
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Resource not found");
            return "redirect:/";
        }

        // Get authenticated user
        String username = authentication.getName();
        var userOpt = userService.findByEmail(username);
        if (userOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "User not found. Please log in again.");
            return "redirect:/";
        }

        // Verify user is a client
        Client client;
        var user = userOpt.get();
        if (user instanceof Client) {
            client = (Client) user;
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "Only clients may create reservations");
            return "redirect:/resources/" + id;
        }

        // Attempt to create reservation - handle race conditions gracefully
        try {
            reservationService.createReservationFromForm(form, client, resource);
            redirectAttributes.addFlashAttribute("successMessage", "Reservation created successfully!");
            return "redirect:/?reserved";
        } catch (IllegalStateException ex) {
            // Business logic violation (e.g., overlapping reservation, resource unavailable)
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Unable to create reservation: " + ex.getMessage());
            return "redirect:/resources/" + id + "?conflict";
        } catch (org.springframework.dao.DataIntegrityViolationException ex) {
            // Database constraint violation (race condition - another user booked first)
            redirectAttributes.addFlashAttribute("errorMessage",
                    "This time slot was just booked by another user. Please select a different time.");
            return "redirect:/resources/" + id + "?conflict";
        } catch (Exception ex) {
            // Generic error handling
            redirectAttributes.addFlashAttribute("errorMessage",
                    "An error occurred while creating your reservation. Please try again.");
            return "redirect:/resources/" + id + "?error";
        }
    }

    @PostMapping("/{id}/{endTime}/cancel")
    @PreAuthorize("isAuthenticated()")
    public String cancelReservation(@PathVariable Long id,
                                    @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
                                    RedirectAttributes redirectAttributes) {

        try {
            ReservationId reservationId = new ReservationId(id, endTime);
            reservationService.cancelReservation(reservationId);
            redirectAttributes.addFlashAttribute("successMessage", "Reservation cancelled successfully");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Reservation not found");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to cancel reservation: " + e.getMessage());
        }

        return "redirect:/";
    }

    @GetMapping("/{id}/{endTime}/edit")
    @PreAuthorize("isAuthenticated()")
    public String editReservation(
            @PathVariable Long id,
            @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
            Model model,
            Authentication authentication,
            RedirectAttributes redirectAttributes) {

        try {
            ReservationId reservationId = new ReservationId(id, endTime);
            Reservation reservation = reservationService.findById(reservationId)
                    .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

            // Check if user owns this reservation
            if (authentication != null && authentication.isAuthenticated()) {
                String userEmail = authentication.getName();
                if (!reservation.getClient().getEmail().equals(userEmail)) {
                    redirectAttributes.addFlashAttribute("errorMessage", "You can only edit your own reservations");
                    return "redirect:/?error=unauthorized";
                }
            }

            // Unproxy the resource to avoid Hibernate proxy issues
            Resource actualResource = (Resource) Hibernate.unproxy(reservation.getResource());
            reservation.setResource(actualResource);

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime futureLimit = now.plusMonths(1);
            List<Reservation> upcomingReservations = reservationService.findOverlappingActiveReservations(id, now, futureLimit);

            // Populate the form with existing data
            ReservationForm form = new ReservationForm();
            form.setStartTime(reservation.getStartTime());
            form.setEndTime(reservation.getId().getEndTime());
            form.setNotes(reservation.getNotes());

            model.addAttribute("reservation", reservation);
            model.addAttribute("reservationForm", form);
            model.addAttribute("upcomingReservations", upcomingReservations);
            model.addAttribute("now", now);
            model.addAttribute("page", "resource");
            model.addAttribute("userType", userType(authentication));
            return "reservation-edit";

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Reservation not found");
            return "redirect:/?error=notfound";
        }
    }

    @PostMapping("/{id}/{endTime}/edit")
    @PreAuthorize("isAuthenticated()")
    public String updateReservation(
            @PathVariable Long id,
            @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
            @ModelAttribute("reservationForm") @Valid ReservationForm form,
            BindingResult bindingResult,
            RedirectAttributes redirectAttributes,
            Model model,
            Authentication authentication) {

        try {
            ReservationId reservationId = new ReservationId(id, endTime);
            Reservation existingReservation = reservationService.findById(reservationId)
                    .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

            // Check if user owns this reservation
            if (authentication == null || !authentication.isAuthenticated()) {
                redirectAttributes.addFlashAttribute("errorMessage", "You must be logged in to edit reservations");
                return "redirect:/?error=unauthorized";
            }

            String userEmail = authentication.getName();
            if (!existingReservation.getClient().getEmail().equals(userEmail)) {
                redirectAttributes.addFlashAttribute("errorMessage", "You can only edit your own reservations");
                return "redirect:/";
            }

            // Check for validation errors
            if (bindingResult.hasErrors()) {
                // Unproxy the resource
                Resource actualResource = (Resource) Hibernate.unproxy(existingReservation.getResource());
                existingReservation.setResource(actualResource);

                LocalDateTime now = LocalDateTime.now();
                LocalDateTime futureLimit = now.plusMonths(1);
                List<Reservation> upcomingReservations = reservationService.findOverlappingActiveReservations(id, now, futureLimit);

                model.addAttribute("reservation", existingReservation);
                model.addAttribute("upcomingReservations", upcomingReservations);
                model.addAttribute("now", now);
                model.addAttribute("page", "resource");
                model.addAttribute("userType", userType(authentication));
                return "reservation-edit";
            }

            // If primary key changed (end time), cancel old and create new
            if (!endTime.equals(form.getEndTime())) {
                reservationService.cancelReservation(reservationId);
                reservationService.createReservationFromForm(form, existingReservation.getClient(),
                        existingReservation.getResource());
                redirectAttributes.addFlashAttribute("successMessage", "Reservation updated successfully");
            } else {
                // Same end time, update in place
                Reservation updatedReservation = reservationService.findById(reservationId)
                        .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));

                updatedReservation.setStartTime(form.getStartTime());
                updatedReservation.setNotes(form.getNotes());
                updatedReservation.setStatus("ACTIVE");

                reservationService.createReservation(updatedReservation);
                redirectAttributes.addFlashAttribute("successMessage", "Reservation updated successfully");
            }

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Reservation not found");
            return "redirect:/";
        } catch (IllegalStateException e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Unable to update reservation: " + e.getMessage());
            return "redirect:/";
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "This time slot is no longer available. Please select a different time.");
            return "redirect:/resources/" + id;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Failed to update reservation: " + e.getMessage());
            return "redirect:/";
        }

        return "redirect:/";
    }
}