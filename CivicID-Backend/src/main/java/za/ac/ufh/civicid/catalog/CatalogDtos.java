package za.ac.ufh.civicid.catalog;

import java.util.List;

public final class CatalogDtos {
    private CatalogDtos() {
    }

    public record ServiceSummary(
            Integer serviceId,
            String serviceCode,
            String serviceName,
            String categoryName,
            String departmentName,
            String description,
            boolean active
    ) {
    }

    public record ServiceField(
            Long serviceFieldId,
            String fieldKey,
            String fieldLabel,
            String dataType,
            String prefillSource,
            String helpText,
            boolean required,
            int displayOrder,
            String optionsJson
    ) {
    }

    public record DocumentRequirement(
            Long requirementId,
            Integer documentTypeId,
            String typeCode,
            String typeName,
            boolean required,
            int minimumCount,
            Integer maximumCount,
            String instructions,
            int displayOrder
    ) {
    }

    public record ServiceDetail(
            ServiceSummary service,
            List<ServiceField> fields,
            List<DocumentRequirement> documentRequirements
    ) {
    }

    public record DocumentType(
            Integer documentTypeId,
            String typeCode,
            String typeName,
            String description,
            boolean active
    ) {
    }
}
