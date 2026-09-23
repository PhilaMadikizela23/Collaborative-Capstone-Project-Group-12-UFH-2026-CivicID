package za.ac.ufh.civicid.user;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record CitizenProfile(
        Long profileId,
        Long userId,
        String nationalIdNumber,
        LocalDate dateOfBirth,
        String phoneNumber,
        String addressLine1,
        String addressLine2,
        String city,
        String province,
        String postalCode,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
