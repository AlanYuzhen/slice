@echo off
chcp 65001 >nul
REM 双击运行：一键装依赖（会自动申请管理员权限）
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
pause
