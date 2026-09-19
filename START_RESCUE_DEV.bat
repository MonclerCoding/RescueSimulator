@echo off
setlocal
title Rescue Simulator DEV
for %%I in ("%~dp0.") do set "PROJECT=%%~fI"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PROJECT%\dev\start-dev.ps1" -ProjectPath "%PROJECT%"
pause
