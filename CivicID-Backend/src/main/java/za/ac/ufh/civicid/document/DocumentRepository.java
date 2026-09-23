package za.ac.ufh.civicid.document;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class DocumentRepository {
    private static final String SELECT_DOCUMENT = """
            SELECT d.document_id, d.owner_user_id, d.document_type_id,
                   dt.type_code, dt.type_name, d.display_name, d.original_file_name,
                   d.storage_reference, d.mime_type, d.size_bytes, d.issue_date,
                   d.expiry_date, d.verification_status, d.uploaded_at, d.updated_at
            FROM documents d
            JOIN document_types dt ON dt.document_type_id = d.document_type_id
            """;

    private final NamedParameterJdbcTemplate jdbc;

    private final RowMapper<DocumentRecord> mapper = (result, rowNumber) -> new DocumentRecord(
            result.getLong("document_id"),
            result.getLong("owner_user_id"),
            result.getInt("document_type_id"),
            result.getString("type_code"),
            result.getString("type_name"),
            result.getString("display_name"),
            result.getString("original_file_name"),
            result.getString("storage_reference"),
            result.getString("mime_type"),
            result.getObject("size_bytes", Long.class),
            toLocalDate(result.getDate("issue_date")),
            toLocalDate(result.getDate("expiry_date")),
            result.getString("verification_status"),
            result.getTimestamp("uploaded_at").toLocalDateTime(),
            result.getTimestamp("updated_at").toLocalDateTime()
    );

    public DocumentRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<DocumentRecord> listByOwner(long userId) {
        return jdbc.query(
                SELECT_DOCUMENT + " WHERE d.owner_user_id = :userId ORDER BY d.uploaded_at DESC",
                Map.of("userId", userId),
                mapper
        );
    }

    public Optional<DocumentRecord> findById(long documentId) {
        return jdbc.query(
                        SELECT_DOCUMENT + " WHERE d.document_id = :documentId",
                        Map.of("documentId", documentId),
                        mapper)
                .stream()
                .findFirst();
    }

    public long insert(
            long userId,
            int documentTypeId,
            String displayName,
            String originalFileName,
            String storageReference,
            String mimeType,
            long sizeBytes,
            LocalDate issueDate,
            LocalDate expiryDate
    ) {
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("userId", userId)
                .addValue("documentTypeId", documentTypeId)
                .addValue("displayName", displayName)
                .addValue("originalFileName", originalFileName)
                .addValue("storageReference", storageReference)
                .addValue("mimeType", mimeType)
                .addValue("sizeBytes", sizeBytes)
                .addValue("issueDate", issueDate)
                .addValue("expiryDate", expiryDate);
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update("""
                        INSERT INTO documents (
                            owner_user_id, document_type_id, display_name, original_file_name,
                            storage_reference, mime_type, size_bytes, issue_date, expiry_date
                        ) VALUES (
                            :userId, :documentTypeId, :displayName, :originalFileName,
                            :storageReference, :mimeType, :sizeBytes, :issueDate, :expiryDate
                        )
                        """,
                parameters,
                keyHolder,
                new String[]{"document_id"});
        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("MySQL did not return the generated document ID.");
        }
        return key.longValue();
    }

    public boolean isAttached(long documentId) {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM application_documents WHERE document_id = :documentId",
                Map.of("documentId", documentId),
                Integer.class
        );
        return count != null && count > 0;
    }

    public void delete(long documentId) {
        jdbc.update("DELETE FROM documents WHERE document_id = :documentId", Map.of("documentId", documentId));
    }

    public void setVerificationStatus(long documentId, String status) {
        jdbc.update("""
                        UPDATE documents
                        SET verification_status = :status
                        WHERE document_id = :documentId
                        """,
                Map.of("status", status, "documentId", documentId));
    }

    private LocalDate toLocalDate(Date date) {
        return date == null ? null : date.toLocalDate();
    }
}
