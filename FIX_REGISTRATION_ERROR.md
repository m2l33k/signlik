# Fix Registration 500 Error

## Problem
Registration fails with HTTP 500 error due to activity logging issue.

## Solution Applied
1. Made activity logging non-blocking (won't fail registration if logging fails)
2. Made user field nullable in ActivityLogEntity
3. Added error handling in AuthController

## Steps to Fix

### 1. Restart Backend
- Stop the current backend (if running)
- Restart it in IntelliJ IDEA
- Wait for "Started BackendSignLikApplication"

### 2. Test Registration Again
1. Open frontend: `sign-registration.html`
2. Click "Register as Specialist"
3. Fill in the form
4. Click "Register"

### 3. If Still Failing

Check backend console for the actual error message. Common issues:

**Issue: User already exists**
- Solution: Use a different email/username

**Issue: Database constraint**
- Solution: Check MySQL is running and tables are created

**Issue: Validation error**
- Solution: Make sure all fields are filled (username, email, password)

## Alternative: Test with Postman/HTTP Client

Use the `http-requests.http` file in IntelliJ:

```http
POST http://localhost:8081/api/auth/register
Content-Type: application/json

{
  "username": "test_specialist2",
  "email": "specialist2@test.com",
  "password": "password123",
  "role": "SPECIALIST"
}
```

This will show you the exact error message.

## Quick Test

After restarting backend, try registering again. The error should be fixed now!

