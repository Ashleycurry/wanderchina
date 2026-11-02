@echo off
setlocal enabledelayedexpansion
title WanderChina Launcher

set "ROOT=%~dp0"
set "BACKEND=%ROOT%backend"
set "FRONTEND=%ROOT%frontend"

rem Usage: start.bat        -> dev mode  (npm run dev)
rem        start.bat prod   -> prod mode (npm run build + npm run start)
set "MODE=dev"
if /i "%~1"=="prod" set "MODE=prod"

echo ==============================================
echo   WanderChina local launcher
echo   Backend : Spring Boot  -^> http://localhost:8080
echo   Frontend: Next.js 14   -^> http://localhost:3000
echo   Mode    : !MODE!
echo   Previous instances are stopped automatically.
echo ==============================================
echo.

rem ---------- Prerequisites: locate runtimes ----------
rem Look on PATH first, then scan common install folders, so the launcher
rem also works when PATH was never configured on this machine.

call :find_maven
if errorlevel 1 (
    echo [ERROR] Maven not found on PATH or in common install folders.
    echo         Install Maven, or set MAVEN_HOME / M2_HOME to its root folder.
    echo Press any key to continue . . .
    pause >nul
    exit /b 1
)

call :find_node
if errorlevel 1 (
    echo [ERROR] Node.js / npm not found on PATH or in common install folders.
    echo         Install Node.js, or set NODE_HOME to its root folder.
    echo Press any key to continue . . .
    pause >nul
    exit /b 1
)

call :check_java
if errorlevel 1 exit /b 1

rem ---------- Step 1: stop previous service windows ----------
rem Match cmd.exe by command line. Do NOT use taskkill /FI WINDOWTITLE:
rem under Windows Terminal the window belongs to the terminal process
rem and killing it by title would close the whole terminal.
echo [CLEAN] Stopping previous service windows ...
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='cmd.exe'\" | Where-Object { $_.CommandLine -match 'mvn spring-boot:run|npm run dev|npm run start' } | ForEach-Object { & taskkill.exe /PID $_.ProcessId /T /F | Out-Null }" >nul 2>nul
ping -n 2 127.0.0.1 >nul

rem ---------- Step 2: free ports left by orphan processes ----------
call :free_port 8080 "Backend" "java.exe javaw.exe"
if errorlevel 1 goto :port_fail

call :free_port 3000 "Frontend" "node.exe"
if errorlevel 1 goto :port_fail

rem ---------- Frontend dependencies ----------
rem Check a file inside node_modules, not just the folder: an interrupted
rem npm install leaves an empty folder behind and npm run dev then fails
rem with "'next' is not recognized".
if not exist "%FRONTEND%\node_modules\next\package.json" (
    echo [SETUP] Frontend dependencies are missing or incomplete, running npm install ...
    echo         This runs once only. It may take a few minutes.
    pushd "%FRONTEND%"
    call npm install --no-audit --no-fund
    if errorlevel 1 (
        popd
        echo [ERROR] npm install failed. Check your network or Node.js version.
        echo Press any key to continue . . .
        pause >nul
        exit /b 1
    )
    popd
)

rem ---------- Production build ----------
if /i "!MODE!"=="prod" (
    echo [BUILD] npm run build ...
    pushd "%FRONTEND%"
    call npm run build
    if errorlevel 1 (
        popd
        echo [ERROR] Frontend build failed. See the log above.
        echo Press any key to continue . . .
        pause >nul
        exit /b 1
    )
    popd
)

rem ---------- Start services ----------
echo [1/2] Starting backend ...
start "WanderChina-BE :8080" /D "%BACKEND%" cmd /k "chcp 65001 >nul && mvn spring-boot:run"

echo [2/2] Starting frontend ...
if /i "!MODE!"=="prod" (
    start "WanderChina-FE :3000" /D "%FRONTEND%" cmd /k "chcp 65001 >nul && npm run start"
) else (
    start "WanderChina-FE :3000" /D "%FRONTEND%" cmd /k "chcp 65001 >nul && npm run dev"
)

echo.
echo Waiting for the frontend to respond ...

rem Fall back to a fixed wait when curl is unavailable
where curl >nul 2>nul
if errorlevel 1 (
    echo [WARN] curl not found, falling back to a fixed 45s wait.
    ping -n 46 127.0.0.1 >nul
    goto :open_browser
)

rem The first request compiles the page in dev mode and can take 20s or more,
rem so each attempt needs a generous timeout instead of a 1-2s probe.
echo - Polling http://localhost:3000 ^(max 20 attempts, up to 30s each^)
set /a TRIES=0
:wait_front
set /a TRIES+=1
if !TRIES! gtr 20 (
    echo [WARN] Frontend did not respond after 20 attempts. Check the "WanderChina-FE :3000" window.
    goto :open_browser
)
curl -s -o nul -f --max-time 30 http://localhost:3000 >nul 2>nul
if errorlevel 1 (
    ping -n 2 127.0.0.1 >nul
    goto :wait_front
)
echo [READY] Frontend is responding on http://localhost:3000

