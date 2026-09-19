@echo off
title Rescue Simulator - Status
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev\status.ps1" -ProjectPath "%~dp0"
pause
