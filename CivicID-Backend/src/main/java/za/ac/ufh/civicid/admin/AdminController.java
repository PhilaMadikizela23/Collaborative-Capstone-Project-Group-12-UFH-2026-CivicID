package za.ac.ufh.civicid.admin;

import jakarta.validation.Valid;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import za.ac.ufh.civicid.application.ApplicationDtos.ApplicationDetail;
import za.ac.ufh.civicid.application.ApplicationDtos.ApplicationSummary;
import za.ac.ufh.civicid.audit.AuditEntry;
import za.ac.ufh.civicid.audit.AuditRepository;
import za.ac.ufh.civicid.document.DocumentController;
import za.ac.ufh.civicid.document.DocumentService;
import za.ac.ufh.civicid.security.AuthenticatedUser;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AdminService admin;
    private final DocumentService documents;
    private final AuditRepository audit;

    public AdminController(AdminService admin, DocumentService documents, AuditRepository audit) {
        this.admin = admin;
        this.documents = documents;
        this.audit = audit;
    }

    @GetMapping("/dashboard")
    public AdminDtos.Dashboard dashboard() {
        return admin.dashboard();
    }

    @GetMapping("/applications")
    public List<ApplicationSummary> applications(@RequestParam(required = false) String status) {
        return admin.applications(status);
    }

    @GetMapping("/applications/{applicationId}")
    public ApplicationDetail detail(@PathVariable long applicationId) {
        return admin.detail(applicationId);
    }

    @PostMapping("/applications/{applicationId}/start-review")
    public ApplicationDetail startReview(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId
    ) {
        return admin.startReview(applicationId, AuthenticatedUser.id(jwt));
    }

    @PatchMapping("/applications/{applicationId}/documents/{applicationDocumentId}")
    public ApplicationDetail reviewDocument(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @PathVariable long applicationDocumentId,
            @Valid @RequestBody AdminDtos.ReviewDocumentRequest request
    ) {
        return admin.reviewDocument(
                applicationId,
                applicationDocumentId,
                AuthenticatedUser.id(jwt),
                request
        );
    }

    @PostMapping("/applications/{applicationId}/decision")
    public ApplicationDetail decide(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @Valid @RequestBody AdminDtos.DecisionRequest request
    ) {
        return admin.decide(applicationId, AuthenticatedUser.id(jwt), request);
    }

    @PostMapping("/applications/{applicationId}/comments")
    public ApplicationDetail comment(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @Valid @RequestBody AdminDtos.AdminCommentRequest request
    ) {
        return admin.addComment(applicationId, AuthenticatedUser.id(jwt), request);
    }

    @GetMapping("/documents/{documentId}/download")
    public ResponseEntity<Resource> download(@PathVariable long documentId) {
        return DocumentController.response(documents.downloadAny(documentId));
    }

    @GetMapping("/audit-logs")
    public List<AuditEntry> auditLogs(@RequestParam(defaultValue = "100") int limit) {
        return audit.list(limit);
    }
}
