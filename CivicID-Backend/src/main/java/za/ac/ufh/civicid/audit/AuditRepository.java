package za.ac.ufh.civicid.audit;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class AuditRepository {
    private final NamedParameterJdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public AuditRepository(NamedParameterJdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    public void record(
            Long userId,
            String action,
            String description,
            String entityType,
            Long entityId,
            Map<String, ?> metadata
    ) {
        jdbc.update("""
                        INSERT INTO audit_logs (
                            user_id, action_type, description, entity_type, entity_id, metadata
                        ) VALUES (
                            :userId, :action, :description, :entityType, :entityId, :metadata
                        )
                        """,
                new MapSqlParameterSource()
                        .addValue("userId", userId)
                        .addValue("action", action)
                        .addValue("description", description)
                        .addValue("entityType", entityType)
                        .addValue("entityId", entityId)
                        .addValue("metadata", json(metadata)));
    }

    public List<AuditEntry> list(int limit) {
        return jdbc.query("""
                        SELECT audit_id, created_at, action_type, description,
                               entity_type, entity_id, device_info, ip_address, actor_name
                        FROM vw_system_audit_logs
                        ORDER BY created_at DESC, audit_id DESC
                        LIMIT :limit
                        """,
                Map.of("limit", Math.max(1, Math.min(limit, 200))),
                (result, rowNumber) -> new AuditEntry(
                        result.getLong("audit_id"),
                        result.getTimestamp("created_at").toLocalDateTime(),
                        result.getString("action_type"),
                        result.getString("description"),
                        result.getString("entity_type"),
                        result.getObject("entity_id", Long.class),
                        result.getString("device_info"),
                        result.getString("ip_address"),
                        result.getString("actor_name")
                ));
    }

    private String json(Map<String, ?> metadata) {
        if (metadata == null || metadata.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(metadata);
        } catch (JsonProcessingException exception) {
            throw new IllegalArgumentException("Audit metadata could not be converted to JSON.", exception);
        }
    }
}
