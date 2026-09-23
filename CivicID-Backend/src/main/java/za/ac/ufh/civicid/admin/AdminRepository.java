package za.ac.ufh.civicid.admin;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Repository
public class AdminRepository {
    private final NamedParameterJdbcTemplate jdbc;

    public AdminRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public AdminDtos.Dashboard dashboard() {
        long totalUsers = count("SELECT COUNT(*) FROM users");
        long citizenUsers = count("""
                SELECT COUNT(*)
                FROM users u
                JOIN roles r ON r.role_id = u.role_id
                WHERE r.role_code = 'CITIZEN'
                """);
        long totalApplications = count("SELECT COUNT(*) FROM applications");
        long pending = count("""
                SELECT COUNT(*)
                FROM applications a
                JOIN application_statuses ast ON ast.status_id = a.current_status_id
                WHERE ast.status_code IN (
                    'SUBMITTED', 'UNDER_REVIEW', 'ADDITIONAL_INFORMATION_REQUIRED'
                )
                """);
        long approved = count("""
                SELECT COUNT(*)
                FROM applications a
                JOIN application_statuses ast ON ast.status_id = a.current_status_id
                WHERE ast.status_code = 'APPROVED'
                """);
        long rejected = count("""
                SELECT COUNT(*)
                FROM applications a
                JOIN application_statuses ast ON ast.status_id = a.current_status_id
                WHERE ast.status_code = 'REJECTED'
                """);
        Map<String, Long> byStatus = new LinkedHashMap<>();
        jdbc.query("""
                        SELECT ast.status_code, COUNT(a.application_id) AS total
                        FROM application_statuses ast
                        LEFT JOIN applications a ON a.current_status_id = ast.status_id
                        GROUP BY ast.status_id, ast.status_code, ast.display_order
                        ORDER BY ast.display_order
                        """,
                (org.springframework.jdbc.core.RowCallbackHandler) result -> byStatus.put(result.getString("status_code"), result.getLong("total")));
        return new AdminDtos.Dashboard(
                totalUsers,
                citizenUsers,
                totalApplications,
                pending,
                approved,
                rejected,
                byStatus
        );
    }

    private long count(String sql) {
        Long value = jdbc.queryForObject(sql, Map.of(), Long.class);
        return value == null ? 0 : value;
    }
}

