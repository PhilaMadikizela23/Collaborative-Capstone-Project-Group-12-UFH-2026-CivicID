package za.ac.ufh.civicid.application;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.ac.ufh.civicid.audit.AuditRepository;
import za.ac.ufh.civicid.catalog.CatalogDtos;
import za.ac.ufh.civicid.catalog.CatalogRepository;
import za.ac.ufh.civicid.common.BadRequestException;
import za.ac.ufh.civicid.common.ConflictException;
import za.ac.ufh.civicid.common.NotFoundException;
import za.ac.ufh.civicid.document.DocumentRecord;
import za.ac.ufh.civicid.document.DocumentService;
import za.ac.ufh.civicid.notification.NotificationRepository;
import za.ac.ufh.civicid.user.ProfileRepository;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import static za.ac.ufh.civicid.application.ApplicationDtos.*;

@Service
public class ApplicationService {
    private final ApplicationRepository applications;
    private final CatalogRepository catalog;
    private final ProfileRepository profiles;
    private final DocumentService documents;
    private final NotificationRepository notifications;
    private final AuditRepository audit;

    public ApplicationService(
            ApplicationRepository applications,
            CatalogRepository catalog,
            ProfileRepository profiles,
            DocumentService documents,
            NotificationRepository notifications,
            AuditRepository audit
    ) {
        this.applications = applications;
        this.catalog = catalog;
        this.profiles = profiles;
        this.documents = documents;
        this.notifications = notifications;
        this.audit = audit;
    }

    public List<ApplicationSummary> mine(long userId) {
        return applications.listByCitizen(userId);
    }

    public ApplicationDetail detailOwned(long applicationId, long userId) {
        ApplicationSummary application = requireOwned(applicationId, userId);
        return detail(application, false);
    }

    public ApplicationDetail detailAdmin(long applicationId) {
        ApplicationSummary application = requireAny(applicationId);
        return detail(application, true);
    }

    @Transactional
    public ApplicationDetail create(long userId, CreateApplicationRequest request) {
        if (profiles.findByUserId(userId).isEmpty()) {
            throw new BadRequestException("Complete your Citizen profile before starting an application.");
        }
        CatalogDtos.ServiceSummary service = catalog.findService(request.serviceId(), false)
                .orElseThrow(() -> new NotFoundException("Government service not found or is not active."));
        long applicationId = createWithUniqueReference(userId, service.serviceId());
        applications.addInitialHistory(applicationId, userId);
        audit.record(
                userId,
                "APPLICATION_CREATED",
                "Created a draft application.",
                "APPLICATION",
                applicationId,
                Map.of("serviceCode", service.serviceCode())
        );
        return detailOwned(applicationId, userId);
    }

    @Transactional
    public ApplicationDetail saveFields(
            long applicationId,
            long userId,
            SaveFieldValuesRequest request
    ) {
        ApplicationSummary application = requireEditableOwned(applicationId, userId);
        List<ApplicationField> configuredFields = applications.fields(applicationId);
        Map<String, ApplicationField> byKey = new HashMap<>();
        configuredFields.forEach(field -> byKey.put(field.fieldKey(), field));
        for (Map.Entry<String, String> supplied : request.fieldValues().entrySet()) {
            ApplicationField field = byKey.get(supplied.getKey());
            if (field == null) {
                throw new BadRequestException("Unknown application field: " + supplied.getKey());
            }
            String value = supplied.getValue() == null ? null : supplied.getValue().trim();
            applications.upsertField(applicationId, field.serviceFieldId(), value);
        }
        resetReadiness(application, userId);
        audit.record(
                userId,
                "APPLICATION_FIELDS_UPDATED",
                "Updated application form information.",
                "APPLICATION",
                applicationId,
                Map.of("updatedFieldCount", request.fieldValues().size())
        );
        return detailOwned(applicationId, userId);
    }

    @Transactional
    public ApplicationDetail attachDocument(long applicationId, long documentId, long userId) {
        ApplicationSummary application = requireEditableOwned(applicationId, userId);
        DocumentRecord document = documents.requireOwned(documentId, userId);
        if (!applications.isDocumentRequired(applicationId, document.documentTypeId())) {
            throw new BadRequestException("This document type is not accepted for the selected service.");
        }
        boolean alreadyAttached = applications.documents(applicationId).stream()
                .anyMatch(item -> item.documentId() == documentId);
        if (alreadyAttached) {
            throw new ConflictException("The document is already attached to this application.");
        }
        int maximum = applications.maximumDocumentCount(applicationId, document.documentTypeId());
        int attached = applications.attachedDocumentCount(applicationId, document.documentTypeId());
        if (attached >= maximum) {
            throw new ConflictException("The maximum number of documents for this type has been reached.");
        }
        applications.attachDocument(applicationId, documentId);
        resetReadiness(application, userId);
        audit.record(
                userId,
                "APPLICATION_DOCUMENT_ATTACHED",
                "Attached a document to an application.",
                "APPLICATION",
                applicationId,
                Map.of("documentId", documentId)
        );
        return detailOwned(applicationId, userId);
    }

