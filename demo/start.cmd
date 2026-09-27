@echo off
cd /d "%~dp0"
docker compose version >nul 2>&1
if errorlevel 1 goto failed
docker compose up --build -d
if errorlevel 1 goto failed
docker compose ps
echo.
echo Open http://localhost:8088/ and wait for /health to report UP.
pause
exit /b 0
:failed
echo Docker Compose failed. Start Docker Desktop with Linux containers and try again.
pause
exit /b 1
