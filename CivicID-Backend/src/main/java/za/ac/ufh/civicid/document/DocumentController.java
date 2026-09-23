package za.ac.ufh.civicid.document;

import org.springframework.core.io.Resource;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import za.ac.ufh.civicid.security.AuthenticatedUser;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {
    private final DocumentService documents;

    public DocumentController(DocumentService documents) {
        this.documents = documents;
    }

    @GetMapping
    public List<DocumentRecord> mine(@AuthenticationPrincipal Jwt jwt) {
        return documents.mine(AuthenticatedUser.id(jwt));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public DocumentRecord upload(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam int documentTypeId,
            @RequestParam String displayName,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate issueDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate expiryDate,
            @RequestParam MultipartFile file
    ) {
        return documents.upload(
                AuthenticatedUser.id(jwt),
                documentTypeId,
                displayName,
                issueDate,
                expiryDate,
                file
        );
    }

    @GetMapping("/{documentId}/download")
    public ResponseEntity<Resource> download(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable long documentId
    ) {
        return response(documents.downloadOwned(documentId, AuthenticatedUser.id(jwt)));
    }

    @DeleteMapping("/{documentId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal Jwt jwt, @PathVariable long documentId) {
        documents.delete(documentId, AuthenticatedUser.id(jwt));
    }

    public static ResponseEntity<Resource> response(DocumentService.Download download) {
        DocumentRecord document = download.document();
        ContentDisposition disposition = ContentDisposition.attachment()
                .filename(document.originalFileName())
                .build();
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(document.mimeType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .body(download.resource());
    }
}
