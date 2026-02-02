package com.example.web.service;

import com.example.web.entity.Admin;
import com.example.web.entity.Client;
import com.example.web.repository.UserRepository;
import com.example.web.entity.User;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public Client addClient(String name,
                            String email,
                            String rawPassword) {

        String encoded = passwordEncoder.encode(rawPassword);

        Client client = Client.builder()
                .name(name)
                .email(email)
                .password(encoded)
                .maxActiveLoans(5)
                .role("ROLE_USER")
                .build();

        return (Client) userRepository.save(client);
    }

    /**
     * Create an Admin and save it.
     */
    @Transactional
    public Admin addAdmin(String name,
                          String email,
                          String rawPassword) {

        String encoded = passwordEncoder.encode(rawPassword);

        Admin admin = Admin.builder()
                .name(name)
                .email(email)
                .password(encoded)
                .adminLevel(1)
                .role("ROLE_ADMIN")
                .build();

        return (Admin) userRepository.save(admin);
    }

    /**
     * Convenience: check existence by email
     */
    public boolean existsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    public User findByEmailOrNull(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User u = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

        return new org.springframework.security.core.userdetails.User(
                u.getEmail(),
                u.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority(u.getRole()))
        );
    }
}
