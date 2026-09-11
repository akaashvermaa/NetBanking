@echo off
setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0"
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "CATALINA_HOME=D:\TOMCAT\apache-tomcat-9.0.120"
set "PG_JAR=%PROJECT_DIR%WebContent\WEB-INF\lib\postgresql-42.7.4.jar"
set "BCRYPT_JAR=%PROJECT_DIR%WebContent\WEB-INF\lib\jbcrypt-0.4.jar"
set "SERVLET_JAR=%CATALINA_HOME%\lib\servlet-api.jar"
set "CLASSES_DIR=%PROJECT_DIR%WebContent\WEB-INF\classes"
set "SOURCES_FILE=%TEMP%\netbanking_sources.txt"

echo ==================================================
echo  NetBanking - Build and Run
echo ==================================================

if not exist "%CLASSES_DIR%" mkdir "%CLASSES_DIR%"

echo Compiling Java sources...
rem javac's @argfile parser treats backslash as an escape character, which mangles
rem Windows paths - so list sources with forward slashes instead (javac accepts them fine).
(for /r "%PROJECT_DIR%src" %%f in (*.java) do (
    set "p=%%f"
    set "p=!p:\=/!"
    echo "!p!"
)) > "%SOURCES_FILE%"

"%JAVA_HOME%\bin\javac" -cp "%PG_JAR%;%BCRYPT_JAR%;%SERVLET_JAR%" -d "%CLASSES_DIR%" "@%SOURCES_FILE%"
if errorlevel 1 (
    echo.
    echo Compilation FAILED. See errors above.
    pause
    exit /b 1
)
echo Compilation OK.

echo.
echo Starting Tomcat...
call "%CATALINA_HOME%\bin\startup.bat"

echo Waiting for the server to come up...
ping -n 7 127.0.0.1 >nul

echo Opening browser...
start "" "http://localhost:8080/netbanking/login"

echo.
echo Done. NetBanking should now be open in your browser.
echo To stop the server later, run: "%CATALINA_HOME%\bin\shutdown.bat"
echo.
pause
endlocal
