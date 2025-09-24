@echo off
echo === CDI Genius Preview APK Build ===
cd /d %~dp0
npm install
eas login
eas build -p android --profile preview --type apk
pause
