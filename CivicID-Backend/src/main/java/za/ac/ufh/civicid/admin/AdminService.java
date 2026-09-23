package za.ac.ufh.civicid.admin;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.ac.ufh.civicid.application.ApplicationDtos.ApplicationDetail;
import za.ac.ufh.civicid.application.ApplicationDtos.ApplicationSummary;
import za.ac.ufh.civicid.application.ApplicationDtos.AttachedDocument;
import za.ac.ufh.civicid.application.ApplicationRepository;
import za.ac.ufh.civicid.application.ApplicationService;
import za.ac.ufh.civicid.audit.AuditRepository;
import za.ac.ufh.civicid.common.BadRequestException;
import za.ac.ufh.civicid.common.NotFoundException;
import za.ac.ufh.civicid.document.DocumentRepository;
import za.ac.ufh.civicid.notification.NotificationRepository;

import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class AdminService {
    private final ApplicationRepository applications;
    private final ApplicationService applicationService;
    private final DocumentRepository documents;
    private final NotificationRepository notifications;
    private final AuditRepository audit;
    private final AdminRepository adminRepository;

    public AdminService(
            ApplicationRepository applications,
            ApplicationService applicationService,
            DocumentRepository documents,
            NotificationRepository notifications,
            AuditRepository audit,
            AdminRepository adminRepository
    ) {
        this.applications = applications;
        this.applicationService = applicationService;
        this.documents = documents;
        this.notifications = notifications;
        this.audit = audit;
        this.adminRepository = adminRepository;
    }

    public AdminDtos.Dashboard dashboard() {
        return adminRepository.dashboard();
    }

    public List<ApplicationSummary> applications(String status) {
        return applications.listSubmitted(status == null ? null : status.trim().toUpperCase(Locale.ROOT));
    }

    public ApplicationDetail detail(long applicationId) {
        return applicationService.detailAdmin(applicationId);
    }

    @Transactional
    public ApplicationDetail startReview(long applicationId, long adminUserId) {
        ApplicationSummary application = applicationService.requireAny(applicationId);
        if ("UNDER_REVIEW".equals(application.statusCode())) {
            return detail(applicationId);
        }
        if (!List.of("SUBMITTED", "ADDITIONAL_INFORMATION_REQUIRED").contains(application.statusCode())) {
            throw new BadRequestException("Only submitted applications can enter review.");
        }
        applications.transition(
                applicationId,
                adminUserId,
                "UNDER_REVIEW",
                "Administrator started reviewing the application."
        );
        audit.record(
                adminUserId,
                "APPLICATION_REVIEW_STARTED",
                "Started reviewing application " + application.referenceNumber() + ".",
                "APPLICATION",
                applicationId,
                Map.of("referenceNumber", application.referenceNumber())
        );
        return detail(applicationId);
    }

    @Transactional
    public ApplicationDetail reviewDocument(
            long applicationId,
            long applicationDocumentId,
            long adminUserId,
            AdminDtos.ReviewDocumentRequest request
    ) {
        ApplicationSummary application = applicationService.requireAny(applicationId);
        if (!"UNDER_REVIEW".equals(application.statusCode())) {
            throw new BadRequestException("Start the application review before reviewing documents.");
        }
        AttachedDocument document = applications.findAttachedDocument(applicationId, applicationDocumentId)
                .orElseThrow(() -> new NotFoundException("Attached application document not found."));
        String status = request.status().toUpperCase(Locale.ROOT);
        applications.reviewDocument(
                applicationDocumentId,
                adminUserId,
                status,
                request.notes() == null ? null : request.notes().trim()
        );
        documents.setVerificationStatus(document.documentId(), status);
        audit.record(
                adminUserId,
                "APPLICATION_DOCUMENT_REVIEWED",
                "Reviewed an application document.",
                "APPLICATION_DOCUMENT",
                applicationDocumentId,
                Map.of("applicationId", applicationId, "reviewStatus", status)
        );
        return detail(applicationId);
    }

    @Transactional
    public ApplicationDetail decide(
            long applicationId,
            long adminUserId,
            AdminDtos.DecisionRequest request
    ) {
        ApplicationSummary application = applicationService.requireAny(applicationId);
        if (!"UNDER_REVIEW".equals(application.statusCode())) {
            throw new BadRequestException("The application must be under review before a decision is recorded.");
        }
        String action = request.action().toUpperCase(Locale.ROOT);
        String message = request.message() == null ? "" : request.message().trim();
        return switch (action) {
            case "APPROVE" -> approve(application, adminUserId, message);
            case "REJECT" -> reject(application, adminUserId, message);
            case "REQUEST_INFORMATION" -> requestInformation(application, adminUserId, message);
            default -> throw new BadRequestException("Unsupported application decision.");
        };
    }

    @Transactional
    public ApplicationDetail addComment(
            long applicationId,
            long adminUserId,
            AdminDtos.AdminCommentRequest request
    ) {
        ApplicationSummary application = applicationService.requireAny(applicationId);
        applications.addCorrespondence(
                applicationId,
                adminUserId,
                request.internal() ? "SYSTEM_NOTE" : "COMMENT",
                request.message().trim(),
                request.internal()
        );
        if (!request.internal()) {
            notifications.create(
                    application.citizenUserId(),
                    applicationId,
                    "ADMIN_COMMENT",
                    "New Application Message",
                    "A new message was added to application " + application.referenceNumber() + "."
            );
        }
        return detail(applicationId);
    }

    private ApplicationDetail approve(ApplicationSummary application, long adminUserId, String message) {
        if (applications.hasUnverifiedDocuments(application.applicationId())) {
            throw new BadRequestException("Every attached document must be verified before approval.");
        }
        applications.transition(
                application.applicationId(),
                adminUserId,
                "APPROVED",
                message.isBlank() ? "Application approved." : message
        );
        if (!message.isBlank()) {
            applications.addCorrespondence(
                    application.applicationId(), adminUserId, "COMMENT", message, false);
        }
        notifications.create(
                application.citizenUserId(),
                application.applicationId(),
                "APPLICATION_APPROVED",
                "Application Approved",
                "Your application " + application.referenceNumber() + " has been approved."
        );
        auditDecision(application, adminUserId, "APPLICATION_APPROVED", "APPROVED");
        return detail(application.applicationId());
    }

    private ApplicationDetail reject(ApplicationSummary application, long adminUserId, String message) {
        requireMessage(message, "A rejection reason is required.");
        applications.transition(application.applicationId(), adminUserId, "REJECTED", message);
        applications.addCorrespondence(
                application.applicationId(), adminUserId, "COMMENT", message, false);
        notifications.create(
                application.citizenUserId(),
                application.applicationId(),
                "APPLICATION_REJECTED",
                "Application Rejected",
                "Your application " + application.referenceNumber() + " was rejected. Review the administrator message."
        );
        auditDecision(application, adminUserId, "APPLICATION_REJECTED", "REJECTED");
        return detail(application.applicationId());
    }

    private ApplicationDetail requestInformation(
            ApplicationSummary application,
            long adminUserId,
            String message
    ) {
        requireMessage(message, "Describe the additional information that is required.");
        applications.transition(
                application.applicationId(),
                adminUserId,
                "ADDITIONAL_INFORMATION_REQUIRED",
                message
        );
        applications.addCorrespondence(
                application.applicationId(),
                adminUserId,
                "REQUEST_INFORMATION",
                message,
                false
        );
        notifications.create(
                application.citizenUserId(),
                application.applicationId(),
                "ADDITIONAL_INFORMATION_REQUIRED",
                "Additional Information Required",
                "More information is required for application " + application.referenceNumber() + "."
        );
        auditDecision(
                application,
                adminUserId,
                "APPLICATION_INFORMATION_REQUESTED",
                "ADDITIONAL_INFORMATION_REQUIRED"
        );
        return detail(application.applicationId());
    }

    private void auditDecision(
            ApplicationSummary application,
            long adminUserId,
            String action,
            String status
    ) {
        audit.record(
                adminUserId,
                action,
                "Changed application " + application.referenceNumber() + " to " + status + ".",
                "APPLICATION",
                application.applicationId(),
                Map.of("referenceNumber", application.referenceNumber(), "newStatus", status)
        );
    }

    private void requireMessage(String message, String error) {
        if (message.isBlank()) {
            throw new BadRequestException(error);
        }
    }
}
