package za.ac.ufh.civicid.user;

import java.time.LocalDateTime;

public record UserAccount(
        Long userId,
        String roleCode,
        String firstName,
        String lastName,
        String email,
        String passwordHash,
        String accountStatus,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
