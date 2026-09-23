package za.ac.ufh.civicid.audit;

import java.time.LocalDateTime;

public record AuditEntry(
        Long auditId,
        LocalDateTime createdAt,
        String actionType,
        String description,
        String entityType,
        Long entityId,
        String deviceInfo,
        String ipAddress,
        String actorName
) {
}
