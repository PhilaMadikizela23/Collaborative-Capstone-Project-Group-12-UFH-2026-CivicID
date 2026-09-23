package za.ac.ufh.civicid.application;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static za.ac.ufh.civicid.application.ApplicationDtos.*;

@Repository
public class ApplicationRepository {
    private static final String SUMMARY_SELECT = """
            SELECT a.application_id, a.reference_number, a.citizen_user_id,
                   s.service_id, s.service_code, s.service_name,
                   ast.status_code, ast.status_name, a.readiness_status,
                   a.draft_created_at, a.submitted_at, a.decided_at, a.updated_at
            FROM applications a
            JOIN services s ON s.service_id = a.service_id
            JOIN application_statuses ast ON ast.status_id = a.current_status_id
            """;

    private final NamedParameterJdbcTemplate jdbc;

    private final RowMapper<ApplicationSummary> summaryMapper = (result, rowNumber) -> new ApplicationSummary(
            result.getLong("application_id"),
            result.getString("reference_number"),
            result.getLong("citizen_user_id"),
            result.getInt("service_id"),
            result.getString("service_code"),
            result.getString("service_name"),
            result.getString("status_code"),
            result.getString("status_name"),
            result.getString("readiness_status"),
            result.getTimestamp("draft_created_at").toLocalDateTime(),
            toLocalDateTime(result.getTimestamp("submitted_at")),
            toLocalDateTime(result.getTimestamp("decided_at")),
            result.getTimestamp("updated_at").toLocalDateTime()
    );

    public ApplicationRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ApplicationSummary> listByCitizen(long userId) {
        return jdbc.query(
                SUMMARY_SELECT + " WHERE a.citizen_user_id = :userId ORDER BY a.updated_at DESC",
                Map.of("userId", userId),
                summaryMapper
        );
    }

    public List<ApplicationSummary> listSubmitted(String statusCode) {
        String statusFilter = statusCode == null || statusCode.isBlank()
                ? ""
                : " AND ast.status_code = :statusCode";
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        if (!statusFilter.isBlank()) {
            parameters.addValue("statusCode", statusCode);
        }
        return jdbc.query(
                SUMMARY_SELECT + " WHERE a.submitted_at IS NOT NULL" + statusFilter + " ORDER BY a.submitted_at DESC",
                parameters,
                summaryMapper
        );
    }

    public Optional<ApplicationSummary> findById(long applicationId) {
        return jdbc.query(
                        SUMMARY_SELECT + " WHERE a.application_id = :applicationId",
                        Map.of("applicationId", applicationId),
                        summaryMapper)
                .stream()
                .findFirst();
    }

