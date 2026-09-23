# CivicID Backend

CivicID Backend is a Spring Boot REST API for the CivicID Android application. It connects the tested `civicid` MySQL schema to Citizen and Administrator interfaces.

## Implemented MVP features

- Citizen registration and login
- BCrypt password hashing
- JWT access tokens and role-based access
- Citizen profile creation and updates
- Government service catalogue
- Secure PDF, JPEG and PNG document uploads
- Draft applications and dynamic service fields
- Document attachment and completeness checking
- Application submission and status history
- Administrator queues, document review and decisions
- Citizen/Admin correspondence
- Notifications, dashboard totals and audit logs
- Database health endpoint

## Technology

- Java 17
- Spring Boot 3.5.16
- Spring Web MVC
- Spring Security and signed JWT tokens
- Spring JDBC
- MySQL 8
- Maven

## Project structure

```text
src/main/java/za/ac/ufh/civicid
├── admin
├── application
├── audit
├── auth
├── bootstrap
├── catalog
├── common
├── document
├── health
├── notification
├── security
└── user
```

## 1. Requirements

Install:

- JDK 17 or newer
- Apache Maven 3.6.3 or newer, or an IDE with Maven support
- MySQL Server 8

Check the installations in PowerShell:

```powershell
java -version
mvn -version
```

Or run the included environment check from the project folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-environment.ps1
```

The Java output must show version `17` or newer. If Java or Maven is missing, install it before continuing. The first Maven build needs internet access so that it can download the project dependencies.

## 2. Prepare MySQL

The database must already exist. If it does not, execute:

```text
../CivicID_Database/CivicID_Database_V2.sql
```

Create the restricted application account while connected as MySQL `root`:

```sql
CREATE USER IF NOT EXISTS 'civicid_app'@'localhost'
IDENTIFIED BY 'YOUR_PRIVATE_DATABASE_PASSWORD';

GRANT SELECT, INSERT, UPDATE, DELETE
ON civicid.*
TO 'civicid_app'@'localhost';
```

## 3. Set private environment variables

Open PowerShell in the project folder. Replace the example values and do not commit them to GitHub:

```powershell
$env:CIVICID_DB_PASSWORD="your_private_database_password"
$env:CIVICID_JWT_SECRET="replace_this_with_a_random_secret_of_at_least_32_characters"
$env:CIVICID_BOOTSTRAP_ADMIN_ENABLED="true"
$env:CIVICID_BOOTSTRAP_ADMIN_EMAIL="admin@civicid.local"
$env:CIVICID_BOOTSTRAP_ADMIN_PASSWORD="your_private_admin_password"
```

The optional bootstrap settings create or reset one Administrator account. After the first successful start, set:

```powershell
$env:CIVICID_BOOTSTRAP_ADMIN_ENABLED="false"
```

## 4. Start the backend

```powershell
mvn spring-boot:run
```

When the backend starts, open:

```text
http://localhost:8080/api/health
```

Expected database totals:

```text
tables: 18
views: 4
```

## 5. Build a runnable JAR

```powershell
mvn clean package
java -jar target/civicid-backend-0.1.0.jar
```

## Android connection addresses

| Android environment | Backend base address |
|---|---|
| Android emulator | `http://10.0.2.2:8080` |
| Physical phone on the same Wi-Fi | `http://YOUR_COMPUTER_IP:8080` |
| Backend on the same computer | `http://localhost:8080` |

`localhost` on a physical phone refers to the phone, not the development computer. For a phone demonstration, allow Java through Windows Firewall and keep MySQL and the backend running.

## File storage

Uploaded files are placed in the local `uploads` directory. MySQL stores their metadata and `storage_reference`. Use managed object storage for a deployed production system.

## Important security rules

- Never place the MySQL password inside the Android application.
- Never commit passwords, JWT secrets, `.env` files or real Citizen records.
- Keep MySQL port `3306` private.
- The Android app communicates with the REST API, not directly with MySQL.
- Use HTTPS when the backend is deployed.

See [API.md](docs/API.md), [ARCHITECTURE.md](docs/ARCHITECTURE.md) and [TESTING.md](docs/TESTING.md).
