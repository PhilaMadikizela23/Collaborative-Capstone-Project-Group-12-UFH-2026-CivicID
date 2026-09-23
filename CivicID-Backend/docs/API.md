# CivicID REST API

Default base URL:

```text
http://localhost:8080
```

Authenticated requests use:

```http
Authorization: Bearer ACCESS_TOKEN
```

## Authentication

| Method | Endpoint | Access |
|---|---|---|
| `POST` | `/api/auth/register` | Public |
| `POST` | `/api/auth/login` | Public |
| `GET` | `/api/auth/me` | Authenticated |

Registration request:

```json
{
  "firstName": "Thando",
  "lastName": "Citizen",
  "email": "thando@example.com",
  "password": "fortestudent@333"
}
```

Login request:

```json
{
  "email": "thando@ufh.com",
  "password": "StrongPassword@1"
}
```

## Citizen profile

| Method | Endpoint |
|---|---|
| `GET` | `/api/citizens/me/profile` |
| `PUT` | `/api/citizens/me/profile` |

Profile request:

```json
{
  "nationalIdNumber": "TEST-ID-0002",
  "dateOfBirth": "2004-08-18",
  "phoneNumber": "+27786452992",
  "addressLine1": "2 Test Street",
  "addressLine2": "",
  "city": "East London",
  "province": "Eastern Cape",
  "postalCode": "5201"
}
```

## Catalogue

| Method | Endpoint | Access |
|---|---|---|
| `GET` | `/api/services` | Public |
| `GET` | `/api/services/{serviceId}` | Public |
| `GET` | `/api/document-types` | Public |

## Documents

| Method | Endpoint |
|---|---|
| `GET` | `/api/documents` |
| `POST` | `/api/documents` |
| `GET` | `/api/documents/{documentId}/download` |
| `DELETE` | `/api/documents/{documentId}` |

Document upload uses `multipart/form-data` fields:

```text
documentTypeId
displayName
issueDate
expiryDate
file
```

## Citizen applications

| Method | Endpoint |
|---|---|
| `GET` | `/api/applications` |
| `POST` | `/api/applications` |
| `GET` | `/api/applications/{applicationId}` |
| `PUT` | `/api/applications/{applicationId}/fields` |
| `POST` | `/api/applications/{applicationId}/documents/{documentId}` |
| `POST` | `/api/applications/{applicationId}/check-readiness` |
| `POST` | `/api/applications/{applicationId}/submit` |
| `POST` | `/api/applications/{applicationId}/correspondence` |

Create a Passport application:

```json
{
  "serviceId": 1
}
```

Save dynamic form values:

```json
{
  "fieldValues": {
    "fullName": "Thando Citizen",
    "idNumber": "09030456540002",
    "dateOfBirth": "2009-03-01",
    "phoneNumber": "+27000000001",
    "residentialAddress": "2 Test Street, East London, Eastern Cape, 5201"
  }
}
```

## Notifications

| Method | Endpoint |
|---|---|
| `GET` | `/api/notifications` |
| `GET` | `/api/notifications/unread-count` |
| `PATCH` | `/api/notifications/{notificationId}/read` |

## Administrator

All endpoints require an `ADMIN` token.

| Method | Endpoint |
|---|---|
| `GET` | `/api/admin/dashboard` |
| `GET` | `/api/admin/applications` |
| `GET` | `/api/admin/applications/{applicationId}` |
| `POST` | `/api/admin/applications/{applicationId}/start-review` |
| `PATCH` | `/api/admin/applications/{applicationId}/documents/{applicationDocumentId}` |
| `POST` | `/api/admin/applications/{applicationId}/decision` |
| `POST` | `/api/admin/applications/{applicationId}/comments` |
| `GET` | `/api/admin/documents/{documentId}/download` |
| `GET` | `/api/admin/audit-logs` |

Document review request:

```json
{
  "status": "VERIFIED",
  "notes": "Document reviewed and accepted."
}
```

Decision request:

```json
{
  "action": "APPROVE",
  "message": "All submitted information was verified."
}
```

Other decision actions are `REJECT` and `REQUEST_INFORMATION`.

## Health

```http
GET /api/health
```

This endpoint confirms that the backend can connect to MySQL and reports the detected table and view totals.
