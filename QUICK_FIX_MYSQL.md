# Quick Fix: MySQL Password Issue

## Problem
MySQL is running but rejecting the connection with "Access denied for user 'root'@'localhost'"

## Solution Steps

### Step 1: Find Your MySQL Password

**Try these in order:**

1. **Empty Password** (Most common with XAMPP/WAMP):
   - In `application.properties`, set: `spring.datasource.password=`
   - Rebuild and restart

2. **Password "root"**:
   - In `application.properties`, set: `spring.datasource.password=root`
   - Rebuild and restart

3. **Test with MySQL Command Line**:
   ```bash
   # Find MySQL bin directory (usually one of these):
   # XAMPP: C:\xampp\mysql\bin
   # WAMP: C:\wamp64\bin\mysql\mysql8.x.x\bin
   # Standard: C:\Program Files\MySQL\MySQL Server 8.0\bin
   
   # Try connecting (enter password when prompted):
   mysql -u root -p
   ```

4. **Check MySQL Workbench**:
   - Open MySQL Workbench
   - Check existing connections for the password
   - Or try creating a new connection and test different passwords

### Step 2: Update application.properties

Once you know the password, update line 19 in `src/main/resources/application.properties`:

```properties
# For empty password:
spring.datasource.password=

# For password 'root':
spring.datasource.password=root

# For other password:
spring.datasource.password=your_actual_password
```

### Step 3: Clean and Rebuild

After updating the password:

```bash
# In the project directory:
mvn clean compile
```

Then restart the application.

### Step 4: Verify Connection

When the application starts successfully, you should see:
```
HikariPool-1 - Start completed.
```

## Alternative: Reset MySQL Password

If you can't find the password, reset it:

### For XAMPP:
1. Stop MySQL in XAMPP Control Panel
2. Open `C:\xampp\mysql\bin\my.ini`
3. Under `[mysqld]`, add: `skip-grant-tables`
4. Save and restart MySQL
5. Connect: `mysql -u root` (no password)
6. Run these commands:
   ```sql
   USE mysql;
   UPDATE user SET authentication_string='' WHERE User='root';
   FLUSH PRIVILEGES;
   ```
7. Remove `skip-grant-tables` from my.ini
8. Restart MySQL
9. Set password in application.properties to empty: `spring.datasource.password=`

### For Standard MySQL:
1. Stop MySQL service
2. Create `reset.txt` file with:
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
   ```
3. Start MySQL with:
   ```bash
   mysqld --init-file=C:\path\to\reset.txt
   ```
4. Once started, delete reset.txt
5. Set password in application.properties: `spring.datasource.password=root`

## Still Not Working?

Run the test script:
```bash
test-mysql-connection.bat
```

Or check `TROUBLESHOOT_MYSQL.md` for more detailed instructions.

