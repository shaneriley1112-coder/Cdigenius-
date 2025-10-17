@echo off
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
puse
Locate src/App.jsx: Locate src/App.jsx: 
