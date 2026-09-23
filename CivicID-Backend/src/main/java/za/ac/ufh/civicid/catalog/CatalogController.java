package za.ac.ufh.civicid.catalog;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static za.ac.ufh.civicid.catalog.CatalogDtos.*;

@RestController
public class CatalogController {
    private final CatalogService catalog;

    public CatalogController(CatalogService catalog) {
        this.catalog = catalog;
    }

    @GetMapping("/api/services")
    public List<ServiceSummary> services() {
        return catalog.services();
    }

    @GetMapping("/api/services/{serviceId}")
    public ServiceDetail service(@PathVariable int serviceId) {
        return catalog.service(serviceId);
    }

    @GetMapping("/api/document-types")
    public List<DocumentType> documentTypes() {
        return catalog.documentTypes();
    }
}
