@echo off
cd /d "%~dp0"
echo The Creator log says the default browser path does not exist, so Play never opens the game.
echo This points Creator at Edge or Chrome and opens http://127.0.0.1:7456
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\fix-browser.ps1"
echo.
echo Press Play in Creator if the page does not load, then refresh that browser tab.
pause
