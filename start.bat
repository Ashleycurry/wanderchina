@echo off
title WanderChina һ������

set "ROOT=%~dp0"
set "BACKEND=%ROOT%backend"
set "FRONTEND=%ROOT%frontend"

echo ==============================================
echo   WanderChina ���ؿ�������
echo   ���? Spring Boot  -^> http://localhost:8080
echo   ǰ��: Next.js 14 -^> http://localhost:3000
echo ==============================================
echo.

where mvn >nul 2>nul
if errorlevel 1 (
    echo [����] δ�ҵ� mvn���밲װ Maven ������ PATH
    pause
    exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
    echo [����] δ�ҵ� npm���밲װ Node.js ������ PATH
    pause
    exit /b 1
)

if not exist "%FRONTEND%\node_modules" (
    echo [��ʾ] ǰ������δ��װ��ִ�� npm install ...
    pushd "%FRONTEND%"
    call npm install --no-audit --no-fund
    popd
)

echo [1/2] ������˴���?..
start "WanderChina ���?:8080" /D "%BACKEND%" cmd /k "chcp 65001 >nul && mvn spring-boot:run"

echo [2/2] ����ǰ�˴���...
start "WanderChina ǰ�� :3000" /D "%FRONTEND%" cmd /k "chcp 65001 >nul && npm run dev"

echo.
echo �ȴ���������������������...
ping -n 11 127.0.0.1 >nul
start "" http://localhost:3000

echo.
echo ���������رձ����ڲ�Ӱ����񣻹رն�Ӧ���񴰿ڼ�ֹͣ�÷���?
ping -n 5 127.0.0.1 >nul
exit /b 0
