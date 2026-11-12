@echo off
setlocal
cd /d "%~dp0"
where code >nul 2>&1
if errorlevel 1 (
  echo Abra o VS Code e selecione a pasta mobile deste projeto.
  pause
  exit /b 1
)
call code --new-window "%~dp0mobile"
