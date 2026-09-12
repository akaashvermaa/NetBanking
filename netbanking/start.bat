@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "PROJECT_DIR=%~dp0"
set "TOOLS_DIR=%PROJECT_DIR%.tools"
set "TOMCAT_VERSION=9.0.120"
set "TOMCAT_DIR=%TOOLS_DIR%\apache-tomcat-%TOMCAT_VERSION%"
set "PG_JAR=%PROJECT_DIR%WebContent\WEB-INF\lib\postgresql-42.7.4.jar"
set "BCRYPT_JAR=%PROJECT_DIR%WebContent\WEB-INF\lib\jbcrypt-0.4.jar"
set "SERVLET_JAR=%TOMCAT_DIR%\lib\servlet-api.jar"
set "CLASSES_DIR=%PROJECT_DIR%WebContent\WEB-INF\classes"
set "SOURCES_FILE=%TEMP%\netbanking_sources.txt"

echo ==================================================
echo  NetBanking - Build and Run
echo ==================================================

if not exist "%CLASSES_DIR%" mkdir "%CLASSES_DIR%"

call :find_java
if errorlevel 1 exit /b 1

call :get_dependency "%PG_JAR%" "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar"
if errorlevel 1 exit /b 1
call :get_dependency "%BCRYPT_JAR%" "https://repo1.maven.org/maven2/org/jbcrypt/jbcrypt/0.4/jbcrypt-0.4.jar"
if errorlevel 1 exit /b 1

if not exist "%SERVLET_JAR%" (
    echo Tomcat %TOMCAT_VERSION% not found. Downloading it to .tools...
    if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-9/v%TOMCAT_VERSION%/bin/apache-tomcat-%TOMCAT_VERSION%-windows-x64.zip' -OutFile '%TOOLS_DIR%\tomcat.zip'"
    if errorlevel 1 (
        echo Could not download Tomcat. Check your internet connection.
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Force '%TOOLS_DIR%\tomcat.zip' '%TOOLS_DIR%'"
    del "%TOOLS_DIR%\tomcat.zip"
)

if not exist "%SERVLET_JAR%" (
    echo Tomcat installation is incomplete: %SERVLET_JAR% was not found.
    exit /b 1
)

if not exist "%CLASSES_DIR%\db.properties" (
    copy "%CLASSES_DIR%\db.properties.example" "%CLASSES_DIR%\db.properties" >nul
    echo Created db.properties from the example. Update it with your PostgreSQL credentials before logging in.
)

echo Compiling Java sources...


(for /r "%PROJECT_DIR%src" %%f in (*.java) do (
    set "p=%%f"
    set "p=!p:\=/!"
    echo "!p!"
)) > "%SOURCES_FILE%"




"%JAVA_HOME%\bin\javac" -encoding UTF-8 -cp "%PG_JAR%;%BCRYPT_JAR%;%SERVLET_JAR%" -d "%CLASSES_DIR%" "@%SOURCES_FILE%"
if errorlevel 1 (
    echo.
    echo Compilation FAILED. See errors above.
    pause
    exit /b 1
)
echo Compilation OK.

echo.
echo Starting Tomcat...
set "CATALINA_HOME=%TOMCAT_DIR%"
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
exit /b 0

:find_java
if defined JAVA_HOME if exist "%JAVA_HOME%\bin\javac.exe" goto :java_found
for /d %%D in ("C:\Program Files\Java\jdk-17*" "C:\Program Files\Eclipse Adoptium\jdk-17*") do if exist "%%~D\bin\javac.exe" if not defined JAVA_HOME set "JAVA_HOME=%%~D"
if defined JAVA_HOME goto :java_found
for /f "delims=" %%J in ('where javac 2^>nul') do if not defined JAVAC_PATH set "JAVAC_PATH=%%J"
if not defined JAVAC_PATH (
    echo Java 17 JDK not found. Installing Eclipse Temurin 17 with winget...
    winget install --id EclipseAdoptium.Temurin.17.JDK --exact --accept-source-agreements --accept-package-agreements
    if errorlevel 1 (
        echo Install Java 17 manually, then run this script again.
        exit /b 1
    )
    for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do if exist "%%~D\bin\javac.exe" set "JAVA_HOME=%%~D"
)
if not defined JAVA_HOME for /f "delims=" %%H in ('powershell -NoProfile -Command "$line = java -XshowSettings:properties -version 2^>^&1 ^| Select-String 'java.home'; $line.ToString().Split('=')[1].Trim()"') do set "JAVA_HOME=%%H"
if not defined JAVA_HOME (
    echo Java was found, but JAVA_HOME could not be determined. Set JAVA_HOME to a Java 17 JDK and retry.
    exit /b 1
)
:java_found
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Using Java at %JAVA_HOME%
exit /b 0

:get_dependency
if exist "%~1" exit /b 0
echo Downloading %~nx1...
if not exist "%~dp1" mkdir "%~dp1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%~2' -OutFile '%~1'"
if errorlevel 1 (
    echo Could not download %~nx1.
    exit /b 1
)
exit /b 0
