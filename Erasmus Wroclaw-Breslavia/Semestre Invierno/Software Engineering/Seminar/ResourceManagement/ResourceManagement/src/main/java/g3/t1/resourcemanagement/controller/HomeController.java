package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.Reservation;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.service.ReservationService;
import g3.t1.resourcemanagement.service.ResourceService;
import g3.t1.resourcemanagement.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Controller
@RequiredArgsConstructor
public class HomeController {

    private final ResourceService resourceService;
    private final ReservationService reservationService;
    private final UserService userService;

    private String userType(Authentication authentication) {
        String userType = "guest"; // default
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

    @GetMapping("/")
    public String index(
            @RequestParam(name = "startTime", required = false) @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime startTime,
            @RequestParam(name = "endTime", required = false) @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime endTime,
            Model model, Authentication authentication) {

        List<Resource> resources = resourceService.findAll();

        LocalDateTime now = LocalDateTime.now();

        if (startTime != null && startTime.isBefore(now)) {
            startTime = null;
        }

        if (endTime != null && endTime.isBefore(now)) {
            endTime = null;
        }

        if (startTime != null && endTime != null && !endTime.isAfter(startTime)) {
            endTime = null;
        }

        // Apply availability filtering
        if (startTime != null) {
            List<Long> reservedIds;

            if (endTime != null) {
                reservedIds = resourceService.findReservedResourceIdsBetween(startTime, endTime);
            } else {
                reservedIds = resourceService.findReservedResourceIdsAt(startTime);
            }

            Set<Long> reservedSet = new HashSet<>(reservedIds);

            resources.forEach(r -> {
                boolean originallyAvailable = Boolean.TRUE.equals(r.getAvailable());
                boolean availableAtTime = originallyAvailable && !reservedSet.contains(r.getId());
                r.setAvailable(availableAtTime);
            });
        }

        String userType = userType(authentication);

        // Initialize empty list
        List<Reservation> userReservations = new ArrayList<>();

        if (userType.equals("client")) {
            String userEmail = authentication.getName();
            userService.findByEmail(userEmail).ifPresent(user -> {
                Client client = (Client) user;
                List<Reservation> reservations = reservationService.findActiveReservationsByClientId(client.getId());
                userReservations.clear();
                userReservations.addAll(reservations);
            });
        }

        // Always add userReservations to model (even if empty)
        model.addAttribute("userReservations", userReservations);

        model.addAttribute("resources", resources);
        model.addAttribute("startTime", startTime);
        model.addAttribute("endTime", endTime);

        model.addAttribute("startTimeString",
                startTime != null ? startTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "");

        model.addAttribute("endTimeString",
                endTime != null ? endTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "");

        model.addAttribute("userType", userType);
        model.addAttribute("page", "main");

        return "index";
    }

    @GetMapping("/login")
    public String loginPage(Model model) {
        model.addAttribute("page", "login");
        return "login";
    }
}
