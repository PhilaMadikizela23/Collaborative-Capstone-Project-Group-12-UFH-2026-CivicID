package za.ac.ufh.civicid.user;

import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import za.ac.ufh.civicid.security.AuthenticatedUser;

@RestController
@RequestMapping("/api/citizens/me/profile")
public class ProfileController {
    private final ProfileService profiles;

    public ProfileController(ProfileService profiles) {
        this.profiles = profiles;
    }

    @GetMapping
    public CitizenProfile get(@AuthenticationPrincipal Jwt jwt) {
        return profiles.get(AuthenticatedUser.id(jwt));
    }

    @PutMapping
    public CitizenProfile save(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody ProfileDtos.SaveProfileRequest request
    ) {
        return profiles.save(AuthenticatedUser.id(jwt), request);
    }
}
