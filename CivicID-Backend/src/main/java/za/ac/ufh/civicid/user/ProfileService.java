package za.ac.ufh.civicid.user;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.ac.ufh.civicid.common.NotFoundException;

@Service
public class ProfileService {
    private final ProfileRepository profiles;

    public ProfileService(ProfileRepository profiles) {
        this.profiles = profiles;
    }

    public CitizenProfile get(long userId) {
        return profiles.findByUserId(userId)
                .orElseThrow(() -> new NotFoundException("Citizen profile has not been completed."));
    }

    @Transactional
    public CitizenProfile save(long userId, ProfileDtos.SaveProfileRequest request) {
        profiles.upsert(userId, request);
        return get(userId);
    }
}
