@echo off
setlocal
set "CREATOR=D:\Creator\3.8.8\CocosCreator.exe"
set "PROJECT=%~dp0"
if not exist "%CREATOR%" (
  echo Cocos Creator 3.8.8 was not found at %CREATOR%
  exit /b 1
)
start "" "%CREATOR%" --project "%PROJECT%"
