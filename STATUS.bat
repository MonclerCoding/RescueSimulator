@echo off
setlocal
title Rescue Simulator - Status
for %%I in ("%~dp0.") do set "PROJECT=%%~fI"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PROJECT%\dev\status.ps1" -ProjectPath "%PROJECT%"
pause