    @Transactional
    public ReadinessResult checkReadiness(long applicationId, long userId) {
        ApplicationSummary application = requireEditableOwned(applicationId, userId);
        List<String> missingFields = applications.missingFieldLabels(applicationId);
        List<String> missingDocuments = applications.missingDocumentNames(applicationId);
        applications.resolveChecks(applicationId);
        for (String field : missingFields) {
            applications.addCheck(
                    applicationId,
                    code("MISSING_FIELD_", field),
                    "FAILED",
                    field + " is required."
            );
        }
        for (String document : missingDocuments) {
            applications.addCheck(
                    applicationId,
                    code("MISSING_DOCUMENT_", document),
                    "FAILED",
                    document + " is required."
            );
        }
        boolean ready = missingFields.isEmpty() && missingDocuments.isEmpty();
        if (ready) {
            applications.addCheck(
                    applicationId,
                    "APPLICATION_COMPLETE",
                    "PASSED",
                    "All required information and documents are present."
            );
            applications.setReadiness(applicationId, "READY");
            if ("DRAFT".equals(application.statusCode())) {
                applications.transition(applicationId, userId, "READY", "All application requirements were completed.");
            }
        } else {
            applications.setReadiness(applicationId, "INCOMPLETE");
            if ("READY".equals(application.statusCode())) {
                applications.transition(applicationId, userId, "DRAFT", "Application requirements became incomplete.");
            }
        }
        return new ReadinessResult(ready, missingFields, missingDocuments);
    }

    @Transactional
    public ApplicationDetail submit(long applicationId, long userId) {
        ApplicationSummary application = requireEditableOwned(applicationId, userId);
        ReadinessResult readiness = checkReadiness(applicationId, userId);
        if (!readiness.ready()) {
            throw new BadRequestException("The application cannot be submitted because required information is missing.");
        }
        applications.transition(applicationId, userId, "SUBMITTED", "Application submitted by the Citizen.");
        ApplicationSummary submitted = requireAny(applicationId);
        notifications.create(
                userId,
                applicationId,
                "APPLICATION_SUBMITTED",
                "Application Submitted",
                "Your application " + submitted.referenceNumber() + " was submitted successfully."
        );
        audit.record(
                userId,
                "APPLICATION_SUBMITTED",
                "Submitted application " + submitted.referenceNumber() + ".",
                "APPLICATION",
                applicationId,
                Map.of("referenceNumber", submitted.referenceNumber())
        );
        return detailOwned(applicationId, userId);
    }

    @Transactional
    public ApplicationDetail respond(
            long applicationId,
            long userId,
            AddCorrespondenceRequest request
    ) {
        ApplicationSummary application = requireOwned(applicationId, userId);
        if ("DRAFT".equals(application.statusCode()) || "READY".equals(application.statusCode())) {
            throw new BadRequestException("Correspondence becomes available after an application is submitted.");
        }
        applications.addCorrespondence(
                applicationId,
                userId,
                "CITIZEN_RESPONSE",
                request.message().trim(),
                false
        );
        return detailOwned(applicationId, userId);
    }

    public ApplicationSummary requireOwned(long applicationId, long userId) {
        ApplicationSummary application = requireAny(applicationId);
        if (application.citizenUserId() != userId) {
            throw new NotFoundException("Application not found.");
        }
        return application;
    }

    public ApplicationSummary requireAny(long applicationId) {
        return applications.findById(applicationId)
                .orElseThrow(() -> new NotFoundException("Application not found."));
    }

    private ApplicationSummary requireEditableOwned(long applicationId, long userId) {
        ApplicationSummary application = requireOwned(applicationId, userId);
        if (!List.of("DRAFT", "READY", "ADDITIONAL_INFORMATION_REQUIRED").contains(application.statusCode())) {
            throw new BadRequestException("A submitted application can no longer be edited.");
        }
        return application;
    }

    private ApplicationDetail detail(ApplicationSummary application, boolean includeInternal) {
        return new ApplicationDetail(
                application,
                applications.fields(application.applicationId()),
                applications.documents(application.applicationId()),
                applications.history(application.applicationId()),
                applications.correspondence(application.applicationId(), includeInternal),
                applications.checks(application.applicationId())
        );
    }

    private void resetReadiness(ApplicationSummary application, long actorUserId) {
        applications.setReadiness(application.applicationId(), "NOT_CHECKED");
        if ("READY".equals(application.statusCode())) {
            applications.transition(
                    application.applicationId(),
                    actorUserId,
                    "DRAFT",
                    "Application information changed after its readiness check."
            );
        }
    }

    private long createWithUniqueReference(long userId, int serviceId) {
        for (int attempt = 0; attempt < 5; attempt++) {
            try {
                return applications.createDraft(userId, serviceId, reference());
            } catch (DataIntegrityViolationException exception) {
                if (attempt == 4) {
                    throw exception;
                }
            }
        }
        throw new IllegalStateException("A unique application reference could not be generated.");
    }

    private String reference() {
        String date = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        String random = UUID.randomUUID().toString().replace("-", "")
                .substring(0, 8)
                .toUpperCase(Locale.ROOT);
        return "CIV-" + date + "-" + random;
    }

    private String code(String prefix, String value) {
        String code = prefix + value.toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9]+", "_");
        return code.length() <= 80 ? code : code.substring(0, 80);
    }
}
