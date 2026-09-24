@echo off
cd /d "%~dp0"
echo Leave this window open. It connects the preview to goserver TCP port 20000.
echo 本窗口不要关。它把预览接到 goserver 的 20000 端口。
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\goserver-bridge.ps1" -ListenPort 17901
echo Bridge stopped.
pause
