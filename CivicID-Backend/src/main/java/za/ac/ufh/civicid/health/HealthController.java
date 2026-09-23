package za.ac.ufh.civicid.health;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {
    private final NamedParameterJdbcTemplate jdbc;

    public HealthController(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping
    public HealthResponse health() {
        Map<String, Object> server = jdbc.queryForMap(
                "SELECT DATABASE() AS database_name, VERSION() AS server_version",
                Map.of()
        );
        Long tables = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM information_schema.tables
                        WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'
                        """,
                Map.of(),
                Long.class);
        Long views = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM information_schema.tables
                        WHERE table_schema = DATABASE() AND table_type = 'VIEW'
                        """,
                Map.of(),
                Long.class);
        return new HealthResponse(
                "UP",
                String.valueOf(server.get("database_name")),
                String.valueOf(server.get("server_version")),
                tables == null ? 0 : tables,
                views == null ? 0 : views,
                Instant.now()
        );
    }

    public record HealthResponse(
            String status,
            String database,
            String mysqlVersion,
            long tables,
            long views,
            Instant checkedAt
    ) {
    }
}
