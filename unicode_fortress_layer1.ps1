# UNICODE FORTRESS - Layer 1: System-Wide UTF-8 Enforcement
# Run as Administrator
# This sets Windows to ALWAYS use UTF-8

Write-Host "=== UNICODE FORTRESS: SYSTEM ENFORCEMENT ===" -ForegroundColor Cyan
Write-Host ""

# Set system-wide UTF-8 via registry
Write-Host "[1/5] Setting Windows system-wide UTF-8..." -ForegroundColor Yellow
try {
    # Enable UTF-8 system-wide
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value "65001" -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "OEMCP" -Value "65001" -Force
    Write-Host "   System UTF-8 encoding enforced" -ForegroundColor Green
} catch {
    Write-Host "    Failed (need admin): $_" -ForegroundColor Red
}

# Set user environment variables
Write-Host ""
Write-Host "[2/5] Setting user environment variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("PYTHONIOENCODING", "utf-8", "User")
[Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")
[Environment]::SetEnvironmentVariable("LC_ALL", "en_US.UTF-8", "User")
Write-Host "   PYTHONIOENCODING=utf-8" -ForegroundColor Green
Write-Host "   PYTHONUTF8=1" -ForegroundColor Green
Write-Host "   LC_ALL=en_US.UTF-8" -ForegroundColor Green

# Set system environment variables
Write-Host ""
Write-Host "[3/5] Setting system environment variables..." -ForegroundColor Yellow
try {
    [Environment]::SetEnvironmentVariable("PYTHONIOENCODING", "utf-8", "Machine")
    [Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "Machine")
    Write-Host "   System-wide Python UTF-8 enforced" -ForegroundColor Green
} catch {
    Write-Host "    Failed (need admin): $_" -ForegroundColor Red
}

# Configure PowerShell to always use UTF-8
Write-Host ""
Write-Host "[4/5] Configuring PowerShell UTF-8..." -ForegroundColor Yellow
$psProfile = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$utf8Config = @"
# UNICODE FORTRESS - Auto-loaded UTF-8 enforcement
`$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
`$PSDefaultParameterValues['*:Encoding'] = 'utf8'
"@

if (Test-Path $psProfile) {
    $content = Get-Content $psProfile -Raw
    if ($content -notmatch "UNICODE FORTRESS") {
        Add-Content -Path $psProfile -Value "`n$utf8Config" -Encoding UTF8
        Write-Host "   PowerShell profile configured for UTF-8" -ForegroundColor Green
    } else {
        Write-Host "  [INFO]  PowerShell already configured" -ForegroundColor Cyan
    }
}

# Create Git global config for UTF-8
Write-Host ""
Write-Host "[5/5] Configuring Git for UTF-8..." -ForegroundColor Yellow
git config --global core.quotepath false
git config --global gui.encoding utf-8
git config --global i18n.commit.encoding utf-8
git config --global i18n.logoutputencoding utf-8
Write-Host "   Git configured for UTF-8" -ForegroundColor Green

Write-Host ""
Write-Host "=== LAYER 1 COMPLETE ===" -ForegroundColor Green
Write-Host "  REBOOT REQUIRED for system-wide changes to take effect!" -ForegroundColor Yellow
