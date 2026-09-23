package za.ac.ufh.civicid.notification;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

@Repository
public class NotificationRepository {
    private final NamedParameterJdbcTemplate jdbc;

    public NotificationRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void create(
            long userId,
            Long applicationId,
            String type,
            String title,
            String message
    ) {
        jdbc.update("""
                        INSERT INTO notifications (
                            user_id, application_id, notification_type, title, message
                        ) VALUES (
                            :userId, :applicationId, :type, :title, :message
                        )
                        """,
                new MapSqlParameterSource()
                        .addValue("userId", userId)
                        .addValue("applicationId", applicationId)
                        .addValue("type", type)
                        .addValue("title", title)
                        .addValue("message", message));
    }

    public List<NotificationRecord> list(long userId) {
        return jdbc.query("""
                        SELECT notification_id, application_id, notification_type,
                               title, message, created_at, read_at
                        FROM notifications
                        WHERE user_id = :userId
                        ORDER BY created_at DESC
                        """,
                Map.of("userId", userId),
                (result, rowNumber) -> new NotificationRecord(
                        result.getLong("notification_id"),
                        result.getObject("application_id", Long.class),
                        result.getString("notification_type"),
                        result.getString("title"),
                        result.getString("message"),
                        result.getTimestamp("created_at").toLocalDateTime(),
                        toLocalDateTime(result.getTimestamp("read_at"))
                ));
    }

    public int unreadCount(long userId) {
        Integer count = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM notifications
                        WHERE user_id = :userId AND read_at IS NULL
                        """,
                Map.of("userId", userId),
                Integer.class);
        return count == null ? 0 : count;
    }

    public int markRead(long notificationId, long userId) {
        return jdbc.update("""
                        UPDATE notifications
                        SET read_at = COALESCE(read_at, CURRENT_TIMESTAMP)
                        WHERE notification_id = :notificationId AND user_id = :userId
                        """,
                Map.of("notificationId", notificationId, "userId", userId));
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }
}
