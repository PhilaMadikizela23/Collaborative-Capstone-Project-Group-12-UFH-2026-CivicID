package za.ac.ufh.civicid.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public final class ProfileDtos {
    private ProfileDtos() {
    }

    public record SaveProfileRequest(
            @NotBlank @Size(max = 30) String nationalIdNumber,
            @NotNull @Past LocalDate dateOfBirth,
            @NotBlank @Size(max = 30) String phoneNumber,
            @NotBlank @Size(max = 150) String addressLine1,
            @Size(max = 150) String addressLine2,
            @NotBlank @Size(max = 100) String city,
            @NotBlank @Size(max = 100) String province,
            @NotBlank @Size(max = 20) String postalCode
    ) {
    }
}
