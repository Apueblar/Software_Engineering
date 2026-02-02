package com.example.web.controller;

import com.example.web.security.SignUpForm;
import com.example.web.service.UserService;
import com.example.web.util.CookieUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class AuthController {

    private final UserService userService;
    private final AuthenticationManager authenticationManager;
    private static final int COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

    public AuthController(UserService userService,
                          AuthenticationManager authenticationManager) {
        this.userService = userService;
        this.authenticationManager = authenticationManager;
    }

    @GetMapping("/login")
    public String login() { return "login"; }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request,
                         HttpServletResponse response,
                         RedirectAttributes redirectAttributes) {

        // Clear Spring Security context
        SecurityContextHolder.clearContext();

        // Invalidate session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Remove cookie
        CookieUtils.addCookie(response, "user", "", 0);

        return "redirect:/login";
    }

    @GetMapping("/signin")
    public String signinForm(Model model) {
        if (!model.containsAttribute("signupForm")) {
            model.addAttribute("signupForm", new SignUpForm());
        }
        return "/signin";
    }

    @PostMapping("/signin")
    public String createAndLogin(@Valid @ModelAttribute("signupForm") SignUpForm form,
                                 BindingResult bindingResult,
                                 HttpServletResponse response,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        // basic validation
        if (bindingResult.hasErrors()) {
            return "/signin";
        }
        // check email uniqueness
        if (userService.existsByEmail(form.getEmail())) {
            model.addAttribute("error", "Email already in use");
            return "/signin";
        }
        // create entity
        if (Boolean.TRUE.equals(form.getAdmin())) {
            userService.addAdmin(
                    form.getName(),
                    form.getEmail(),
                    form.getPassword()
            );
        } else {
            userService.addClient(
                    form.getName(),
                    form.getEmail(),
                    form.getPassword()
            );
        }

        // authenticate programmatically
        try {
            Authentication authRequest = new UsernamePasswordAuthenticationToken(form.getEmail(), form.getPassword());
            Authentication authResult = authenticationManager.authenticate(authRequest);
            SecurityContextHolder.getContext().setAuthentication(authResult);
        } catch (AuthenticationException ex) {
            // fallback if authentication manager fails
            UserDetails ud = userService.loadUserByUsername(form.getEmail());
            Authentication fallbackAuth = new UsernamePasswordAuthenticationToken(ud, null, ud.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(fallbackAuth);
        }

        // set user cookie
        CookieUtils.addCookie(response, "user", form.getEmail(), COOKIE_MAX_AGE);

        // put message into flash (survives redirect)
        redirectAttributes.addFlashAttribute("userCreated",
                "Sign in successful. Log in to explore your account and discover available features.");

        return "redirect:/login";
    }

    /**
     * Sets a simple "user" cookie with the authenticated username/email.
     * This endpoint expects the user to be already authenticated (i.e. after Spring form login).
     * You can call it via fetch('/auth/set-cookie', { method: 'POST', credentials: 'include' })
     * from the client after login to create a readable cookie for client logic.
     */
    @PostMapping("/auth/set-cookie")
    public String setUserCookie(Authentication authentication, HttpServletResponse response) {
        if (authentication != null && authentication.isAuthenticated()) {
            String principalName = authentication.getName();
            // 30 days
            CookieUtils.addCookie(response, "user", principalName, 60 * 60 * 24 * 30);
        }
        // redirect to home (or read Accept header and return 200 for AJAX)
        return "redirect:/";
    }
}
