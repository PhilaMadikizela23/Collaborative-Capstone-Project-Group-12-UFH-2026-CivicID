package za.ac.ufh.civicid.user;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import za.ac.ufh.civicid.common.NotFoundException;

import java.sql.Timestamp;
import java.util.Map;
import java.util.Optional;

@Repository
public class UserRepository {
    private static final String SELECT_USER = """
            SELECT u.user_id, r.role_code, u.first_name, u.last_name, u.email,
                   u.password_hash, u.account_status, u.last_login_at,
                   u.created_at, u.updated_at
            FROM users u
            JOIN roles r ON r.role_id = u.role_id
            """;

    private final NamedParameterJdbcTemplate jdbc;

    private final RowMapper<UserAccount> mapper = (result, rowNumber) -> new UserAccount(
            result.getLong("user_id"),
            result.getString("role_code"),
            result.getString("first_name"),
            result.getString("last_name"),
            result.getString("email"),
            result.getString("password_hash"),
            result.getString("account_status"),
            toLocalDateTime(result.getTimestamp("last_login_at")),
            toLocalDateTime(result.getTimestamp("created_at")),
            toLocalDateTime(result.getTimestamp("updated_at"))
    );

    public UserRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<UserAccount> findByEmail(String email) {
        return jdbc.query(
                        SELECT_USER + " WHERE LOWER(u.email) = LOWER(:email)",
                        Map.of("email", email),
                        mapper)
                .stream()
                .findFirst();
    }

    public Optional<UserAccount> findById(long userId) {
        return jdbc.query(
                        SELECT_USER + " WHERE u.user_id = :userId",
                        Map.of("userId", userId),
                        mapper)
                .stream()
                .findFirst();
    }

    public UserAccount requireById(long userId) {
        return findById(userId).orElseThrow(() -> new NotFoundException("User account not found."));
    }

    public long create(
            String roleCode,
            String firstName,
            String lastName,
            String email,
            String passwordHash
    ) {
        Integer roleId = jdbc.queryForObject(
                "SELECT role_id FROM roles WHERE role_code = :roleCode",
                Map.of("roleCode", roleCode),
                Integer.class
        );
        KeyHolder keyHolder = new GeneratedKeyHolder();
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("roleId", roleId)
                .addValue("firstName", firstName)
                .addValue("lastName", lastName)
                .addValue("email", email.toLowerCase())
                .addValue("passwordHash", passwordHash);
        jdbc.update("""
                        INSERT INTO users (
                            role_id, first_name, last_name, email, password_hash, account_status
                        ) VALUES (
                            :roleId, :firstName, :lastName, :email, :passwordHash, 'ACTIVE'
                        )
                        """,
                parameters,
                keyHolder,
                new String[]{"user_id"});
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("MySQL did not return the generated user ID.");
        }
        return key.longValue();
    }

    public void updateLastLogin(long userId) {
        jdbc.update(
                "UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE user_id = :userId",
                Map.of("userId", userId)
        );
    }

    public void updateAdmin(long userId, String firstName, String lastName, String passwordHash) {
        jdbc.update("""
                        UPDATE users u
                        JOIN roles r ON r.role_code = 'ADMIN'
                        SET u.role_id = r.role_id,
                            u.first_name = :firstName,
                            u.last_name = :lastName,
                            u.password_hash = :passwordHash,
                            u.account_status = 'ACTIVE'
                        WHERE u.user_id = :userId
                        """,
                Map.of(
                        "userId", userId,
                        "firstName", firstName,
                        "lastName", lastName,
                        "passwordHash", passwordHash
                ));
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }
}
