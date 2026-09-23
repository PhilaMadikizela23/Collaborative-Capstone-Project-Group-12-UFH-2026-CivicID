package za.ac.ufh.civicid.notification;

import java.time.LocalDateTime;

public record NotificationRecord(
        Long notificationId,
        Long applicationId,
        String notificationType,
        String title,
        String message,
        LocalDateTime createdAt,
        LocalDateTime readAt
) {
}
