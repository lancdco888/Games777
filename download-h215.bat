@echo off
chcp 65001 >nul
cd /d "%~dp0"
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
title 下载 h215 大厅和全部游戏
echo.
echo 这个窗口会把 h215.vip 大厅和全部 H5 游戏下载到本目录的 h215-local。
echo 大约 1.1GB。已经下过的文件会跳过，中途关掉可以再双击继续。
echo 完成后不要关闭窗口。浏览器打开 http://127.0.0.1:8080
echo 登录仍然用原来的账号。脚本不会保存密码或 token。
echo 如果系统询问是否允许访问网络，请选择允许。
echo.

set "PYEXE="
if exist "%~dp0.pyruntime\python.exe" set "PYEXE=%~dp0.pyruntime\python.exe"

if not defined PYEXE (
  where py >nul 2>&1 && py -3 -c "import sys; raise SystemExit(0 if sys.version_info>=(3,9) else 1)" >nul 2>&1 && set "PYLAUNCH=1"
)
if not defined PYEXE if not defined PYLAUNCH (
  where python >nul 2>&1 && python -c "import sys; raise SystemExit(0 if sys.version_info>=(3,9) else 1)" >nul 2>&1 && set "PYEXE=python"
)
if not defined PYEXE if not defined PYLAUNCH (
  where python3 >nul 2>&1 && python3 -c "import sys; raise SystemExit(0 if sys.version_info>=(3,9) else 1)" >nul 2>&1 && set "PYEXE=python3"
)

if not defined PYEXE if not defined PYLAUNCH (
  echo 没有检测到 Python，正在下载免安装 Python ...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download-h215-python.ps1"
  if errorlevel 1 (
    echo Python 下载失败。请安装 Python 3 后重新双击这个文件。
    pause
    exit /b 1
  )
  set "PYEXE=%~dp0.pyruntime\python.exe"
)

if defined PYLAUNCH (
  py -3 "%~dp0download-h215.py"
) else (
  "%PYEXE%" "%~dp0download-h215.py"
)
echo.
echo 窗口里的网页服务已停止。要再打开，重新双击即可。
pause
