@echo off
title XMRig Smart Launcher - Efficiency & Power Control
cd /d "%~dp0"

echo ========================================================
echo    XMRig Monero (RandomX) Smart Launcher
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_mining.ps1"

pause

