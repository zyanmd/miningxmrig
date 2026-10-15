@echo off
title Download XMRig Latest Release
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_xmrig.ps1"

pause

