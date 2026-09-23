# CivicID


## UFH  2026 Collaborative Capstone Project — TechTribe (Group 12)

CivicID is a prototype digital citizen profile application designed for South Africa and its citizens. It lets a citizen register, build a secure profile, upload identity/supporting documents, and prepare, check, and track applications for government services (starting with a Home Affairs passport workflow) — with an administrator side to review and process those applications.

## Contents
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Step 1 — Get the code](#step-1--get-the-code)
- [Step 2 — Set up MySQL and the schema](#step-2--set-up-mysql-and-the-schema)
- [Step 3 — Configure and run the backend](#step-3--configure-and-run-the-backend)
- [Step 4 — Configure and run the Flutter app](#step-4--configure-and-run-the-flutter-app)
- [Step 5 — Verify everything is connected](#step-5--verify-everything-is-connected)
- [Core features (MVP)](#core-features-mvp)
- [Roles](#roles)
- [Application lifecycle](#application-lifecycle)
- [Security notes](#security-notes)
- [Troubleshooting](#troubleshooting)
- [Team](#team)

  ## Architecture
 ```text
Flutter app (citizen + admin UI)
        │  HTTPS / JSON
        ▼
Spring Boot REST API  (auth, business rules, validation)
        │  JDBC
        ▼
MySQL 8  (civicid database — 18 tables, 4 views)
```

The Flutter app never talks to MySQL directly — only to the Spring Boot API.


## Project structure

```text
.
├── lib/                   # Flutter mobile app (citizen + admin UI)
├── android/, web/         # Flutter platform targets
├── test/                  # Flutter widget/unit tests
├── assets/                # Images and sounds used by the app
├── pubspec.yaml           # Flutter dependencies
├── CivicID-Backend/       # Spring Boot REST API
│   ├── src/                # Java source (auth, catalog, application, admin, ...)
│   ├── docs/                # API.md, ARCHITECTURE.md, TESTING.md
│   ├── scripts/              # Windows setup helper scripts
│   └── pom.xml
└── CivicID_Database/       # MySQL schema and EER diagram
    ├── CivicID_Database_V2.sql
    └── CivicId_DatabaseEER diagrams.mwb
```

## Prerequisites

Install these before touching the project. Version numbers matter — the backend specifically targets Java 17 and MySQL 8.

| Tool | Version | Check with | Download |
|---|---|---|---|
| Git | any recent | `git --version` | https://git-scm.com/downloads |
| JDK | 17 or newer | `java -version` | https://adoptium.net |
| Apache Maven | 3.6.3+ (or use an IDE with Maven support) | `mvn -version` | https://maven.apache.org/download.cgi |
| MySQL Server | 8.x (8.4 LTS or 9.7 LTS recommended; avoid old 8.0.x builds, EOL April 2026) | `mysql --version` | https://dev.mysql.com/downloads/mysql/ |
| Flutter SDK | matches `^3.13.2` in `pubspec.yaml` | `flutter doctor` | https://docs.flutter.dev/get-started/install |
| Android Studio | latest (for the Android emulator/SDK, even though the app itself is Flutter) | — | https://developer.android.com/studio |

After installing Flutter, run:

```bash
flutter doctor
```

and resolve anything it flags (missing Android licenses, missing Xcode, etc.) before continuing.

## Step 1 — Get the code

```bash
git clone https://github.com/PhilaMadikizela23/Collaborative-Capstone-Project-Group-12-UFH-2026-CivicID.git
cd Collaborative-Capstone-Project-Group-12-UFH-2026-CivicID
```

## Step 2 — Set up MySQL and the schema

1. Make sure the MySQL service is running (starts automatically on most installs; on Windows check the *Services* app for `MySQL80`/`MySQL`).
2. Log in as root and run the schema script, which creates the `civicid` database, its 18 tables, and 4 views:
   ```bash
   mysql -u root -p < CivicID_Database/CivicID_Database_V2.sql
   ```
3. Create a **restricted application user** rather than letting the backend use `root`:
   ```sql
   CREATE USER IF NOT EXISTS 'civicid_app'@'localhost'
   IDENTIFIED BY 'YOUR_PRIVATE_DATABASE_PASSWORD';

   GRANT SELECT, INSERT, UPDATE, DELETE
   ON civicid.*
   TO 'civicid_app'@'localhost';
   ```
   Pick your own password — you'll reference it as an environment variable in Step 3, never hardcoded.
4. (Optional) Open `CivicID_Database/CivicId_DatabaseEER diagrams.mwb` in MySQL Workbench if you want to see the schema visually.

## Step 3 — Configure and run the backend

```bash
cd CivicID-Backend
```

Confirm your Java/Maven install:

```bash
java -version
mvn -version
```

(On Windows you can instead run the included checker: `powershell -ExecutionPolicy Bypass -File .\scripts\check-environment.ps1`.)

Set the required environment variables (macOS/Linux shown; use `$env:NAME="value"` in PowerShell on Windows):

```bash
export CIVICID_DB_PASSWORD="your_private_database_password"
export CIVICID_JWT_SECRET="a_random_secret_of_at_least_32_characters"
export CIVICID_BOOTSTRAP_ADMIN_ENABLED="true"
export CIVICID_BOOTSTRAP_ADMIN_EMAIL="admin@civicid.local"
export CIVICID_BOOTSTRAP_ADMIN_PASSWORD="your_private_admin_password"
```

`CIVICID_BOOTSTRAP_ADMIN_*` creates the first Administrator account on startup. After the first successful run, turn it off:

```bash
export CIVICID_BOOTSTRAP_ADMIN_ENABLED="false"
```

Start the backend (first run needs internet access to download Maven dependencies):

```bash
mvn spring-boot:run
```

Or build and run a standalone JAR:

```bash
mvn clean package
java -jar target/civicid-backend-0.1.0.jar
```

The API listens on `http://localhost:8080`. Full endpoint reference, request/response shapes, and auth flow are in [`CivicID-Backend/docs/API.md`](CivicID-Backend/docs/API.md); module-by-module design in [`ARCHITECTURE.md`](CivicID-Backend/docs/ARCHITECTURE.md); test setup in [`TESTING.md`](CivicID-Backend/docs/TESTING.md).

## Step 4 — Configure and run the Flutter app

From the repository root (not inside `CivicID-Backend`):

```bash
flutter pub get
```

The app's default API base URL is `http://localhost:8080`. Override it for your target device with `--dart-define`:

```bash
# Android emulator (10.0.2.2 is the emulator's alias for your machine's localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Physical phone on the same Wi-Fi as your dev machine
flutter run --dart-define=API_BASE_URL=http://<your-computer-lan-ip>:8080

# Chrome / web target, backend on the same machine
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

List available targets first if unsure which device/emulator to run on:

```bash
flutter devices
```

## Step 5 — Verify everything is connected

1. With the backend running, open `http://localhost:8080/api/health` in a browser. You should see:
   ```text
   tables: 18
   views: 4
   ```
2. Launch the Flutter app and try registering a citizen account, or sign in with the bootstrap admin credentials you set in Step 3.
3. If a request fails, check the base URL you passed with `--dart-define` matches how your device reaches the backend (see the emulator/phone note above).

## Core features (MVP)

- Citizen registration, login, and profile management
- Secure document wallet (PDF/JPEG/PNG uploads)
- Government service catalogue with dynamic application fields
- Document attachment and application completeness checks
- Application submission and status tracking
- Administrator queues, document review, and decisions
- Citizen/admin correspondence and notifications
- Audit logging

## Roles

**Citizen** — registers and signs in, completes a profile, uploads documents, browses services, creates and completes applications, tracks status, reads messages.

**Administrator** — views dashboard totals and submitted applications, reviews documents, requests more information, approves or rejects applications, views audit logs.

## Application lifecycle

```text
DRAFT → READY → SUBMITTED → UNDER_REVIEW → APPROVED
                                 │      └──→ REJECTED
                                 └──→ ADDITIONAL_INFORMATION_REQUIRED → SUBMITTED
```

## Security notes

- Never commit passwords, JWT secrets, `.env` files, or real citizen records.
- Never place the MySQL password inside the Flutter/Android app — it only ever talks to the REST API.
- Keep MySQL's port (`3306`) closed to anything outside the backend host.
- Use HTTPS for any deployed (non-local) backend.
- Uploaded files are stored in the backend's local `uploads` directory during development; use managed object storage for a real deployment.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `flutter doctor` shows Android toolchain errors | Open Android Studio → SDK Manager and accept licenses (`flutter doctor --android-licenses`) |
| Backend fails to start with a JDBC/connection error | MySQL isn't running, or `CIVICID_DB_PASSWORD` doesn't match the `civicid_app` user you created |
| App can't reach the backend from an emulator | You're using `localhost` instead of `10.0.2.2` in `API_BASE_URL` |
| App can't reach the backend from a physical phone | Phone and dev machine aren't on the same Wi-Fi, or a firewall is blocking port 8080 on the dev machine |
| `mvn spring-boot:run` hangs on first run | Normal — first build downloads all dependencies; needs internet access |

## Team
| Name | Student Number | Role |
|---|---|---|
| Abahle Mati | 224015316 | Group leader |
| Lukhanyile Mthwazi | 224056213 | Project group leader and Developer Coordinator  |
| Phila Madikizela | 202310277 | Assignment group leader and repo & version control coordinator |
| Velly Mkhonto | 225029469  | Research coordinator |
| Asive Hohwana |202249082  | Documentation coordinator |
| Tlou Ngoepe | 224091788  | Presentation group leader and coordinator |
| Anda Kosi | 202354899  | System design coordinator |
| Ayabonga Luphelile | 202372918  | Slide design coordinator |
| Mivuyo Duntsa | 225023474  | Testing and Q&A coordinator |
| Aseza Makhosi | 225038576  | Communication and scheduling coordinator |
| Funanani Magadzu | 224102681| Report editor |
| Amahle Ngwane | 224063322 | support and logistics coordinator|
| Phumelelo Qoza |  225000045  | requirements gathering coordinator |
| Mlondiwa L | 225058499 | developer |





