package za.ac.ufh.civicid.bootstrap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import za.ac.ufh.civicid.auth.AuthService;

@Component
public class AdminBootstrap implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(AdminBootstrap.class);

    private final AuthService authService;
    private final boolean enabled;
    private final String email;
    private final String password;

    public AdminBootstrap(
            AuthService authService,
            @Value("${civicid.bootstrap.admin-enabled}") boolean enabled,
            @Value("${civicid.bootstrap.admin-email}") String email,
            @Value("${civicid.bootstrap.admin-password}") String password
    ) {
        this.authService = authService;
        this.enabled = enabled;
        this.email = email;
        this.password = password;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!enabled) {
            return;
        }
        if (password == null || password.length() < 10) {
            throw new IllegalStateException("The bootstrap administrator password must contain at least 10 characters.");
        }
        authService.createOrUpdateAdmin(email, password);
        log.info("Bootstrap administrator account is ready for {}", email);
    }
}
