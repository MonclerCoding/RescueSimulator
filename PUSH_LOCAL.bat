@echo off
title Rescue Simulator - Push Local
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev\push-local.ps1" -ProjectPath "%~dp0"
pause
