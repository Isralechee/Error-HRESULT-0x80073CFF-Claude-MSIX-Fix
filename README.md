# Claude Desktop MSIX Installation Error Fix

## Error: HRESULT 0x80073CFF

This repository contains the solution for the Claude Desktop installation error on Windows 11 Insider Preview Build 26200.

---

## ðŸ“‹ Error Description

**Error Code:** \HRESULT 0x80073CFF\

**Error Message:**
\\\
Installation failed: AddPackage failed: AddPackage failed with HRESULT 0x80073CFF
\\\

**Affected Systems:**
- Windows 11 Professional
- Build: 10.0.26200 (Insider Preview)
- Installation Method: MSIX package

---

## ðŸ” Root Cause Analysis

The error occurs due to a combination of factors:

1. **Incomplete Developer Mode Configuration**: While \AllowDevelopmentWithoutDevLicense\ was set to 1 in the registry, the Group Policy location (\HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Appx\) had conflicting values set to 0.

2. **Corrupted AppX Service State**: The Windows AppX package manager service had cached corrupted state from previous installation attempts.

3. **Windows Store Cache**: Existing cache interfered with the new installation.

4. **Windows Insider Build Issues**: Build 26200 has known compatibility issues with MSIX package installations.

---

## âœ… Solution

### Quick Fix (Copy & Paste)

Run PowerShell **as Administrator** and execute:

\\\powershell
# Step 1: Configure Group Policy for Development
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowDevelopmentWithoutDevLicense" -PropertyType "DWORD" -Value "1" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowAllTrustedApps" -PropertyType "DWORD" -Value "1" -Force | Out-Null

# Step 2: Restart AppX Services
Stop-Service AppXSvc -Force -ErrorAction SilentlyContinue
Stop-Service ClipSVC -Force -ErrorAction SilentlyContinue
Start-Service ClipSVC -ErrorAction SilentlyContinue
Start-Service AppXSvc -ErrorAction SilentlyContinue

# Step 3: Clear Windows Store Cache
wsreset.exe

# Step 4: Install Claude MSIX
Add-AppxPackage -Path "C:\Users\Isra\Downloads\Claude.msix"

Write-Host "Installation complete! Check Start Menu for Claude." -ForegroundColor Green
\\\

---

## ðŸ“– Detailed Step-by-Step Solution

### Step 1: Enable Developer Mode via Group Policy

The installer checks TWO registry locations. Both must be configured:

\\\powershell
# Location 1: System registry
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" 
    -Name "AllowDevelopmentWithoutDevLicense" -PropertyType "DWORD" -Value "1" -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" 
    -Name "AllowAllTrustedApps" -PropertyType "DWORD" -Value "1" -Force

# Location 2: Group Policy (CRITICAL - this was missing!)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" 
    -Name "AllowDevelopmentWithoutDevLicense" -PropertyType "DWORD" -Value "1" -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" 
    -Name "AllowAllTrustedApps" -PropertyType "DWORD" -Value "1" -Force
\\\

### Step 2: Restart AppX Package Services

Clear any corrupted state in the package manager:

\\\powershell
Stop-Service AppXSvc -Force
Stop-Service ClipSVC -Force
Start-Service ClipSVC
Start-Service AppXSvc
\\\

### Step 3: Clear Windows Store Cache

\\\powershell
wsreset.exe
\\\

### Step 4: Install MSIX Package

\\\powershell
Add-AppxPackage -Path "C:\Users\Isra\Downloads\Claude.msix"
\\\

---

## ðŸ”§ Alternative: Automated Installation Script

Use the provided script in the \scripts\ folder:

\\\powershell
.\\scripts\\Install-Claude.ps1 -MSIXPath "C:\\path\\to\\Claude.msix"
\\\

---

## ðŸ“Š Technical Details

### Registry Keys Modified

1. **HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock**
   - \AllowDevelopmentWithoutDevLicense\ = 1
   - \AllowAllTrustedApps\ = 1

2. **HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Appx**
   - \AllowDevelopmentWithoutDevLicense\ = 1
   - \AllowAllTrustedApps\ = 1

### Services Restarted

- **AppXSvc** (AppX Deployment Service)
- **ClipSVC** (Client License Service)

### Why This Works

1. **Dual Registry Configuration**: Windows checks both the system registry AND group policy. Setting only one location is insufficient.

2. **Service State Reset**: The AppX services cache installation state. Restarting them clears corrupted data.

3. **Cache Clearance**: Windows Store cache can interfere with MSIX installations.

---

##  Troubleshooting

### If Installation Still Fails

1. **Check if package already exists:**
   \\\powershell
   Get-AppxPackage -Name "*Claude*" -AllUsers
   \\\

2. **Remove existing packages:**
   \\\powershell
   Get-AppxPackage -Name "*Claude*" | Remove-AppxPackage
   Get-AppxPackage -Name "*Claude*" -AllUsers | Remove-AppxPackage -AllUsers
   \\\

3. **Verify Developer Mode is enabled:**
   \\\powershell
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx"
   \\\

4. **Check Windows version compatibility:**
   \\\powershell
   winver
   \\\

### For Windows Insider Builds

If you're on Build 26200 or later Insider builds, consider:
- Using the EXE installer instead of MSIX
- Waiting for a stable build
- Reporting the issue to Microsoft via Feedback Hub

---

## ðŸ“ Repository Contents

- \logs/\ - Installation log files
- \scripts/\ - Automated installation scripts
- \README.md\ - This documentation

---

## ðŸ“ Notes

- **Administrator privileges required**: All PowerShell commands must be run as Administrator
- **Restart recommended**: After applying fixes, restart your computer for best results
- **Windows Insider builds**: This issue is more common on Insider Preview builds

---

## ðŸ”— References

- [Microsoft Docs: Enable your device for development](https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development)
- [Microsoft Docs: Sideloading](https://docs.microsoft.com/en-us/windows/msix/sideload-apps)
- [Claude Desktop Download](https://claude.ai/download)

---

## ðŸ¤ Contributing

If you encounter this error on different Windows versions, please:
1. Open an issue with your Windows version
2. Share your installation logs
3. Document any additional steps required

---

**Last Updated:** June 24, 2026  
**Tested On:** Windows 11 Professional Build 10.0.26200
