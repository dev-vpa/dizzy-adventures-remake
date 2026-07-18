@echo off
setlocal
set "ROOT=%~dp0.."
set "GODOT=%GODOT%"

if "%GODOT%"=="" set "GODOT=D:\Programming\Tools\Godot_v4.7\Godot_v4.7-stable_win64_console.exe"
if not exist "%GODOT%" set "GODOT=godot"

where %GODOT% >nul 2>&1
if errorlevel 1 (
  echo Godot not found. Set GODOT= path to Godot 4.4+ executable.
  exit /b 1
)

echo Using: %GODOT%
"%GODOT%" --headless --path "%ROOT%" res://tests/test_runner.tscn %*
exit /b %ERRORLEVEL%
