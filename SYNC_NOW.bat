@echo off
title Rescue Simulator - Sync Now
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev\sync-now.ps1" -ProjectPath "%~dp0"
pause
