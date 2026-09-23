package za.ac.ufh.civicid.application;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public final class ApplicationDtos {
    private ApplicationDtos() {
    }

    public record CreateApplicationRequest(@NotNull Integer serviceId) {
    }

    public record SaveFieldValuesRequest(@NotEmpty Map<String, String> fieldValues) {
    }

    public record AddCorrespondenceRequest(
            @NotBlank @Size(max = 5000) String message
    ) {
    }

    public record ApplicationSummary(
            Long applicationId,
            String referenceNumber,
            Long citizenUserId,
            Integer serviceId,
            String serviceCode,
            String serviceName,
            String statusCode,
            String statusName,
            String readinessStatus,
            LocalDateTime draftCreatedAt,
            LocalDateTime submittedAt,
            LocalDateTime decidedAt,
            LocalDateTime updatedAt
    ) {
    }

    public record ApplicationField(
            Long serviceFieldId,
            String fieldKey,
            String fieldLabel,
            String dataType,
            boolean required,
            int displayOrder,
            String fieldValue
    ) {
    }

    public record AttachedDocument(
            Long applicationDocumentId,
            Long documentId,
            Integer documentTypeId,
            String typeCode,
            String typeName,
            String displayName,
            String reviewStatus,
            String reviewNotes,
            Long reviewedByUserId,
            LocalDateTime reviewedAt,
            LocalDateTime attachedAt
    ) {
    }

    public record StatusHistory(
            Long historyId,
            String fromStatus,
            String toStatus,
            Long changedByUserId,
            String changedByName,
            String notes,
            LocalDateTime changedAt
    ) {
    }

    public record Correspondence(
            Long correspondenceId,
            Long senderUserId,
            String senderName,
            String correspondenceType,
            String message,
            boolean internal,
            LocalDateTime createdAt,
            LocalDateTime readAt
    ) {
    }

    public record CheckResult(
            Long checkResultId,
            String checkType,
            String resultCode,
            String outcome,
            String message,
            LocalDateTime checkedAt,
            LocalDateTime resolvedAt
    ) {
    }

    public record ApplicationDetail(
            ApplicationSummary application,
            List<ApplicationField> fields,
            List<AttachedDocument> documents,
            List<StatusHistory> statusHistory,
            List<Correspondence> correspondence,
            List<CheckResult> checks
    ) {
    }

    public record ReadinessResult(
            boolean ready,
            List<String> missingFields,
            List<String> missingDocuments
    ) {
    }
}
