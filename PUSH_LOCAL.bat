@echo off
setlocal
title Rescue Simulator - Push Local
for %%I in ("%~dp0.") do set "PROJECT=%%~fI"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PROJECT%\dev\push-local.ps1" -ProjectPath "%PROJECT%"
pause
