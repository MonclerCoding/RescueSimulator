@echo off
setlocal
title Rescue Simulator - Sync Now
for %%I in ("%~dp0.") do set "PROJECT=%%~fI"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PROJECT%\dev\sync-now.ps1" -ProjectPath "%PROJECT%"
pause