    public long createDraft(long citizenUserId, int serviceId, String referenceNumber) {
        Integer draftStatusId = status("DRAFT").statusId();
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("referenceNumber", referenceNumber)
                .addValue("citizenUserId", citizenUserId)
                .addValue("serviceId", serviceId)
                .addValue("statusId", draftStatusId);
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update("""
                        INSERT INTO applications (
                            reference_number, citizen_user_id, service_id, current_status_id
                        ) VALUES (
                            :referenceNumber, :citizenUserId, :serviceId, :statusId
                        )
                        """,
                parameters,
                keyHolder,
                new String[]{"application_id"});
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("MySQL did not return the generated application ID.");
        }
        return key.longValue();
    }

    public List<ApplicationField> fields(long applicationId) {
        return jdbc.query("""
                        SELECT sf.service_field_id, sf.field_key, sf.field_label, sf.data_type,
                               sf.is_required, sf.display_order, afv.field_value
                        FROM applications a
                        JOIN service_fields sf ON sf.service_id = a.service_id
                        LEFT JOIN application_field_values afv
                               ON afv.application_id = a.application_id
                              AND afv.service_field_id = sf.service_field_id
                        WHERE a.application_id = :applicationId
                        ORDER BY sf.display_order
                        """,
                Map.of("applicationId", applicationId),
                (result, rowNumber) -> new ApplicationField(
                        result.getLong("service_field_id"),
                        result.getString("field_key"),
                        result.getString("field_label"),
                        result.getString("data_type"),
                        result.getBoolean("is_required"),
                        result.getInt("display_order"),
                        result.getString("field_value")
                ));
    }

    public void upsertField(long applicationId, long serviceFieldId, String fieldValue) {
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("applicationId", applicationId)
                .addValue("serviceFieldId", serviceFieldId)
                .addValue("fieldValue", fieldValue);
        jdbc.update("""
                        INSERT INTO application_field_values (
                            application_id, service_field_id, field_value
                        ) VALUES (
                            :applicationId, :serviceFieldId, :fieldValue
                        )
                        ON DUPLICATE KEY UPDATE field_value = :fieldValue
                        """,
                parameters);
    }

    public List<AttachedDocument> documents(long applicationId) {
        return jdbc.query("""
                        SELECT ad.application_document_id, d.document_id, d.document_type_id,
                               dt.type_code, dt.type_name, d.display_name, ad.review_status,
                               ad.review_notes, ad.reviewed_by_user_id, ad.reviewed_at, ad.attached_at
                        FROM application_documents ad
                        JOIN documents d ON d.document_id = ad.document_id
                        JOIN document_types dt ON dt.document_type_id = d.document_type_id
                        WHERE ad.application_id = :applicationId
                        ORDER BY ad.attached_at
                        """,
                Map.of("applicationId", applicationId),
                (result, rowNumber) -> new AttachedDocument(
                        result.getLong("application_document_id"),
                        result.getLong("document_id"),
                        result.getInt("document_type_id"),
                        result.getString("type_code"),
                        result.getString("type_name"),
                        result.getString("display_name"),
                        result.getString("review_status"),
                        result.getString("review_notes"),
                        result.getObject("reviewed_by_user_id", Long.class),
                        toLocalDateTime(result.getTimestamp("reviewed_at")),
                        result.getTimestamp("attached_at").toLocalDateTime()
                ));
    }

    public boolean isDocumentRequired(long applicationId, int documentTypeId) {
        Integer count = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM applications a
                        JOIN service_document_requirements sdr ON sdr.service_id = a.service_id
                        WHERE a.application_id = :applicationId
                          AND sdr.document_type_id = :documentTypeId
                        """,
                Map.of("applicationId", applicationId, "documentTypeId", documentTypeId),
                Integer.class);
        return count != null && count > 0;
    }

    public int maximumDocumentCount(long applicationId, int documentTypeId) {
        Integer maximum = jdbc.queryForObject("""
                        SELECT COALESCE(sdr.maximum_count, 2147483647)
                        FROM applications a
                        JOIN service_document_requirements sdr ON sdr.service_id = a.service_id
                        WHERE a.application_id = :applicationId
                          AND sdr.document_type_id = :documentTypeId
                        """,
                Map.of("applicationId", applicationId, "documentTypeId", documentTypeId),
                Integer.class);
        return maximum == null ? 0 : maximum;
    }

    public int attachedDocumentCount(long applicationId, int documentTypeId) {
        Integer count = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM application_documents ad
                        JOIN documents d ON d.document_id = ad.document_id
                        WHERE ad.application_id = :applicationId
                          AND d.document_type_id = :documentTypeId
                        """,
                Map.of("applicationId", applicationId, "documentTypeId", documentTypeId),
                Integer.class);
        return count == null ? 0 : count;
    }

    public void attachDocument(long applicationId, long documentId) {
        jdbc.update("""
                        INSERT INTO application_documents (application_id, document_id)
                        VALUES (:applicationId, :documentId)
                        """,
                Map.of("applicationId", applicationId, "documentId", documentId));
    }

    public List<String> missingFieldLabels(long applicationId) {
        return jdbc.queryForList("""
                        SELECT sf.field_label
                        FROM applications a
                        JOIN service_fields sf ON sf.service_id = a.service_id
                        LEFT JOIN application_field_values afv
                               ON afv.application_id = a.application_id
                              AND afv.service_field_id = sf.service_field_id
                        WHERE a.application_id = :applicationId
                          AND sf.is_required = TRUE
                          AND (afv.field_value IS NULL OR TRIM(afv.field_value) = '')
                        ORDER BY sf.display_order
                        """,
                Map.of("applicationId", applicationId),
                String.class);
    }

    public List<String> missingDocumentNames(long applicationId) {
        return jdbc.queryForList("""
                        SELECT dt.type_name
                        FROM applications a
                        JOIN service_document_requirements sdr ON sdr.service_id = a.service_id
                        JOIN document_types dt ON dt.document_type_id = sdr.document_type_id
                        WHERE a.application_id = :applicationId
                          AND sdr.is_required = TRUE
                          AND (
                              SELECT COUNT(*)
                              FROM application_documents ad
                              JOIN documents d ON d.document_id = ad.document_id
                              WHERE ad.application_id = a.application_id
                                AND d.document_type_id = sdr.document_type_id
                          ) < sdr.minimum_count
                        ORDER BY sdr.display_order
                        """,
                Map.of("applicationId", applicationId),
                String.class);
    }

    public void resolveChecks(long applicationId) {
        jdbc.update("""
                        UPDATE application_check_results
                        SET resolved_at = CURRENT_TIMESTAMP
                        WHERE application_id = :applicationId AND resolved_at IS NULL
                        """,
                Map.of("applicationId", applicationId));
    }

    public void addCheck(long applicationId, String code, String outcome, String message) {
        jdbc.update("""
                        INSERT INTO application_check_results (
                            application_id, check_type, result_code, outcome, message
                        ) VALUES (
                            :applicationId, 'COMPLETENESS', :code, :outcome, :message
                        )
                        """,
                Map.of(
                        "applicationId", applicationId,
                        "code", code,
                        "outcome", outcome,
                        "message", message
                ));
    }

    public void setReadiness(long applicationId, String readiness) {
        jdbc.update("""
                        UPDATE applications
                        SET readiness_status = :readiness, last_checked_at = CURRENT_TIMESTAMP
                        WHERE application_id = :applicationId
                        """,
                Map.of("applicationId", applicationId, "readiness", readiness));
    }

    public Status status(String statusCode) {
        return jdbc.query("""
                                SELECT status_id, status_code, is_final
                                FROM application_statuses
                                WHERE status_code = :statusCode
                                """,
                        Map.of("statusCode", statusCode),
                        (result, rowNumber) -> new Status(
                                result.getInt("status_id"),
                                result.getString("status_code"),
                                result.getBoolean("is_final")
                        ))
                .stream()
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Application status is not configured: " + statusCode));
    }

    public void transition(long applicationId, long actorUserId, String targetCode, String notes) {
        ApplicationSummary current = findById(applicationId)
                .orElseThrow(() -> new IllegalStateException("Application does not exist."));
        if (current.statusCode().equals(targetCode)) {
            return;
        }
        Status from = status(current.statusCode());
        Status to = status(targetCode);
        jdbc.update("""
                        INSERT INTO application_status_history (
                            application_id, from_status_id, to_status_id, changed_by_user_id, notes
                        ) VALUES (
                            :applicationId, :fromStatusId, :toStatusId, :actorUserId, :notes
                        )
                        """,
                new MapSqlParameterSource()
                        .addValue("applicationId", applicationId)
                        .addValue("fromStatusId", from.statusId())
                        .addValue("toStatusId", to.statusId())
                        .addValue("actorUserId", actorUserId)
                        .addValue("notes", notes));
        jdbc.update("""
                        UPDATE applications
                        SET current_status_id = :toStatusId,
                            submitted_at = CASE
                                WHEN :targetCode = 'SUBMITTED' THEN COALESCE(submitted_at, CURRENT_TIMESTAMP)
                                ELSE submitted_at
                            END,
                            decided_at = CASE
                                WHEN :isFinal = TRUE THEN COALESCE(decided_at, CURRENT_TIMESTAMP)
                                ELSE decided_at
                            END
                        WHERE application_id = :applicationId
                        """,
                Map.of(
                        "toStatusId", to.statusId(),
                        "targetCode", targetCode,
                        "isFinal", to.finalStatus(),
                        "applicationId", applicationId
                ));
    }

    public void addInitialHistory(long applicationId, long actorUserId) {
        Status draft = status("DRAFT");
        jdbc.update("""
                        INSERT INTO application_status_history (
                            application_id, from_status_id, to_status_id,
                            changed_by_user_id, notes
                        ) VALUES (
                            :applicationId, NULL, :draftStatusId,
                            :actorUserId, 'Draft application created.'
                        )
                        """,
                Map.of(
                        "applicationId", applicationId,
                        "draftStatusId", draft.statusId(),
                        "actorUserId", actorUserId
                ));
    }

    public List<StatusHistory> history(long applicationId) {
        return jdbc.query("""
                        SELECT ash.history_id, from_status.status_code AS from_status,
                               to_status.status_code AS to_status, ash.changed_by_user_id,
                               CONCAT(u.first_name, ' ', u.last_name) AS changed_by_name,
                               ash.notes, ash.changed_at
                        FROM application_status_history ash
                        LEFT JOIN application_statuses from_status
                               ON from_status.status_id = ash.from_status_id
                        JOIN application_statuses to_status
                             ON to_status.status_id = ash.to_status_id
                        LEFT JOIN users u ON u.user_id = ash.changed_by_user_id
                        WHERE ash.application_id = :applicationId
                        ORDER BY ash.changed_at, ash.history_id
                        """,
                Map.of("applicationId", applicationId),
                (result, rowNumber) -> new StatusHistory(
                        result.getLong("history_id"),
                        result.getString("from_status"),
                        result.getString("to_status"),
                        result.getObject("changed_by_user_id", Long.class),
                        result.getString("changed_by_name"),
                        result.getString("notes"),
                        result.getTimestamp("changed_at").toLocalDateTime()
                ));
    }

    public void addCorrespondence(
            long applicationId,
            long senderUserId,
            String type,
            String message,
            boolean internal
    ) {
        jdbc.update("""
                        INSERT INTO application_correspondence (
                            application_id, sender_user_id, correspondence_type, message, is_internal
                        ) VALUES (
                            :applicationId, :senderUserId, :type, :message, :internal
                        )
                        """,
                Map.of(
                        "applicationId", applicationId,
                        "senderUserId", senderUserId,
                        "type", type,
                        "message", message,
                        "internal", internal
                ));
    }

    public List<Correspondence> correspondence(long applicationId, boolean includeInternal) {
        String internalFilter = includeInternal ? "" : " AND ac.is_internal = FALSE";
        return jdbc.query("""
                                SELECT ac.correspondence_id, ac.sender_user_id,
                                       CONCAT(u.first_name, ' ', u.last_name) AS sender_name,
                                       ac.correspondence_type, ac.message, ac.is_internal,
                                       ac.created_at, ac.read_at
                                FROM application_correspondence ac
                                JOIN users u ON u.user_id = ac.sender_user_id
                                WHERE ac.application_id = :applicationId
                                """ + internalFilter + " ORDER BY ac.created_at",
                Map.of("applicationId", applicationId),
                (result, rowNumber) -> new Correspondence(
                        result.getLong("correspondence_id"),
                        result.getLong("sender_user_id"),
                        result.getString("sender_name"),
                        result.getString("correspondence_type"),
                        result.getString("message"),
                        result.getBoolean("is_internal"),
                        result.getTimestamp("created_at").toLocalDateTime(),
                        toLocalDateTime(result.getTimestamp("read_at"))
                ));
    }

    public List<CheckResult> checks(long applicationId) {
        return jdbc.query("""
                        SELECT check_result_id, check_type, result_code, outcome,
                               message, checked_at, resolved_at
                        FROM application_check_results
                        WHERE application_id = :applicationId
                        ORDER BY checked_at DESC, check_result_id DESC
                        """,
                Map.of("applicationId", applicationId),
                (result, rowNumber) -> new CheckResult(
                        result.getLong("check_result_id"),
                        result.getString("check_type"),
                        result.getString("result_code"),
                        result.getString("outcome"),
                        result.getString("message"),
                        result.getTimestamp("checked_at").toLocalDateTime(),
                        toLocalDateTime(result.getTimestamp("resolved_at"))
                ));
    }

    public void reviewDocument(long applicationDocumentId, long adminUserId, String status, String notes) {
        jdbc.update("""
                        UPDATE application_documents
                        SET review_status = :status,
                            review_notes = :notes,
                            reviewed_by_user_id = :adminUserId,
                            reviewed_at = CURRENT_TIMESTAMP
                        WHERE application_document_id = :applicationDocumentId
                        """,
                new MapSqlParameterSource()
                        .addValue("status", status)
                        .addValue("notes", notes)
                        .addValue("adminUserId", adminUserId)
                        .addValue("applicationDocumentId", applicationDocumentId));
    }

    public Optional<AttachedDocument> findAttachedDocument(long applicationId, long applicationDocumentId) {
        return documents(applicationId).stream()
                .filter(document -> document.applicationDocumentId() == applicationDocumentId)
                .findFirst();
    }

    public boolean hasUnverifiedDocuments(long applicationId) {
        Integer count = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM application_documents
                        WHERE application_id = :applicationId
                          AND review_status <> 'VERIFIED'
                        """,
                Map.of("applicationId", applicationId),
                Integer.class);
        return count != null && count > 0;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }

    public record Status(int statusId, String statusCode, boolean finalStatus) {
    }
}
