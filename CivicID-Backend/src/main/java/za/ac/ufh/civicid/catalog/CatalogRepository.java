package za.ac.ufh.civicid.catalog;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static za.ac.ufh.civicid.catalog.CatalogDtos.*;

@Repository
public class CatalogRepository {
    private final NamedParameterJdbcTemplate jdbc;

    private final RowMapper<ServiceSummary> serviceMapper = (result, rowNumber) -> new ServiceSummary(
            result.getInt("service_id"),
            result.getString("service_code"),
            result.getString("service_name"),
            result.getString("category_name"),
            result.getString("department_name"),
            result.getString("description"),
            result.getBoolean("is_active")
    );

    public CatalogRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ServiceSummary> listActiveServices() {
        return jdbc.query("""
                        SELECT s.service_id, s.service_code, s.service_name,
                               sc.category_name, s.department_name, s.description, s.is_active
                        FROM services s
                        LEFT JOIN service_categories sc ON sc.category_id = s.category_id
                        WHERE s.is_active = TRUE
                        ORDER BY sc.category_name, s.service_name
                        """,
                Map.of(),
                serviceMapper);
    }

    public Optional<ServiceSummary> findService(int serviceId, boolean includeInactive) {
        String activeFilter = includeInactive ? "" : " AND s.is_active = TRUE";
        return jdbc.query("""
                                SELECT s.service_id, s.service_code, s.service_name,
                                       sc.category_name, s.department_name, s.description, s.is_active
                                FROM services s
                                LEFT JOIN service_categories sc ON sc.category_id = s.category_id
                                WHERE s.service_id = :serviceId
                                """ + activeFilter,
                        Map.of("serviceId", serviceId),
                        serviceMapper)
                .stream()
                .findFirst();
    }

    public List<ServiceField> fields(int serviceId) {
        return jdbc.query("""
                        SELECT service_field_id, field_key, field_label, data_type,
                               prefill_source, help_text, is_required, display_order,
                               CAST(options_json AS CHAR) AS options_json
                        FROM service_fields
                        WHERE service_id = :serviceId
                        ORDER BY display_order
                        """,
                Map.of("serviceId", serviceId),
                (result, rowNumber) -> new ServiceField(
                        result.getLong("service_field_id"),
                        result.getString("field_key"),
                        result.getString("field_label"),
                        result.getString("data_type"),
                        result.getString("prefill_source"),
                        result.getString("help_text"),
                        result.getBoolean("is_required"),
                        result.getInt("display_order"),
                        result.getString("options_json")
                ));
    }

    public List<DocumentRequirement> requirements(int serviceId) {
        return jdbc.query("""
                        SELECT sdr.requirement_id, dt.document_type_id, dt.type_code, dt.type_name,
                               sdr.is_required, sdr.minimum_count, sdr.maximum_count,
                               sdr.instructions, sdr.display_order
                        FROM service_document_requirements sdr
                        JOIN document_types dt ON dt.document_type_id = sdr.document_type_id
                        WHERE sdr.service_id = :serviceId
                        ORDER BY sdr.display_order
                        """,
                Map.of("serviceId", serviceId),
                (result, rowNumber) -> new DocumentRequirement(
                        result.getLong("requirement_id"),
                        result.getInt("document_type_id"),
                        result.getString("type_code"),
                        result.getString("type_name"),
                        result.getBoolean("is_required"),
                        result.getInt("minimum_count"),
                        (Integer) result.getObject("maximum_count"),
                        result.getString("instructions"),
                        result.getInt("display_order")
                ));
    }

    public List<DocumentType> documentTypes() {
        return jdbc.query("""
                        SELECT document_type_id, type_code, type_name, description, is_active
                        FROM document_types
                        WHERE is_active = TRUE
                        ORDER BY type_name
                        """,
                Map.of(),
                (result, rowNumber) -> new DocumentType(
                        result.getInt("document_type_id"),
                        result.getString("type_code"),
                        result.getString("type_name"),
                        result.getString("description"),
                        result.getBoolean("is_active")
                ));
    }

    public boolean documentTypeExists(int documentTypeId) {
        Integer count = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM document_types
                        WHERE document_type_id = :documentTypeId AND is_active = TRUE
                        """,
                Map.of("documentTypeId", documentTypeId),
                Integer.class);
        return count != null && count > 0;
    }
}
