# Fix Role Column Size Error

## Problem
```
Data truncated for column 'role' at row 1
```

The `role` column in the `users` table is too small to store "SPECIALIST" (10 characters).

## Solution

### Option 1: Alter Table (Recommended - Keeps Data)

1. **Connect to MySQL**:
   ```bash
   mysql -u root -p
   ```

2. **Select database**:
   ```sql
   USE signlikdb;
   ```

3. **Alter the column**:
   ```sql
   ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;
   ```

4. **Verify**:
   ```sql
   DESCRIBE users;
   ```
   The `role` column should show `varchar(20)`

5. **Restart backend** and try registration again

### Option 2: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your database
3. Run this SQL:
   ```sql
   USE signlikdb;
   ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;
   ```

### Option 3: Drop and Recreate (WARNING: Deletes All Users)

If you don't have important data:

1. **Stop backend**
2. **Connect to MySQL**:
   ```sql
   mysql -u root -p
   USE signlikdb;
   DROP TABLE users;
   ```
3. **Restart backend** - Hibernate will recreate the table with correct size

### Option 4: Quick Fix Script

I've created `fix-role-column.sql` - you can run it directly:

```bash
mysql -u root -p signlikdb < fix-role-column.sql
```

## After Fixing

1. **Restart backend** (if it's running)
2. **Try registration again** in the frontend
3. It should work now! ✅

## Verification

After fixing, you can verify the column size:
```sql
DESCRIBE users;
```

The `role` column should show `varchar(20)` instead of `varchar(10)` or similar.

