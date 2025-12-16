-- Fix role column size in MySQL
-- Run this SQL command in your MySQL database

ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;

-- Or if you want to drop and recreate (WARNING: This will delete all users):
-- DROP TABLE IF EXISTS users;
-- Then restart the application and Hibernate will recreate it with the correct size