:open_browser
start "" http://localhost:3000

echo.
echo You can close this window; services keep running. Close a service window to stop it.
ping -n 4 127.0.0.1 >nul
exit /b 0

:port_fail
echo.
echo Free the port listed above, then run this script again.
echo Press any key to continue . . .
pause >nul
exit /b 1

rem ---------- :free_port ^<port^> ^<label^> ^<allowed exe names^> ----------
rem returns 0 when the port is free, or when a leftover project process was stopped
rem returns 1 when the port is held by an unrelated process
:free_port
set "PORT=%~1"
set "LABEL=%~2"
set "ALLOWED=%~3"
set /a RETRY=0

:free_port_scan
set "OWNER_PID="
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r /c:":%PORT% " ^| findstr /i "LISTENING"') do set "OWNER_PID=%%p"
if not defined OWNER_PID exit /b 0

set "OWNER_NAME=unknown"
for /f "tokens=1 delims=," %%n in ('tasklist /fi "PID eq !OWNER_PID!" /fo csv /nh') do set "OWNER_NAME=%%~n"

rem Only stop processes on the allow list, so unrelated programs are never killed
set "ALLOW="
for %%a in (%ALLOWED%) do if /i "%%a"=="!OWNER_NAME!" set "ALLOW=1"
if not defined ALLOW (
    echo [BLOCK] %LABEL% port %PORT% is held by !OWNER_NAME! ^(PID !OWNER_PID!^), not started by this project.
    echo         Run: taskkill /PID !OWNER_PID! /F
    exit /b 1
)

echo [CLEAN] Stopping leftover %LABEL% process !OWNER_NAME! ^(PID !OWNER_PID!^)
taskkill /PID !OWNER_PID! /T /F >nul 2>nul
ping -n 2 127.0.0.1 >nul

set /a RETRY+=1
if !RETRY! lss 3 goto :free_port_scan

echo [ERROR] Failed to free %LABEL% port %PORT%. Run manually: taskkill /PID !OWNER_PID! /T /F
exit /b 1

rem ---------- :find_maven ----------
rem Resolves mvn.cmd from PATH, MAVEN_HOME / M2_HOME, then common folders.
:find_maven
set "MVN_CMD="
for /f "delims=" %%p in ('where mvn.cmd 2^>nul') do if not defined MVN_CMD set "MVN_CMD=%%p"

if not defined MVN_CMD if defined MAVEN_HOME if exist "%MAVEN_HOME%\bin\mvn.cmd" set "MVN_CMD=%MAVEN_HOME%\bin\mvn.cmd"
if not defined MVN_CMD if defined M2_HOME if exist "%M2_HOME%\bin\mvn.cmd" set "MVN_CMD=%M2_HOME%\bin\mvn.cmd"

if not defined MVN_CMD (
    for /d %%d in (
        "%ProgramFiles%\apache-maven*"
        "%ProgramFiles%\apache-maven"
        "%USERPROFILE%\tools\apache-maven*"
        "%USERPROFILE%\apache-maven*"
        "%USERPROFILE%\dev\apache-maven*"
        "%USERPROFILE%\scoop\apps\maven\current"
        "%ProgramData%\chocolatey\lib\maven*"
    ) do if not defined MVN_CMD if exist "%%~d\bin\mvn.cmd" set "MVN_CMD=%%~d\bin\mvn.cmd"
)

if not defined MVN_CMD (
    rem Last resort: scan common folders on every fixed drive.
    rem Folder names are matched case-insensitively, because some volumes are
    rem case-sensitive and a literal D:\apache-maven* pattern would miss them.
    for %%r in (C D E F G H) do if exist "%%r:\" (
        for /f "delims=" %%d in ('dir /b /ad "%%r:\" 2^>nul ^| findstr /i /c:"maven"') do (
            if not defined MVN_CMD if exist "%%r:\%%~d\bin\mvn.cmd" set "MVN_CMD=%%r:\%%~d\bin\mvn.cmd"
        )
        for %%s in (tools dev software env opt) do (
            for /f "delims=" %%d in ('dir /b /ad "%%r:\%%s" 2^>nul ^| findstr /i /c:"maven"') do (
                if not defined MVN_CMD if exist "%%r:\%%s\%%~d\bin\mvn.cmd" set "MVN_CMD=%%r:\%%s\%%~d\bin\mvn.cmd"
            )
        )
    )
)

if not defined MVN_CMD exit /b 1
for %%d in ("!MVN_CMD!") do set "PATH=%%~dpd;!PATH!"
echo [ENV] mvn  : !MVN_CMD!
exit /b 0

rem ---------- :find_node ----------
rem Resolves npm.cmd from PATH, NODE_HOME, then common install folders.
:find_node
set "NPM_CMD="
for /f "delims=" %%p in ('where npm.cmd 2^>nul') do if not defined NPM_CMD set "NPM_CMD=%%p"

if not defined NPM_CMD if defined NODE_HOME if exist "%NODE_HOME%\npm.cmd" set "NPM_CMD=%NODE_HOME%\npm.cmd"

