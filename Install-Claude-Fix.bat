@echo off
echo === Claude Installation Fix ===
echo.
echo This script will fix the HRESULT 0x80073CFF error
echo and install Claude Desktop.
echo.
echo NOTE: You must run this as Administrator!
echo.
pause

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\Install-Claude.ps1" -MSIXPath "C:\Users\Isra\Downloads\Claude.msix"

echo.
pause
