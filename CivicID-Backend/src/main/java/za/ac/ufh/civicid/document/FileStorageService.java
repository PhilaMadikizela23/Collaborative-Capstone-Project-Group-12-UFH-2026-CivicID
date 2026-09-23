package za.ac.ufh.civicid.document;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import za.ac.ufh.civicid.common.BadRequestException;
import za.ac.ufh.civicid.common.NotFoundException;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class FileStorageService {
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "application/pdf",
            "image/jpeg",
            "image/png"
    );

    private final Path root;

    public FileStorageService(@Value("${civicid.storage.root}") String root) {
        this.root = Path.of(root).toAbsolutePath().normalize();
    }

    @PostConstruct
    void initialise() {
        try {
            Files.createDirectories(root);
        } catch (IOException exception) {
            throw new IllegalStateException("Unable to create the document storage directory.", exception);
        }
    }

    public StoredFile store(long userId, MultipartFile file) {
        if (file.isEmpty()) {
            throw new BadRequestException("The uploaded file is empty.");
        }
        String contentType = file.getContentType() == null
                ? "application/octet-stream"
                : file.getContentType().toLowerCase(Locale.ROOT);
        if (!ALLOWED_TYPES.contains(contentType)) {
            throw new BadRequestException("Only PDF, JPEG and PNG documents are accepted.");
        }
        String originalName = sanitise(file.getOriginalFilename());
        Path relativePath = Path.of(Long.toString(userId), UUID.randomUUID() + "_" + originalName);
        Path destination = resolve(relativePath.toString());
        try {
            Files.createDirectories(destination.getParent());
            try (InputStream input = file.getInputStream()) {
                Files.copy(input, destination, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException exception) {
            throw new IllegalStateException("The uploaded document could not be stored.", exception);
        }
        return new StoredFile(relativePath.toString().replace('\\', '/'), originalName, contentType, file.getSize());
    }

    public Resource load(String storageReference) {
        Path path = resolve(storageReference);
        if (!Files.exists(path) || !Files.isRegularFile(path)) {
            throw new NotFoundException("The stored document file could not be found.");
        }
        try {
            return new UrlResource(path.toUri());
        } catch (MalformedURLException exception) {
            throw new IllegalStateException("The stored document path is invalid.", exception);
        }
    }

    public void delete(String storageReference) {
        try {
            Files.deleteIfExists(resolve(storageReference));
        } catch (IOException exception) {
            throw new IllegalStateException("The document record was removed but its file could not be deleted.", exception);
        }
    }

    private Path resolve(String storageReference) {
        Path resolved = root.resolve(storageReference).normalize();
        if (!resolved.startsWith(root)) {
            throw new BadRequestException("Invalid document storage path.");
        }
        return resolved;
    }

    private String sanitise(String originalName) {
        String value = originalName == null || originalName.isBlank() ? "document" : originalName;
        value = value.replace('\\', '/');
        value = value.substring(value.lastIndexOf('/') + 1);
        value = value.replaceAll("[^A-Za-z0-9._-]", "_");
        if (value.isBlank()) {
            return "document";
        }
        return value.length() <= 180 ? value : value.substring(value.length() - 180);
    }

    public record StoredFile(
            String storageReference,
            String originalFileName,
            String mimeType,
            long sizeBytes
    ) {
    }
}
