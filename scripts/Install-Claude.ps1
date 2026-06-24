# Claude MSIX Automated Installation Script
# Usage: .\Install-Claude.ps1 -MSIXPath "C:\path\to\Claude.msix"

param(
    [Parameter(Mandatory=$true)]
    [string]$MSIXPath
)

Write-Host "=== Claude MSIX Installation Fix ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Verify MSIX file exists
if (-not (Test-Path $MSIXPath)) {
    Write-Host "ERROR: MSIX file not found at: $MSIXPath" -ForegroundColor Red
    exit 1
}

Write-Host "[1/4] Configuring Group Policy for Development..." -ForegroundColor Yellow
try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowDevelopmentWithoutDevLicense" -PropertyType "DWORD" -Value "1" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowAllTrustedApps" -PropertyType "DWORD" -Value "1" -Force | Out-Null
    Write-Host "  [OK] Group Policy configured" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Failed to configure Group Policy: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/4] Restarting AppX Services..." -ForegroundColor Yellow
try {
    Stop-Service AppXSvc -Force -ErrorAction SilentlyContinue
    Stop-Service ClipSVC -Force -ErrorAction SilentlyContinue
    Start-Service ClipSVC -ErrorAction SilentlyContinue
    Start-Service AppXSvc -ErrorAction SilentlyContinue
    Write-Host "  [OK] Services restarted" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Failed to restart services: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/4] Clearing Windows Store Cache..." -ForegroundColor Yellow
try {
    wsreset.exe | Out-Null
    Start-Sleep -Seconds 2
    Write-Host "  [OK] Cache cleared" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Failed to clear cache: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[4/4] Installing MSIX Package..." -ForegroundColor Yellow
try {
    Add-AppxPackage -Path $MSIXPath
    Write-Host "  [OK] Installation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Claude has been installed. You can find it in the Start Menu." -ForegroundColor Cyan
} catch {
    Write-Host "  [FAIL] Installation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check if package already exists: Get-AppxPackage -Name '*Claude*'" -ForegroundColor White
    Write-Host "2. Remove existing package and try again" -ForegroundColor White
    Write-Host "3. Check the logs in: $env:LOCALAPPDATA\Temp\ClaudeSetup.log" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
