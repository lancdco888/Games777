@echo off
cd /d "%~dp0"
echo Leave this window open. Preview connects here, then this window dials goserver port 20000.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\goserver-bridge.ps1" -ListenPort 17901
echo Bridge stopped.
pause
