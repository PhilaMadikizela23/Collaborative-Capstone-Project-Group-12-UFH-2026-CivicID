package za.ac.ufh.civicid.document;

import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import za.ac.ufh.civicid.catalog.CatalogRepository;
import za.ac.ufh.civicid.common.BadRequestException;
import za.ac.ufh.civicid.common.ConflictException;
import za.ac.ufh.civicid.common.NotFoundException;

import java.time.LocalDate;
import java.util.List;

@Service
public class DocumentService {
    private final DocumentRepository documents;
    private final CatalogRepository catalog;
    private final FileStorageService storage;

    public DocumentService(
            DocumentRepository documents,
            CatalogRepository catalog,
            FileStorageService storage
    ) {
        this.documents = documents;
        this.catalog = catalog;
        this.storage = storage;
    }

    public List<DocumentRecord> mine(long userId) {
        return documents.listByOwner(userId);
    }

    @Transactional
    public DocumentRecord upload(
            long userId,
            int documentTypeId,
            String displayName,
            LocalDate issueDate,
            LocalDate expiryDate,
            MultipartFile file
    ) {
        if (!catalog.documentTypeExists(documentTypeId)) {
            throw new BadRequestException("The selected document type is invalid.");
        }
        if (displayName == null || displayName.isBlank() || displayName.length() > 150) {
            throw new BadRequestException("A document display name of up to 150 characters is required.");
        }
        if (issueDate != null && expiryDate != null && expiryDate.isBefore(issueDate)) {
            throw new BadRequestException("The document expiry date cannot be before its issue date.");
        }
        FileStorageService.StoredFile stored = storage.store(userId, file);
        try {
            long documentId = documents.insert(
                    userId,
                    documentTypeId,
                    displayName.trim(),
                    stored.originalFileName(),
                    stored.storageReference(),
                    stored.mimeType(),
                    stored.sizeBytes(),
                    issueDate,
                    expiryDate
            );
            return requireOwned(documentId, userId);
        } catch (RuntimeException exception) {
            storage.delete(stored.storageReference());
            throw exception;
        }
    }

    public DocumentRecord requireOwned(long documentId, long userId) {
        DocumentRecord document = requireAny(documentId);
        if (document.ownerUserId() != userId) {
            throw new NotFoundException("Document not found.");
        }
        return document;
    }

    public DocumentRecord requireAny(long documentId) {
        return documents.findById(documentId)
                .orElseThrow(() -> new NotFoundException("Document not found."));
    }

    public Download downloadOwned(long documentId, long userId) {
        DocumentRecord document = requireOwned(documentId, userId);
        return new Download(document, storage.load(document.storageReference()));
    }

    public Download downloadAny(long documentId) {
        DocumentRecord document = requireAny(documentId);
        return new Download(document, storage.load(document.storageReference()));
    }

    @Transactional
    public void delete(long documentId, long userId) {
        DocumentRecord document = requireOwned(documentId, userId);
        if (documents.isAttached(documentId)) {
            throw new ConflictException("A document attached to an application cannot be deleted.");
        }
        documents.delete(documentId);
        storage.delete(document.storageReference());
    }

    public record Download(DocumentRecord document, Resource resource) {
    }
}
