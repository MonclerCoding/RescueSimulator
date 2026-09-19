@echo off
title Rescue Simulator DEV
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev\start-dev.ps1" -ProjectPath "%~dp0"
pause
