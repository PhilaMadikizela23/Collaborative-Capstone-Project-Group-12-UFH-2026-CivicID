# CivicID Backend Testing Guide

## Startup test

1. Start MySQL.
2. Set the required environment variables.
3. Run `mvn spring-boot:run`.
4. Open `http://localhost:8080/api/health`.
5. Confirm status `UP`, database `civicid`, 18 tables and 4 views.

## Citizen workflow

1. Register a new Citizen.
2. Copy the returned access token.
3. Save the Citizen profile.
4. Read the available services and requirements.
5. Upload the three Passport documents.
6. Create a draft Passport application.
7. Save the five form values.
8. Attach the uploaded documents.
9. Run the readiness check.
10. Submit the application.
11. Confirm a notification and status-history records exist.

## Administrator workflow

1. Log in using the bootstrapped Administrator account.
2. View the submitted application queue.
3. Open the application detail.
4. Start the review.
5. Verify all three documents.
6. Add an Administrator comment.
7. Approve the application.
8. Confirm the Citizen receives an approval notification.
9. Confirm the action appears in the audit log.

## Negative tests

- Register an already-used email and expect HTTP `409`.
- Log in with the wrong password and expect HTTP `400`.
- Access an Administrator endpoint with a Citizen token and expect HTTP `403`.
- Access another Citizen's application and expect HTTP `404`.
- Upload an unsupported file type and expect HTTP `400`.
- Submit an incomplete application and expect HTTP `400`.
- Approve an application with unverified documents and expect HTTP `400`.

## Database verification

After the workflow, verify:

```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM applications;
SELECT COUNT(*) FROM application_status_history;
SELECT COUNT(*) FROM notifications;
SELECT COUNT(*) FROM audit_logs;
```

No test should require direct changes to primary or foreign keys.
