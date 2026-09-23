CREATE DATABASE IF NOT EXISTS civicid
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE civicid;

CREATE TABLE IF NOT EXISTS roles (
    role_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_code VARCHAR(30) NOT NULL,
    role_name VARCHAR(60) NOT NULL,
    description VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id),
    UNIQUE KEY uq_roles_code (role_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_id SMALLINT UNSIGNED NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    account_status ENUM('ACTIVE', 'SUSPENDED', 'DISABLED') NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_email (email),
    KEY ix_users_role (role_id),
    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles (role_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS citizen_profiles (
    profile_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    national_id_number VARCHAR(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    address_line_1 VARCHAR(150) NOT NULL,
    address_line_2 VARCHAR(150) NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id),
    UNIQUE KEY uq_citizen_profiles_user (user_id),
    UNIQUE KEY uq_citizen_profiles_national_id (national_id_number),
    CONSTRAINT fk_citizen_profiles_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS service_categories (
    category_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_service_categories_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS services (
    service_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_id SMALLINT UNSIGNED NULL,
    service_code VARCHAR(50) NOT NULL,
    service_name VARCHAR(150) NOT NULL,
    department_name VARCHAR(150) NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (service_id),
    UNIQUE KEY uq_services_code (service_code),
    UNIQUE KEY uq_services_name (service_name),
    KEY ix_services_category (category_id),
    CONSTRAINT fk_services_category
        FOREIGN KEY (category_id) REFERENCES service_categories (category_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS service_fields (
    service_field_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    service_id INT UNSIGNED NOT NULL,
    field_key VARCHAR(100) NOT NULL,
    field_label VARCHAR(150) NOT NULL,
    data_type ENUM('TEXT', 'TEXTAREA', 'DATE', 'NUMBER', 'BOOLEAN', 'EMAIL', 'PHONE', 'SELECT') NOT NULL,
    prefill_source VARCHAR(120) NULL,
    help_text VARCHAR(255) NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    display_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    options_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (service_field_id),
    UNIQUE KEY uq_service_fields_key (service_id, field_key),
    KEY ix_service_fields_order (service_id, display_order),
    CONSTRAINT fk_service_fields_service
        FOREIGN KEY (service_id) REFERENCES services (service_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS document_types (
    document_type_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    type_code VARCHAR(50) NOT NULL,
    type_name VARCHAR(120) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (document_type_id),
    UNIQUE KEY uq_document_types_code (type_code),
    UNIQUE KEY uq_document_types_name (type_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS service_document_requirements (
    requirement_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    service_id INT UNSIGNED NOT NULL,
    document_type_id SMALLINT UNSIGNED NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    minimum_count SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    maximum_count SMALLINT UNSIGNED NULL DEFAULT 1,
    instructions VARCHAR(255) NULL,
    display_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (requirement_id),
    UNIQUE KEY uq_service_document_requirement (service_id, document_type_id),
    KEY ix_service_document_requirement_type (document_type_id),
    CONSTRAINT chk_service_document_requirement_counts
        CHECK (maximum_count IS NULL OR maximum_count >= minimum_count),
    CONSTRAINT fk_service_document_requirement_service
        FOREIGN KEY (service_id) REFERENCES services (service_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_service_document_requirement_type
        FOREIGN KEY (document_type_id) REFERENCES document_types (document_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS documents (
    document_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    owner_user_id BIGINT UNSIGNED NOT NULL,
    document_type_id SMALLINT UNSIGNED NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    original_file_name VARCHAR(255) NOT NULL,
    storage_reference VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT UNSIGNED NULL,
    issue_date DATE NULL,
    expiry_date DATE NULL,
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (document_id),
    KEY ix_documents_owner (owner_user_id),
    KEY ix_documents_type (document_type_id),
    KEY ix_documents_verification (verification_status),
    CONSTRAINT chk_documents_dates
        CHECK (expiry_date IS NULL OR issue_date IS NULL OR expiry_date >= issue_date),
    CONSTRAINT fk_documents_owner
        FOREIGN KEY (owner_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_documents_type
        FOREIGN KEY (document_type_id) REFERENCES document_types (document_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_statuses (
    status_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    status_code VARCHAR(40) NOT NULL,
    status_name VARCHAR(80) NOT NULL,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    display_order SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (status_id),
    UNIQUE KEY uq_application_statuses_code (status_code),
    UNIQUE KEY uq_application_statuses_name (status_name),
    UNIQUE KEY uq_application_statuses_order (display_order)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS applications (
    application_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    reference_number VARCHAR(30) NOT NULL,
    citizen_user_id BIGINT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    current_status_id SMALLINT UNSIGNED NOT NULL,
    readiness_status ENUM('NOT_CHECKED', 'INCOMPLETE', 'READY') NOT NULL DEFAULT 'NOT_CHECKED',
    draft_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_checked_at DATETIME NULL,
    submitted_at DATETIME NULL,
    decided_at DATETIME NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (application_id),
    UNIQUE KEY uq_applications_reference (reference_number),
    KEY ix_applications_citizen (citizen_user_id),
    KEY ix_applications_service (service_id),
    KEY ix_applications_status_submitted (current_status_id, submitted_at),
    CONSTRAINT chk_applications_decision_date
        CHECK (decided_at IS NULL OR submitted_at IS NULL OR decided_at >= submitted_at),
    CONSTRAINT fk_applications_citizen
        FOREIGN KEY (citizen_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_applications_service
        FOREIGN KEY (service_id) REFERENCES services (service_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_applications_current_status
        FOREIGN KEY (current_status_id) REFERENCES application_statuses (status_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_field_values (
    application_field_value_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    application_id BIGINT UNSIGNED NOT NULL,
    service_field_id BIGINT UNSIGNED NOT NULL,
    field_value TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (application_field_value_id),
    UNIQUE KEY uq_application_field_value (application_id, service_field_id),
    KEY ix_application_field_values_field (service_field_id),
    CONSTRAINT fk_application_field_values_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_application_field_values_service_field
        FOREIGN KEY (service_field_id) REFERENCES service_fields (service_field_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_documents (
    application_document_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    application_id BIGINT UNSIGNED NOT NULL,
    document_id BIGINT UNSIGNED NOT NULL,
    review_status ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    review_notes TEXT NULL,
    reviewed_by_user_id BIGINT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    attached_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (application_document_id),
    UNIQUE KEY uq_application_document (application_id, document_id),
    KEY ix_application_documents_document (document_id),
    KEY ix_application_documents_reviewer (reviewed_by_user_id),
    KEY ix_application_documents_review_status (review_status),
    CONSTRAINT fk_application_documents_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_application_documents_document
        FOREIGN KEY (document_id) REFERENCES documents (document_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_application_documents_reviewer
        FOREIGN KEY (reviewed_by_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_status_history (
    history_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    application_id BIGINT UNSIGNED NOT NULL,
    from_status_id SMALLINT UNSIGNED NULL,
    to_status_id SMALLINT UNSIGNED NOT NULL,
    changed_by_user_id BIGINT UNSIGNED NULL,
    notes TEXT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (history_id),
    KEY ix_application_status_history_timeline (application_id, changed_at),
    KEY ix_application_status_history_actor (changed_by_user_id),
    KEY ix_application_status_history_from (from_status_id),
    KEY ix_application_status_history_to (to_status_id),
    CONSTRAINT fk_application_status_history_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_application_status_history_from
        FOREIGN KEY (from_status_id) REFERENCES application_statuses (status_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_application_status_history_to
        FOREIGN KEY (to_status_id) REFERENCES application_statuses (status_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_application_status_history_actor
        FOREIGN KEY (changed_by_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_correspondence (
    correspondence_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    application_id BIGINT UNSIGNED NOT NULL,
    sender_user_id BIGINT UNSIGNED NOT NULL,
    correspondence_type ENUM('COMMENT', 'REQUEST_INFORMATION', 'CITIZEN_RESPONSE', 'SYSTEM_NOTE') NOT NULL DEFAULT 'COMMENT',
    message TEXT NOT NULL,
    is_internal BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME NULL,
    PRIMARY KEY (correspondence_id),
    KEY ix_application_correspondence_timeline (application_id, created_at),
    KEY ix_application_correspondence_sender (sender_user_id),
    CONSTRAINT fk_application_correspondence_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_application_correspondence_sender
        FOREIGN KEY (sender_user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS application_check_results (
    check_result_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    application_id BIGINT UNSIGNED NOT NULL,
    check_type ENUM('COMPLETENESS', 'CONSISTENCY') NOT NULL,
    result_code VARCHAR(80) NOT NULL,
    outcome ENUM('PASSED', 'FAILED', 'WARNING') NOT NULL,
    message VARCHAR(500) NOT NULL,
    service_field_id BIGINT UNSIGNED NULL,
    document_type_id SMALLINT UNSIGNED NULL,
    checked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME NULL,
    PRIMARY KEY (check_result_id),
    KEY ix_application_check_results_application (application_id, checked_at),
    KEY ix_application_check_results_field (service_field_id),
    KEY ix_application_check_results_document_type (document_type_id),
    CONSTRAINT fk_application_check_results_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_application_check_results_field
        FOREIGN KEY (service_field_id) REFERENCES service_fields (service_field_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_application_check_results_document_type
        FOREIGN KEY (document_type_id) REFERENCES document_types (document_type_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    application_id BIGINT UNSIGNED NULL,
    notification_type VARCHAR(60) NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME NULL,
    PRIMARY KEY (notification_id),
    KEY ix_notifications_user_read (user_id, read_at),
    KEY ix_notifications_application (application_id),
    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notifications_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NULL,
    action_type VARCHAR(80) NOT NULL,
    description VARCHAR(500) NOT NULL,
    entity_type VARCHAR(80) NULL,
    entity_id BIGINT UNSIGNED NULL,
    device_info VARCHAR(255) NULL,
    ip_address VARCHAR(45) NULL,
    metadata JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audit_id),
    KEY ix_audit_logs_created (created_at),
    KEY ix_audit_logs_user (user_id),
    KEY ix_audit_logs_action (action_type),
    KEY ix_audit_logs_entity (entity_type, entity_id),
    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO roles (role_id, role_code, role_name, description) VALUES
    (1, 'CITIZEN', 'Citizen', 'Citizen-facing CivicID account'),
    (2, 'ADMIN', 'Administrator', 'Application review and system administration account');

INSERT IGNORE INTO application_statuses
    (status_id, status_code, status_name, is_final, display_order) VALUES
    (1, 'DRAFT', 'Draft', FALSE, 1),
    (2, 'READY', 'Ready to Submit', FALSE, 2),
    (3, 'SUBMITTED', 'Submitted', FALSE, 3),
    (4, 'UNDER_REVIEW', 'Under Review', FALSE, 4),
    (5, 'ADDITIONAL_INFORMATION_REQUIRED', 'Additional Information Required', FALSE, 5),
    (6, 'APPROVED', 'Approved', TRUE, 6),
    (7, 'REJECTED', 'Rejected', TRUE, 7),
    (8, 'CANCELLED', 'Cancelled', TRUE, 8);

INSERT IGNORE INTO service_categories
    (category_id, category_name, description, is_active) VALUES
    (1, 'Home Affairs', 'Identity, citizenship and civil-registration services', TRUE),
    (2, 'Police Services', 'Police and personal-record services', TRUE),
    (3, 'Transport', 'Driving and vehicle-related services', TRUE),
    (4, 'Social Services', 'Social support and benefit services', TRUE);

INSERT IGNORE INTO document_types
    (document_type_id, type_code, type_name, description, is_active) VALUES
    (1, 'SA_ID', 'South African Identity Document', 'Identity document or Smart ID record', TRUE),
    (2, 'PROOF_OF_RESIDENCE', 'Proof of Residence', 'Document confirming the citizen address', TRUE),
    (3, 'PASSPORT_PHOTO', 'Passport Photograph', 'Passport-format photograph for the prototype workflow', TRUE),
    (4, 'BIRTH_CERTIFICATE', 'Birth Certificate', 'Birth registration certificate', TRUE);

INSERT IGNORE INTO services
    (service_id, category_id, service_code, service_name, department_name, description, is_active) VALUES
    (1, 1, 'PASSPORT_APPLICATION', 'Passport Application', 'Department of Home Affairs', 'Mock passport application used for the CivicID prototype', TRUE),
    (2, 1, 'SMART_ID_APPLICATION', 'Smart ID Application', 'Department of Home Affairs', 'Planned future CivicID service', FALSE),
    (3, 1, 'BIRTH_CERTIFICATE_REQUEST', 'Birth Certificate Request', 'Department of Home Affairs', 'Planned future CivicID service', FALSE),
    (4, 2, 'POLICE_CLEARANCE_REQUEST', 'Police Clearance Request', 'South African Police Service', 'Planned future CivicID service', FALSE);

INSERT IGNORE INTO service_fields
    (service_field_id, service_id, field_key, field_label, data_type, prefill_source, help_text, is_required, display_order) VALUES
    (1, 1, 'fullName', 'Full Name', 'TEXT', 'USER_FULL_NAME', 'Applicant full name', TRUE, 1),
    (2, 1, 'idNumber', 'Identity Number', 'TEXT', 'CITIZEN_PROFILE.NATIONAL_ID_NUMBER', 'South African identity number', TRUE, 2),
    (3, 1, 'dateOfBirth', 'Date of Birth', 'DATE', 'CITIZEN_PROFILE.DATE_OF_BIRTH', NULL, TRUE, 3),
    (4, 1, 'phoneNumber', 'Phone Number', 'PHONE', 'CITIZEN_PROFILE.PHONE_NUMBER', NULL, TRUE, 4),
    (5, 1, 'residentialAddress', 'Residential Address', 'TEXTAREA', 'CITIZEN_PROFILE.ADDRESS', NULL, TRUE, 5);

INSERT IGNORE INTO service_document_requirements
    (requirement_id, service_id, document_type_id, is_required, minimum_count, maximum_count, instructions, display_order) VALUES
    (1, 1, 1, TRUE, 1, 1, 'Attach the citizen identity document used for the prototype application', 1),
    (2, 1, 2, TRUE, 1, 1, 'Attach a current proof of residence', 2),
    (3, 1, 3, TRUE, 1, 1, 'Attach a passport-format photograph', 3);

CREATE OR REPLACE VIEW vw_admin_application_queue AS
SELECT
    a.application_id,
    a.reference_number,
    a.submitted_at,
    CONCAT(u.first_name, ' ', u.last_name) AS applicant_name,
    s.service_name,
    ast.status_code,
    ast.status_name
FROM applications AS a
JOIN users AS u
    ON u.user_id = a.citizen_user_id
JOIN services AS s
    ON s.service_id = a.service_id
JOIN application_statuses AS ast
    ON ast.status_id = a.current_status_id
WHERE a.submitted_at IS NOT NULL;

CREATE OR REPLACE VIEW vw_application_form_data AS
SELECT
    a.application_id,
    a.reference_number,
    sf.field_key,
    sf.field_label,
    sf.data_type,
    afv.field_value,
    sf.display_order
FROM application_field_values AS afv
JOIN applications AS a
    ON a.application_id = afv.application_id
JOIN service_fields AS sf
    ON sf.service_field_id = afv.service_field_id;

CREATE OR REPLACE VIEW vw_admin_document_queue AS
SELECT
    ad.application_document_id,
    a.reference_number,
    CONCAT(u.first_name, ' ', u.last_name) AS applicant_name,
    d.document_id,
    d.display_name,
    dt.type_name AS document_type,
    ad.review_status,
    ad.attached_at,
    ad.reviewed_at
FROM application_documents AS ad
JOIN applications AS a
    ON a.application_id = ad.application_id
JOIN users AS u
    ON u.user_id = a.citizen_user_id
JOIN documents AS d
    ON d.document_id = ad.document_id
JOIN document_types AS dt
    ON dt.document_type_id = d.document_type_id;

CREATE OR REPLACE VIEW vw_system_audit_logs AS
SELECT
    al.audit_id,
    al.created_at,
    al.action_type,
    al.description,
    al.entity_type,
    al.entity_id,
    al.device_info,
    al.ip_address,
    CASE
        WHEN u.user_id IS NULL THEN 'System or anonymous user'
        ELSE CONCAT(u.first_name, ' ', u.last_name)
    END AS actor_name
FROM audit_logs AS al
LEFT JOIN users AS u
    ON u.user_id = al.user_id;
