# Quick Fix: MySQL Connection Error

## The Problem
You're getting: `Access denied for user 'root'@'localhost' (using password: YES)`

This means your MySQL password is **WRONG** or MySQL is **NOT RUNNING**.

## Quick Solutions (Try in Order)

### Solution 1: Try Empty Password (Most Common for XAMPP/WAMP)

1. Open `src/main/resources/application.properties`
2. Change line 19 from:
   ```properties
   spring.datasource.password=root
   ```
   To:
   ```properties
   spring.datasource.password=
   ```
3. Save and run the application again

### Solution 2: Find Your MySQL Password

#### Option A: Using MySQL Command Line
1. Open Command Prompt or PowerShell
2. Navigate to MySQL bin folder (usually `C:\Program Files\MySQL\MySQL Server 8.0\bin`)
3. Run:
   ```bash
   mysql -u root -p
   ```
4. Try common passwords:
   - Press Enter (empty password)
   - Type `root` and press Enter
   - Type your Windows password
5. When you successfully connect, note the password you used

#### Option B: Using MySQL Workbench
1. Open MySQL Workbench
2. Click on a connection (or create new)
3. Try different passwords:
   - Empty password (leave blank)
   - `root`
   - Your Windows password
4. When connection succeeds, note the password

#### Option C: Check MySQL Configuration
1. Look for MySQL config file:
   - `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini`
   - Or `C:\xampp\mysql\bin\my.ini` (for XAMPP)
2. Search for `password` in the file
3. Or check if there's a default password set

### Solution 3: Reset MySQL Password

If you can't remember your password:

#### For Standard MySQL:
1. Stop MySQL service (Services → MySQL → Stop)
2. Start MySQL in safe mode:
   ```bash
   mysqld --skip-grant-tables
   ```
3. Open a new command prompt and connect:
   ```bash
   mysql -u root
   ```
4. Reset password:
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';
   FLUSH PRIVILEGES;
   ```
5. Stop safe mode MySQL and start normal MySQL service
6. Update `application.properties` with the new password

#### For XAMPP:
1. Open XAMPP Control Panel
2. Stop MySQL
3. Open Command Prompt in XAMPP MySQL bin folder
4. Run:
   ```bash
   mysql -u root
   ```
5. If it works without password, your password is empty
6. Update `application.properties` with empty password

### Solution 4: Check if MySQL is Running

1. Press `Win + R`
2. Type `services.msc` and press Enter
3. Look for **MySQL** service
4. Check if it's **Running**
5. If not, right-click → **Start**

### Solution 5: Use Docker MySQL (Easiest)

If you have Docker installed:

```bash
docker run --name mysql-signlik -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=signlikdb -p 3306:3306 -d mysql:8.0
```

Then in `application.properties`:
```properties
spring.datasource.username=root
spring.datasource.password=root
```

## Update application.properties

Once you know your MySQL password, update `src/main/resources/application.properties`:

```properties
# For empty password:
spring.datasource.password=

# For a specific password:
spring.datasource.password=your_actual_password

# For different username:
spring.datasource.username=your_username
spring.datasource.password=your_password
```

## Test Connection

After updating, run the application. You should see:
```
HikariPool-1 - Start completed.
```

Instead of:
```
Access denied for user 'root'@'localhost'
```

## Still Having Issues?

1. **Check MySQL port**: Make sure MySQL is on port 3306. If not, update the URL:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:YOUR_PORT/signlikdb?...
   ```

2. **Check MySQL version**: Make sure you have MySQL 8.0 or later

3. **Check firewall**: Make sure Windows Firewall isn't blocking MySQL

4. **Check MySQL logs**: Look in MySQL data directory for error logs

5. **Try creating a new MySQL user**:
   ```sql
   CREATE USER 'signlik'@'localhost' IDENTIFIED BY 'signlik123';
   GRANT ALL PRIVILEGES ON signlikdb.* TO 'signlik'@'localhost';
   FLUSH PRIVILEGES;
   ```
   Then use:
   ```properties
   spring.datasource.username=signlik
   spring.datasource.password=signlik123
   ```

## Common Scenarios

| Installation | Username | Password | Port |
|-------------|----------|----------|------|
| XAMPP | root | (empty) | 3306 |
| WAMP | root | (empty) | 3306 |
| Standard MySQL | root | (set during install) | 3306 |
| Docker MySQL | root | root | 3306 |
| MariaDB | root | (empty or set) | 3306 |

## Next Steps

1. ✅ Find your MySQL password
2. ✅ Update `application.properties`
3. ✅ Make sure MySQL is running
4. ✅ Run the application
5. ✅ Verify connection in logs

