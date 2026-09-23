$failed = $false

Write-Host "Checking Java..."
if (Get-Command java -ErrorAction SilentlyContinue) {
    $javaOutput = java -version 2>&1
    $javaOutput
    $versionLine = $javaOutput | Select-Object -First 1
    if ($versionLine -match 'version "(?<major>\d+)') {
        $javaMajor = [int]$Matches.major
        if ($javaMajor -lt 17) {
            Write-Host "Java 17 or newer is required."
            $failed = $true
        }
    } else {
        Write-Host "The Java version could not be identified."
        $failed = $true
    }
} else {
    Write-Host "Java was not found. Install JDK 17 or newer and reopen PowerShell."
    $failed = $true
}

Write-Host ""
Write-Host "Checking Maven..."
if (Get-Command mvn -ErrorAction SilentlyContinue) {
    mvn -version
} else {
    Write-Host "Maven was not found. Install Maven 3.6.3 or newer, or open the project in an IDE with Maven support."
    $failed = $true
}

if ($failed) {
    exit 1
}

Write-Host ""
Write-Host "The development environment is ready."
