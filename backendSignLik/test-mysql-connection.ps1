# MySQL Connection Test Script
# This script helps you find the correct MySQL password

Write-Host "=== MySQL Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Common passwords to try
$passwords = @("", "root", "admin", "password", "123456", "mysql")

# MySQL connection parameters
$server = "localhost"
$port = "3306"
$username = "root"
$database = "mysql"

Write-Host "Testing connection to MySQL server..." -ForegroundColor Yellow
Write-Host "Server: $server:$port" -ForegroundColor Gray
Write-Host "Username: $username" -ForegroundColor Gray
Write-Host ""

# Check if MySQL is running
Write-Host "Step 1: Checking if MySQL is running..." -ForegroundColor Cyan
$mysqlProcess = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "✓ MySQL process found (PID: $($mysqlProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "✗ MySQL process NOT found. Please start MySQL first." -ForegroundColor Red
    Write-Host ""
    Write-Host "To start MySQL:" -ForegroundColor Yellow
    Write-Host "1. Open Services (Win + R, type 'services.msc')" -ForegroundColor Gray
    Write-Host "2. Find 'MySQL' service" -ForegroundColor Gray
    Write-Host "3. Right-click → Start" -ForegroundColor Gray
    Write-Host ""
    exit
}

Write-Host ""

# Try to find MySQL installation path
Write-Host "Step 2: Looking for MySQL installation..." -ForegroundColor Cyan
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.1\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.xx\bin\mysql.exe",
    "C:\Program Files\MariaDB\*\bin\mysql.exe"
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqlExe = $path
        Write-Host "✓ Found MySQL at: $path" -ForegroundColor Green
        break
    }
}

if (-not $mysqlExe) {
    # Try to find mysql.exe in PATH
    $mysqlExe = Get-Command mysql -ErrorAction SilentlyContinue
    if ($mysqlExe) {
        $mysqlExe = $mysqlExe.Source
        Write-Host "✓ Found MySQL in PATH: $mysqlExe" -ForegroundColor Green
    } else {
        Write-Host "✗ MySQL executable not found." -ForegroundColor Red
        Write-Host "Please ensure MySQL is installed and in your PATH." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "You can test manually by running:" -ForegroundColor Yellow
        Write-Host "  mysql -u root -p" -ForegroundColor Gray
        Write-Host ""
        exit
    }
}

Write-Host ""

# Test common passwords
Write-Host "Step 3: Testing common passwords..." -ForegroundColor Cyan
Write-Host ""

$success = $false
foreach ($password in $passwords) {
    Write-Host "Testing password: '$($password -replace '.', '*')'" -ForegroundColor Gray -NoNewline
    
    $pwdArg = if ($password -eq "") { "" } else { "-p$password" }
    
    # Test connection
    $result = & $mysqlExe -u $username $pwdArg -h $server -P $port -e "SELECT 1;" 2>&1
    
    if ($LASTEXITCODE -eq 0 -or $result -match "mysql") {
        Write-Host " ✓ SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "CORRECT PASSWORD FOUND!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        if ($password -eq "") {
            Write-Host "Password: (empty - leave blank)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Update application.properties:" -ForegroundColor Cyan
            Write-Host "  spring.datasource.password=" -ForegroundColor White
        } else {
            Write-Host "Password: $password" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Update application.properties:" -ForegroundColor Cyan
            Write-Host "  spring.datasource.password=$password" -ForegroundColor White
        }
        Write-Host ""
        $success = $true
        break
    } else {
        Write-Host " ✗ Failed" -ForegroundColor Red
    }
}

if (-not $success) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "COULD NOT CONNECT WITH COMMON PASSWORDS" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try one of the following:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Test manually:" -ForegroundColor Cyan
    Write-Host "   $mysqlExe -u root -p" -ForegroundColor Gray
    Write-Host "   (Enter your password when prompted)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Check MySQL Workbench:" -ForegroundColor Cyan
    Write-Host "   - Open MySQL Workbench" -ForegroundColor Gray
    Write-Host "   - Try to connect with different passwords" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Reset MySQL password:" -ForegroundColor Cyan
    Write-Host "   See QUICK_FIX.md for instructions" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Create a new MySQL user:" -ForegroundColor Cyan
    Write-Host "   See QUICK_FIX.md for instructions" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

