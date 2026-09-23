package za.ac.ufh.civicid.user;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Map;
import java.util.Optional;

@Repository
public class ProfileRepository {
    private final NamedParameterJdbcTemplate jdbc;

    private final RowMapper<CitizenProfile> mapper = (result, rowNumber) -> new CitizenProfile(
            result.getLong("profile_id"),
            result.getLong("user_id"),
            result.getString("national_id_number"),
            result.getDate("date_of_birth").toLocalDate(),
            result.getString("phone_number"),
            result.getString("address_line_1"),
            result.getString("address_line_2"),
            result.getString("city"),
            result.getString("province"),
            result.getString("postal_code"),
            toLocalDateTime(result.getTimestamp("created_at")),
            toLocalDateTime(result.getTimestamp("updated_at"))
    );

    public ProfileRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<CitizenProfile> findByUserId(long userId) {
        return jdbc.query(
                        "SELECT * FROM citizen_profiles WHERE user_id = :userId",
                        Map.of("userId", userId),
                        mapper)
                .stream()
                .findFirst();
    }

    public void upsert(long userId, ProfileDtos.SaveProfileRequest request) {
        jdbc.update("""
                        INSERT INTO citizen_profiles (
                            user_id, national_id_number, date_of_birth, phone_number,
                            address_line_1, address_line_2, city, province, postal_code
                        ) VALUES (
                            :userId, :nationalIdNumber, :dateOfBirth, :phoneNumber,
                            :addressLine1, :addressLine2, :city, :province, :postalCode
                        )
                        ON DUPLICATE KEY UPDATE
                            national_id_number = :nationalIdNumber,
                            date_of_birth = :dateOfBirth,
                            phone_number = :phoneNumber,
                            address_line_1 = :addressLine1,
                            address_line_2 = :addressLine2,
                            city = :city,
                            province = :province,
                            postal_code = :postalCode
                        """,
                Map.ofEntries(
                        Map.entry("userId", userId),
                        Map.entry("nationalIdNumber", request.nationalIdNumber().trim()),
                        Map.entry("dateOfBirth", request.dateOfBirth()),
                        Map.entry("phoneNumber", request.phoneNumber().trim()),
                        Map.entry("addressLine1", request.addressLine1().trim()),
                        Map.entry("addressLine2", request.addressLine2() == null ? "" : request.addressLine2().trim()),
                        Map.entry("city", request.city().trim()),
                        Map.entry("province", request.province().trim()),
                        Map.entry("postalCode", request.postalCode().trim())
                ));
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }
}
