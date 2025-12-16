# MySQL Setup Guide

## Problem: Access Denied Error

If you're seeing `Access denied for user 'root'@'localhost' (using password: YES)`, follow these steps:

## Step 1: Check if MySQL is Running

### Windows:
1. Open **Services** (Win + R, type `services.msc`)
2. Look for **MySQL** service
3. Make sure it's **Running**
4. If not running, right-click → **Start**

### Alternative (Command Line):
```bash
# Check if MySQL is running
netstat -an | findstr 3306
```

## Step 2: Verify Your MySQL Credentials

### Option A: Using MySQL Command Line
1. Open Command Prompt or PowerShell
2. Navigate to MySQL bin directory (usually `C:\Program Files\MySQL\MySQL Server 8.0\bin`)
3. Run:
   ```bash
   mysql -u root -p
   ```
4. Enter your password when prompted
5. If it works, note down your username and password

### Option B: Using MySQL Workbench
1. Open MySQL Workbench
2. Try to connect with different credentials:
   - `root` / `root`
   - `root` / ` ` (empty password)
   - `root` / your actual password

## Step 3: Check Common MySQL Installations

### XAMPP:
- Username: `root`
- Password: `` (empty - leave it blank)
- Port: `3306`

### WAMP:
- Username: `root`
- Password: `` (empty - leave it blank)
- Port: `3306`

### Standard MySQL Installation:
- Username: `root`
- Password: (the password you set during installation)
- Port: `3306`

### Docker MySQL:
```bash
docker run --name mysql-signlik -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=signlikdb -p 3306:3306 -d mysql:8.0
```
- Username: `root`
- Password: `root`
- Port: `3306`

## Step 4: Update application.properties

Edit `src/main/resources/application.properties`:

```properties
# If your MySQL has NO password:
spring.datasource.password=

# If your MySQL has a different password:
spring.datasource.password=your_actual_password

# If your MySQL is on a different port (e.g., 3307):
spring.datasource.url=jdbc:mysql://localhost:3307/signlikdb?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

## Step 5: Create Database (Optional)

Spring Boot will create the database automatically, but if you want to create it manually:

```sql
CREATE DATABASE IF NOT EXISTS signlikdb;
```

## Step 6: Reset MySQL Root Password (If Needed)

If you forgot your MySQL root password:

### Windows:
1. Stop MySQL service
2. Create a text file with:
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
   ```
3. Start MySQL with:
   ```bash
   mysqld --init-file=C:\path\to\your\file.txt
   ```

### Or use MySQL Installer:
1. Open MySQL Installer
2. Click **Reconfigure** on your MySQL Server
3. Set a new root password
4. Update `application.properties` with the new password

## Step 7: Test Connection

After updating `application.properties`, try running the application again. You should see:
```
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
```

## Troubleshooting

### Error: "Unknown database 'signlikdb'"
- Solution: The database will be created automatically. If not, create it manually:
  ```sql
  CREATE DATABASE signlikdb;
  ```

### Error: "Access denied"
- Solution: Verify username and password in `application.properties`
- Try connecting with MySQL Workbench first to verify credentials

### Error: "Connection refused" or "Can't connect to MySQL server"
- Solution: Make sure MySQL service is running
- Check if port 3306 is available
- Verify MySQL is listening on the correct port

### Error: "Communications link failure"
- Solution: Check if MySQL is running
- Verify firewall isn't blocking port 3306
- Check MySQL configuration file (`my.ini` or `my.cnf`)

## Quick Test Script

Create a file `test-mysql-connection.java`:

```java
import java.sql.Connection;
import java.sql.DriverManager;

public class TestMySQLConnection {
    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/signlikdb?useSSL=false",
                "root",
                "root"  // Change this to your password
            );
            System.out.println("Connection successful!");
            conn.close();
        } catch (Exception e) {
            System.out.println("Connection failed: " + e.getMessage());
        }
    }
}
```

## Need Help?

If you're still having issues:
1. Check MySQL error logs (usually in `C:\ProgramData\MySQL\MySQL Server 8.0\Data\`)
2. Verify MySQL version: `mysql --version`
3. Check MySQL configuration: Look for `my.ini` or `my.cnf` file
4. Try connecting with MySQL Workbench or phpMyAdmin to verify credentials

