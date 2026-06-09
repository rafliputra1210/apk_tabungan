@echo off
REM Tabunganku - Quick Setup Script untuk Windows

echo.
echo 🎉 Selamat datang di Tabunganku!
echo ==================================
echo.

REM Check Flutter installation
echo 📦 Checking Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter not found. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

flutter --version
echo.

REM Setup project
echo 📂 Setting up project...
cd /d "%~dp0"

REM Clean and get dependencies
echo 🔄 Installing dependencies...
call flutter clean
call flutter pub get

echo.
echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Android: flutter run -d emulator-5554
echo 2. Generic: flutter run
echo.
pause
