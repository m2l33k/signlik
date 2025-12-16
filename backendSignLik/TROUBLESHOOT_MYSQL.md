# MySQL Connection Troubleshooting

## Current Status
- ✅ MySQL is running on port 3306
- ❌ Connection is being rejected with "Access denied"

## Quick Test

Run the test script to check your MySQL credentials:
```bash
test-mysql-connection.bat
```

## Manual Testing

### Option 1: Using MySQL Command Line

1. Open Command Prompt
2. Navigate to MySQL bin directory (usually):
   - XAMPP: `C:\xampp\mysql\bin`
   - WAMP: `C:\wamp64\bin\mysql\mysql8.x.x\bin`
   - Standard MySQL: `C:\Program Files\MySQL\MySQL Server 8.0\bin`

3. Try connecting with empty password:
   ```bash
   mysql -u root
   ```

4. If that fails, try with password:
   ```bash
   mysql -u root -p
   ```
   (Enter your password when prompted)

### Option 2: Using MySQL Workbench

1. Open MySQL Workbench
2. Try to create a new connection with:
   - Username: `root`
   - Password: (try empty first, then your password)
   - Host: `localhost`
   - Port: `3306`

### Option 3: Check MySQL Service

1. Open Services (Win + R → `services.msc`)
2. Find MySQL service
3. Right-click → Properties
4. Check the service name and status

## Common Solutions

### Solution 1: Empty Password (XAMPP/WAMP)

If you're using XAMPP or WAMP, the password is usually empty:

```properties
spring.datasource.password=
```

### Solution 2: Reset MySQL Root Password

If you forgot your MySQL password:

#### For XAMPP:
1. Stop MySQL in XAMPP Control Panel
2. Open `C:\xampp\mysql\bin\my.ini`
3. Under `[mysqld]`, add: `skip-grant-tables`
4. Start MySQL
5. Connect: `mysql -u root`
6. Run:
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY '';
   FLUSH PRIVILEGES;
   ```
7. Remove `skip-grant-tables` from my.ini
8. Restart MySQL

#### For Standard MySQL:
1. Stop MySQL service
2. Create a text file `reset.txt` with:
   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
   ```
3. Start MySQL with:
   ```bash
   mysqld --init-file=C:\path\to\reset.txt
   ```

### Solution 3: Create New MySQL User

If you can't access root, create a new user:

```sql
CREATE USER 'signlik'@'localhost' IDENTIFIED BY 'signlik123';
GRANT ALL PRIVILEGES ON signlikdb.* TO 'signlik'@'localhost';
FLUSH PRIVILEGES;
```

Then update `application.properties`:
```properties
spring.datasource.username=signlik
spring.datasource.password=signlik123
```

## Update application.properties

Once you find the correct password, update `src/main/resources/application.properties`:

```properties
# For empty password:
spring.datasource.password=

# For password 'root':
spring.datasource.password=root

# For custom password:
spring.datasource.password=your_password_here
```

## After Updating

1. **Clean and rebuild** the project:
   ```bash
   mvn clean compile
   ```

2. **Restart the application**

3. **Check logs** for successful connection:
   ```
   HikariPool-1 - Start completed.
   ```

## Still Having Issues?

1. Check MySQL error logs:
   - XAMPP: `C:\xampp\mysql\data\*.err`
   - Standard: `C:\ProgramData\MySQL\MySQL Server 8.0\Data\*.err`

2. Verify MySQL version:
   ```bash
   mysql --version
   ```

3. Check if there are multiple MySQL installations:
   ```bash
   Get-Service | Where-Object {$_.DisplayName -like "*MySQL*"}
   ```

4. Try connecting with different users:
   - `root@localhost`
   - `root@127.0.0.1`
   - `root@%`

## Need More Help?

If you're still stuck, provide:
1. How you installed MySQL (XAMPP, WAMP, standalone, Docker)
2. Output of `mysql --version`
3. Whether you can connect via MySQL Workbench
4. Any error messages from MySQL logs

