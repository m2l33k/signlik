# SignLik Backend API Test Script
# Run this script in PowerShell to test the API

$baseUrl = "http://localhost:8081"

Write-Host "=== Testing SignLik Backend API ===" -ForegroundColor Green
Write-Host ""

# Test 1: Register a user
Write-Host "1. Registering a new user..." -ForegroundColor Yellow
$registerBody = @{
    username = "test_user"
    email = "test@example.com"
    password = "test123"
    role = "DEAF"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody
    Write-Host "✓ User registered successfully!" -ForegroundColor Green
    Write-Host "  Username: $($registerResponse.username)" -ForegroundColor Cyan
    Write-Host "  Email: $($registerResponse.email)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 2: Login
Write-Host "2. Testing login..." -ForegroundColor Yellow
$loginBody = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host "  Response: $loginResponse" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 3: Send a message
Write-Host "3. Sending a message..." -ForegroundColor Yellow
$messageBody = @{
    content = "Hello from PowerShell test!"
    type = "TEXT"
    sender = @{
        username = "test_user"
        email = "test@example.com"
        password = "test123"
        role = "DEAF"
    }
    receiver = @{
        username = "receiver_user"
        email = "receiver@example.com"
        password = "test123"
        role = "HEARING"
    }
} | ConvertTo-Json -Depth 10

try {
    $messageResponse = Invoke-RestMethod -Uri "$baseUrl/api/messages/send" `
        -Method POST `
        -ContentType "application/json" `
        -Body $messageBody
    Write-Host "✓ Message sent successfully!" -ForegroundColor Green
    Write-Host "  Content: $($messageResponse.content)" -ForegroundColor Cyan
    Write-Host "  Type: $($messageResponse.type)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ Message sending failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 4: Get all messages
Write-Host "4. Retrieving all messages..." -ForegroundColor Yellow
try {
    $messagesResponse = Invoke-RestMethod -Uri "$baseUrl/api/messages/all" `
        -Method GET
    Write-Host "✓ Retrieved messages successfully!" -ForegroundColor Green
    Write-Host "  Total messages: $($messagesResponse.Count)" -ForegroundColor Cyan
    if ($messagesResponse.Count -gt 0) {
        foreach ($msg in $messagesResponse) {
            Write-Host "  - $($msg.content) (Type: $($msg.type), From: $($msg.sender.email))" -ForegroundColor Cyan
        }
    }
    Write-Host ""
} catch {
    Write-Host "✗ Failed to retrieve messages: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "=== Testing Complete ===" -ForegroundColor Green

