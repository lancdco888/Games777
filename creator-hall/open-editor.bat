@echo off
setlocal EnableExtensions
set "CREATOR=D:\Creator\3.8.8\CocosCreator.exe"
for %%I in ("%~dp0.") do set "PROJECT=%%~fI"

if not exist "%CREATOR%" (
  echo Cocos Creator 3.8.8 was not found: %CREATOR%
  exit /b 1
)

echo %PROJECT% | findstr /I /C:"\Windows\System32\" >nul
if not errorlevel 1 (
  echo Move this folder out of C:\Windows\System32 before opening it.
  echo Example: C:\Games777\creator-hall
  echo Creator must create profiles and temp inside the project, and System32 denies that write.
  exit /b 1
)

echo Opening %PROJECT%
"%CREATOR%" --project "%PROJECT%"
