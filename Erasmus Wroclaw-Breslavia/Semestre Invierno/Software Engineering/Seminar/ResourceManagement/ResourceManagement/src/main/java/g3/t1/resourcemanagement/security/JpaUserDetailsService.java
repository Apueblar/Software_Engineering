package g3.t1.resourcemanagement.security;

import g3.t1.resourcemanagement.entity.AccountStatus;
import g3.t1.resourcemanagement.entity.Admin;
import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.User;
import g3.t1.resourcemanagement.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collection;

@Service
@RequiredArgsConstructor
public class JpaUserDetailsService implements UserDetailsService {

	private final UserRepository userRepository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		User u = userRepository.findByEmail(username)
				.orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

		Collection<GrantedAuthority> authorities = mapAuthorities(u);

		// Ensure the password returned here is the encoded password stored in DB
		return org.springframework.security.core.userdetails.User.builder()
				.username(u.getEmail())
				.password(u.getPassword())
				.authorities(authorities)
				.accountLocked(!isAccountNonLocked(u))
				.disabled(!isEnabled(u))
				.accountExpired(false)
				.credentialsExpired(false)
				.build();
	}

	private Collection<GrantedAuthority> mapAuthorities(User u) {
		var auth = new ArrayList<GrantedAuthority>();

		// Simple mapping based on subclass type. Adjust if you have a Role entity.
		if (u instanceof Admin) {
			auth.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
		} else if (u instanceof Client) {
			auth.add(new SimpleGrantedAuthority("ROLE_CLIENT"));
		} else {
			throw new AuthenticationServiceException("Unsupported user type: " + u.getClass().getName());
		}

		// If you have additional role/permission fields on User, map them here.
		return auth;
	}

	private boolean isEnabled(User u) {
		AccountStatus status = u.getAccountStatus();
		// Enabled -> ACTIVE
		return (status == AccountStatus.ACTIVE);
	}

	private boolean isAccountNonLocked(User u) {
		AccountStatus status = u.getAccountStatus();
		// null -> assume not locked; BLOCKED or SUSPENDED -> locked
		return (status != AccountStatus.BLOCKED && status != AccountStatus.SUSPENDED);
	}
}
