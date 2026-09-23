package za.ac.ufh.civicid.notification;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import za.ac.ufh.civicid.security.AuthenticatedUser;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final NotificationService notifications;

    public NotificationController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping
    public List<NotificationRecord> list(@AuthenticationPrincipal Jwt jwt) {
        return notifications.list(AuthenticatedUser.id(jwt));
    }

    @GetMapping("/unread-count")
    public NotificationService.UnreadCount unreadCount(@AuthenticationPrincipal Jwt jwt) {
        return notifications.unreadCount(AuthenticatedUser.id(jwt));
    }

    @PatchMapping("/{notificationId}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markRead(@AuthenticationPrincipal Jwt jwt, @PathVariable long notificationId) {
        notifications.markRead(notificationId, AuthenticatedUser.id(jwt));
    }
}
