package g3.t1.resourcemanagement.security;

import g3.t1.resourcemanagement.entity.AccountStatus;
import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.User;
import g3.t1.resourcemanagement.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Optional;

/**
 * Filter to validate that authenticated users still exist in the database
 * and are not blocked or suspended.
 */
@Component
@RequiredArgsConstructor
public class UserValidationFilter extends OncePerRequestFilter {

    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Check if user is authenticated
        if (authentication != null && authentication.isAuthenticated()
                && !(authentication.getPrincipal() instanceof String)) {

            String username = authentication.getName();

            // Check if user still exists in database
            Optional<User> userOpt = userRepository.findByEmail(username);

            if (userOpt.isEmpty()) {
                // User no longer exists - invalidate session and logout
                logoutUser(request, response, authentication, "deleted");
                return;
            }

            User user = userOpt.get();

            // Check if account is blocked or suspended
            if (user.getAccountStatus() == AccountStatus.BLOCKED
                    || user.getAccountStatus() == AccountStatus.SUSPENDED) {
                logoutUser(request, response, authentication, "blocked");
                return;
            }

            // Check if client is temporarily blocked
            if (user instanceof Client) {
                Client client = (Client) user;
                if (client.getBlockedUntil() != null
                        && !LocalDate.now().isAfter(client.getBlockedUntil())) {
                    // Still blocked
                    logoutUser(request, response, authentication, "blocked");
                    return;
                }
            }
        }

        filterChain.doFilter(request, response);
    }

    private void logoutUser(HttpServletRequest request,
                            HttpServletResponse response,
                            Authentication authentication,
                            String reason) throws IOException {
        new SecurityContextLogoutHandler().logout(request, response, authentication);
        SecurityContextHolder.clearContext();
        response.sendRedirect(request.getContextPath() + "/login?" + reason);
    }
}