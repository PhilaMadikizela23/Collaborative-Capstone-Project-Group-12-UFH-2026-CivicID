package za.ac.ufh.civicid.catalog;

import org.springframework.stereotype.Service;
import za.ac.ufh.civicid.common.NotFoundException;

import java.util.List;

import static za.ac.ufh.civicid.catalog.CatalogDtos.*;

@Service
public class CatalogService {
    private final CatalogRepository catalog;

    public CatalogService(CatalogRepository catalog) {
        this.catalog = catalog;
    }

    public List<ServiceSummary> services() {
        return catalog.listActiveServices();
    }

    public ServiceDetail service(int serviceId) {
        ServiceSummary service = catalog.findService(serviceId, false)
                .orElseThrow(() -> new NotFoundException("Government service not found or is not active."));
        return new ServiceDetail(service, catalog.fields(serviceId), catalog.requirements(serviceId));
    }

    public List<DocumentType> documentTypes() {
        return catalog.documentTypes();
    }
}
