package g3.t1.resourcemanagement.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.*;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

	private final UserValidationFilter userValidationFilter;

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
	// @Bean
	// public PasswordEncoder passwordEncoder() { return
	// NoOpPasswordEncoder.getInstance(); }

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http, PasswordEncoder passwordEncoder) throws Exception {
		http
				.authorizeHttpRequests(auth -> auth
						.requestMatchers("/css/**", "/js/**", "/img/**", "/login").permitAll()
						.requestMatchers("/login").permitAll()
						.requestMatchers("/admin/**").hasRole("ADMIN")
						.anyRequest().authenticated())
				.formLogin(form -> form
						.loginPage("/login")
						.defaultSuccessUrl("/", true)
						.permitAll())
				.logout(logout -> logout
						.logoutUrl("/logout")
						.logoutSuccessUrl("/login?logout")
						.invalidateHttpSession(true)
						.deleteCookies("JSESSIONID")
						.permitAll())
				.addFilterBefore(userValidationFilter, UsernamePasswordAuthenticationFilter.class)
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
				.csrf(csrf -> csrf
						// default CSRF protection for MPA
						.ignoringRequestMatchers("/api/**") // if you later add API endpoints for SPA, you may handle
															// CSRF differently
				);

		return http.build();
	}
}
