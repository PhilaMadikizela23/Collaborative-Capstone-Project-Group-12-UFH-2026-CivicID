package za.ac.ufh.civicid.document;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record DocumentRecord(
        Long documentId,
        Long ownerUserId,
        Integer documentTypeId,
        String typeCode,
        String typeName,
        String displayName,
        String originalFileName,
        String storageReference,
        String mimeType,
        Long sizeBytes,
        LocalDate issueDate,
        LocalDate expiryDate,
        String verificationStatus,
        LocalDateTime uploadedAt,
        LocalDateTime updatedAt
) {
}
