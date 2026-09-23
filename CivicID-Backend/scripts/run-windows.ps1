$dbPassword = Read-Host "CivicID MySQL password"
$jwtSecret = Read-Host "JWT secret with at least 32 characters"
$env:CIVICID_DB_PASSWORD = $dbPassword
$env:CIVICID_JWT_SECRET = $jwtSecret
mvn spring-boot:run