if not defined NPM_CMD (
    for %%f in (
        "%ProgramFiles%\nodejs\npm.cmd"
        "%ProgramFiles%\nodejs\node.exe"
        "%LOCALAPPDATA%\Programs\nodejs\npm.cmd"
        "%USERPROFILE%\scoop\apps\nodejs\current\npm.cmd"
        "%APPDATA%\nvm\npm.cmd"
        "%APPDATA%\nvm\node.exe"
    ) do if not defined NPM_CMD if exist "%%~f" set "NPM_CMD=%%~f"
)

if not defined NPM_CMD (
    rem Same scan, folder names matched case-insensitively (for example D:\Node.js)
    for %%r in (C D E F G H) do if exist "%%r:\" (
        for /f "delims=" %%d in ('dir /b /ad "%%r:\" 2^>nul ^| findstr /i /c:"node"') do (
            if not defined NPM_CMD if exist "%%r:\%%~d\npm.cmd" set "NPM_CMD=%%r:\%%~d\npm.cmd"
            if not defined NPM_CMD if exist "%%r:\%%~d\node.exe" set "NPM_CMD=%%r:\%%~d\node.exe"
        )
        for %%s in (tools dev software env opt) do (
            for /f "delims=" %%d in ('dir /b /ad "%%r:\%%s" 2^>nul ^| findstr /i /c:"node"') do (
                if not defined NPM_CMD if exist "%%r:\%%s\%%~d\npm.cmd" set "NPM_CMD=%%r:\%%s\%%~d\npm.cmd"
                if not defined NPM_CMD if exist "%%r:\%%s\%%~d\node.exe" set "NPM_CMD=%%r:\%%s\%%~d\node.exe"
            )
        )
    )
)

if not defined NPM_CMD exit /b 1
for %%d in ("!NPM_CMD!") do set "PATH=%%~dpd;!PATH!"
echo [ENV] npm  : !NPM_CMD!
exit /b 0

rem ---------- :check_java ----------
rem Resolves java.exe from PATH, JAVA_HOME, then common JDK folders,
rem and warns when the runtime is older than the Java 21 the backend targets.
:check_java
set "JAVA_EXE="
for /f "delims=" %%p in ('where java.exe 2^>nul') do if not defined JAVA_EXE set "JAVA_EXE=%%p"

if not defined JAVA_EXE if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"

if not defined JAVA_EXE (
    for /d %%d in (
        "%ProgramFiles%\Java\jdk*"
        "%ProgramFiles%\Eclipse Adoptium\jdk*"
        "%ProgramFiles%\Microsoft\jdk*"
        "%ProgramFiles%\Zulu\zulu*"
        "%USERPROFILE%\.jdks\*"
    ) do if not defined JAVA_EXE if exist "%%~d\bin\java.exe" set "JAVA_EXE=%%~d\bin\java.exe"
)

if not defined JAVA_EXE (
    rem Same scan, folder names matched case-insensitively (for example D:\JDK-21)
    for %%r in (C D E F G H) do if exist "%%r:\" (
        for /f "delims=" %%d in ('dir /b /ad "%%r:\" 2^>nul ^| findstr /i "jdk java"') do (
            if not defined JAVA_EXE if exist "%%r:\%%~d\bin\java.exe" set "JAVA_EXE=%%r:\%%~d\bin\java.exe"
        )
        for %%s in (tools dev software env opt Java) do (
            for /f "delims=" %%d in ('dir /b /ad "%%r:\%%s" 2^>nul ^| findstr /i "jdk java"') do (
                if not defined JAVA_EXE if exist "%%r:\%%s\%%~d\bin\java.exe" set "JAVA_EXE=%%r:\%%s\%%~d\bin\java.exe"
            )
        )
    )
)

if not defined JAVA_EXE (
    echo [ERROR] Java not found on PATH or in common install folders.
    echo         Install a JDK 21+ and set JAVA_HOME to its root folder.
    echo Press any key to continue . . .
    pause >nul
    exit /b 1
)

set "JAVA_BIN="
for %%d in ("!JAVA_EXE!") do set "JAVA_BIN=%%~dpd"
set "PATH=!JAVA_BIN!;!PATH!"
if not defined JAVA_HOME (
    pushd "!JAVA_BIN!.."
    set "JAVA_HOME=%CD%"
    popd
)

set "JAVAVER="
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do if not defined JAVAVER set "JAVAVER=%%~v"
set "JAVAMAJOR="
if defined JAVAVER for /f "tokens=1 delims=._-" %%m in ("!JAVAVER!") do set "JAVAMAJOR=%%m"

echo [ENV] java : !JAVAVER! (!JAVA_HOME!)
if not defined JAVAMAJOR exit /b 0
if !JAVAMAJOR! lss 21 (
    echo [WARN] The backend targets Java 21, but !JAVAVER! was found.
    echo        Point JAVA_HOME to a JDK 21+ folder, then run again.
)
exit /b 0
