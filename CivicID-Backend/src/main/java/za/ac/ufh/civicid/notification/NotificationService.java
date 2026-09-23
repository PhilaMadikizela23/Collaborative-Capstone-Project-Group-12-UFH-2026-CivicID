package za.ac.ufh.civicid.notification;

import org.springframework.stereotype.Service;
import za.ac.ufh.civicid.common.NotFoundException;

import java.util.List;

@Service
public class NotificationService {
    private final NotificationRepository notifications;

    public NotificationService(NotificationRepository notifications) {
        this.notifications = notifications;
    }

    public List<NotificationRecord> list(long userId) {
        return notifications.list(userId);
    }

    public UnreadCount unreadCount(long userId) {
        return new UnreadCount(notifications.unreadCount(userId));
    }

    public void markRead(long notificationId, long userId) {
        if (notifications.markRead(notificationId, userId) == 0) {
            throw new NotFoundException("Notification not found.");
        }
    }

    public record UnreadCount(int unread) {
    }
}
