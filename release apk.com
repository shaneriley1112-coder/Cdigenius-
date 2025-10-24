# =====================================
# CDI Genius Real Version Launcher
# =====================================

# Set working directory to this script folder
Set-Location -Path $PSScriptRoot

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is not installed. Install Node.js to run this app." -ForegroundColor Red
    pause
    exit
}

# Start React Native Metro server in a new window
Start-Process powershell -ArgumentList "npx react-native start" -NoNewWindow

# Run Android app if connected device/emulator exists
Start-Process powershell -ArgumentList "npx react-native run-android"

Write-Host "✅ Real version launched. Metro server started."
pauseCDI-Genius-Real\launch-real.ps1Create-Full-CDI-Genius-ZIPs.ps1@echo off
REM === CONFIGURATION ===
set KEYSTORE=my-release-key.keystore
set ALIAS=cdigenius-key
set APK_IN=app-release-unsigned.apk
set APK_ALIGNED=app-release-aligned.apk
set APK_OUT=app-release-signed.apk

REM === ASK FOR KEYSTORE PASSWORD ===
set /p KSPASS=Enter keystore password: 

echo.
echo === Step 1: Aligning APK ===
zipalign -v -p 4 "%APK_IN%" "%APK_ALIGNED%"
if %ERRORLEVEL% neq 0 (
    echo Error: zipalign failed.
    pause
    exit /b 1
)

echo.
echo === Step 2: Signing APK ===
apksigner sign --ks "%KEYSTORE%" --ks-key-alias "%ALIAS%" --ks-pass pass:%KSPASS% --out "%APK_OUT%" "%APK_ALIGNED%"
if %ERRORLEVEL% neq 0 (
    echo Error: signing failed.
    pause
    exit /b 1
)

echo.
echo === Step 3: Verifying APK ===
apksigner verify --verbose --print-certs "%APK_OUT%"
if %ERRORLEVEL% neq 0 (
    echo Error: verification failed.
    pause
    exit /b 1
)

echo.
echo ✅ APK successfully aligned, signed, and verified!
echo Output: %APK_OUT%
pause
Locate src/App.jsx: Locate src/App.jsx: 
run start