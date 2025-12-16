@echo off
echo Testing MySQL Connection...
echo.
echo Attempting to connect with empty password...
mysql -u root -e "SELECT 1;" 2>nul
if %errorlevel% equ 0 (
    echo SUCCESS: MySQL connection works with empty password!
    echo Update application.properties with: spring.datasource.password=
    goto :end
)

echo Failed with empty password. Trying with 'root' password...
mysql -u root -proot -e "SELECT 1;" 2>nul
if %errorlevel% equ 0 (
    echo SUCCESS: MySQL connection works with password 'root'!
    echo Update application.properties with: spring.datasource.password=root
    goto :end
)

echo Failed with 'root' password. 
echo.
echo Please try the following:
echo 1. Open MySQL Command Line or MySQL Workbench
echo 2. Try connecting with different credentials
echo 3. Once you find the correct password, update application.properties
echo.
echo Common MySQL installations:
echo - XAMPP: Usually empty password
echo - WAMP: Usually empty password  
echo - Standard MySQL: Password set during installation
echo - Docker: Usually 'root' password

:end
pause

