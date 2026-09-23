package za.ac.ufh.civicid.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.Map;

public final class AdminDtos {
    private AdminDtos() {
    }

    public record ReviewDocumentRequest(
            @NotBlank @Pattern(regexp = "VERIFIED|REJECTED") String status,
            @Size(max = 5000) String notes
    ) {
    }

    public record DecisionRequest(
            @NotBlank @Pattern(regexp = "APPROVE|REJECT|REQUEST_INFORMATION") String action,
            @Size(max = 5000) String message
    ) {
    }

    public record AdminCommentRequest(
            @NotBlank @Size(max = 5000) String message,
            boolean internal
    ) {
    }

    public record Dashboard(
            long totalUsers,
            long citizenUsers,
            long totalApplications,
            long pendingApplications,
            long approvedApplications,
            long rejectedApplications,
            Map<String, Long> applicationsByStatus
    ) {
    }
}
