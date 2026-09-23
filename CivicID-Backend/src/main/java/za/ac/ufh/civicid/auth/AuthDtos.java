package za.ac.ufh.civicid.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public final class AuthDtos {
    private AuthDtos() {
    }

    public record RegisterRequest(
            @NotBlank @Size(max = 80) String firstName,
            @NotBlank @Size(max = 80) String lastName,
            @NotBlank @Email @Size(max = 150) String email,
            @NotBlank @Size(min = 8, max = 72) String password
    ) {
    }

    public record LoginRequest(
            @NotBlank @Email String email,
            @NotBlank String password
    ) {
    }

    public record AuthResponse(
            Long userId,
            String email,
            String role,
            String tokenType,
            String accessToken,
            Instant expiresAt
    ) {
    }

    public record UserResponse(
            Long userId,
            String firstName,
            String lastName,
            String email,
            String role,
            String accountStatus
    ) {
    }
}
