package za.ac.ufh.civicid.auth;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.ac.ufh.civicid.common.BadRequestException;
import za.ac.ufh.civicid.common.ConflictException;
import za.ac.ufh.civicid.security.TokenService;
import za.ac.ufh.civicid.user.UserAccount;
import za.ac.ufh.civicid.user.UserRepository;

import static za.ac.ufh.civicid.auth.AuthDtos.*;

@Service
public class AuthService {
    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokens;

    public AuthService(UserRepository users, PasswordEncoder passwordEncoder, TokenService tokens) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.tokens = tokens;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.email().trim().toLowerCase();
        if (users.findByEmail(email).isPresent()) {
            throw new ConflictException("An account with this email address already exists.");
        }
        long userId = users.create(
                "CITIZEN",
                request.firstName().trim(),
                request.lastName().trim(),
                email,
                passwordEncoder.encode(request.password())
        );
        return response(users.requireById(userId));
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        UserAccount user = users.findByEmail(request.email().trim().toLowerCase())
                .orElseThrow(() -> new BadRequestException("The email address or password is incorrect."));
        if (!"ACTIVE".equals(user.accountStatus()) || !passwordEncoder.matches(request.password(), user.passwordHash())) {
            throw new BadRequestException("The email address or password is incorrect.");
        }
        users.updateLastLogin(user.userId());
        return response(users.requireById(user.userId()));
    }

    public UserResponse currentUser(long userId) {
        UserAccount user = users.requireById(userId);
        return new UserResponse(
                user.userId(),
                user.firstName(),
                user.lastName(),
                user.email(),
                user.roleCode(),
                user.accountStatus()
        );
    }

    @Transactional
    public void createOrUpdateAdmin(String email, String password) {
        String normalizedEmail = email.trim().toLowerCase();
        String passwordHash = passwordEncoder.encode(password);
        users.findByEmail(normalizedEmail).ifPresentOrElse(
                user -> users.updateAdmin(user.userId(), "CivicID", "Administrator", passwordHash),
                () -> users.create("ADMIN", "CivicID", "Administrator", normalizedEmail, passwordHash)
        );
    }

    private AuthResponse response(UserAccount user) {
        TokenService.TokenResult token = tokens.issue(user);
        return new AuthResponse(
                user.userId(),
                user.email(),
                user.roleCode(),
                "Bearer",
                token.value(),
                token.expiresAt()
        );
    }
}
