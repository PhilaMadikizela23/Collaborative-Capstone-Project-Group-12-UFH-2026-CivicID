package za.ac.ufh.civicid.application;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import za.ac.ufh.civicid.security.AuthenticatedUser;

import java.util.List;

import static za.ac.ufh.civicid.application.ApplicationDtos.*;

@RestController
@RequestMapping("/api/applications")
public class ApplicationController {
    private final ApplicationService applications;

    public ApplicationController(ApplicationService applications) {
        this.applications = applications;
    }

    @GetMapping
    public List<ApplicationSummary> mine(@AuthenticationPrincipal Jwt jwt) {
        return applications.mine(AuthenticatedUser.id(jwt));
    }

    @GetMapping("/{applicationId}")
    public ApplicationDetail detail(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId
    ) {
        return applications.detailOwned(applicationId, AuthenticatedUser.id(jwt));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApplicationDetail create(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreateApplicationRequest request
    ) {
        return applications.create(AuthenticatedUser.id(jwt), request);
    }

    @PutMapping("/{applicationId}/fields")
    public ApplicationDetail saveFields(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @Valid @RequestBody SaveFieldValuesRequest request
    ) {
        return applications.saveFields(applicationId, AuthenticatedUser.id(jwt), request);
    }

    @PostMapping("/{applicationId}/documents/{documentId}")
    public ApplicationDetail attachDocument(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @PathVariable long documentId
    ) {
        return applications.attachDocument(applicationId, documentId, AuthenticatedUser.id(jwt));
    }

    @PostMapping("/{applicationId}/check-readiness")
    public ReadinessResult checkReadiness(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId
    ) {
        return applications.checkReadiness(applicationId, AuthenticatedUser.id(jwt));
    }

    @PostMapping("/{applicationId}/submit")
    public ApplicationDetail submit(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId
    ) {
        return applications.submit(applicationId, AuthenticatedUser.id(jwt));
    }

    @PostMapping("/{applicationId}/correspondence")
    public ApplicationDetail respond(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long applicationId,
            @Valid @RequestBody AddCorrespondenceRequest request
    ) {
        return applications.respond(applicationId, AuthenticatedUser.id(jwt), request);
    }
}
