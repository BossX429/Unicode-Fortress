# UNICODE FORTRESS - MASTER INSTALLATION
# Run as Administrator
# This installs all 4 layers of Unicode protection

Write-Host ""
Write-Host "" -ForegroundColor Cyan
Write-Host "           UNICODE FORTRESS INSTALLATION           " -ForegroundColor Cyan
Write-Host "                                                        " -ForegroundColor Cyan
Write-Host "  Multi-Layer Defense Against Unicode Corruption       " -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Check for admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   Some features will be limited" -ForegroundColor Yellow
    Write-Host ""
}

# Layer 1: System-Wide UTF-8 Enforcement
Write-Host "" -ForegroundColor Cyan
Write-Host "LAYER 1: System-Wide UTF-8 Enforcement" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""

& "C:\Users\kyleh\unicode_fortress_layer1.ps1"

Write-Host ""
Write-Host "Press any key to continue to Layer 2..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""


# Layer 2: Install Guardian as Windows Service
Write-Host "" -ForegroundColor Cyan
Write-Host "LAYER 2: Real-Time Guardian Service" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""

Write-Host "Creating Windows Scheduled Task for Guardian..." -ForegroundColor Cyan

$taskName = "UnicodeGuardian"
$scriptPath = "C:\Users\kyleh\unicode_guardian.py"
$pythonPath = "C:\Program Files\Python312\python.exe"

# Check if task exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "  Removing existing task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create new task
$action = New-ScheduledTaskAction -Execute $pythonPath -Argument $scriptPath
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Unicode Fortress - Real-time file monitoring"

Write-Host "   Guardian scheduled to run at startup" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to continue to Layer 3..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""


# Layer 3: Install Git Hooks
Write-Host "" -ForegroundColor Cyan
Write-Host "LAYER 3: Git Pre-Commit Protection" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""

$repos = @("C:\Projects\kyleh", "C:\repos\AI-Librarian")

foreach ($repo in $repos) {
    if (Test-Path "$repo\.git") {
        Write-Host "Installing hook in: $repo" -ForegroundColor Cyan
        
        $hookDir = "$repo\.git\hooks"
        $hookPath = "$hookDir\pre-commit"
        
        # Create hook script
        $hookContent = @"
#!/bin/sh
# Unicode Fortress Git Hook
python "C:/Users/kyleh/git_pre_commit_unicode_check.py"
"@
        
        Set-Content -Path $hookPath -Value $hookContent -Encoding UTF8 -Force
        Write-Host "   Hook installed" -ForegroundColor Green
    } else {
        Write-Host "  ⏭  Not a git repo: $repo" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Press any key to continue to Layer 4..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""


# Layer 4: VSCode Settings
Write-Host "" -ForegroundColor Cyan
Write-Host "LAYER 4: VSCode UTF-8 Enforcement" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""

$vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"

if (Test-Path $vscodeSettingsPath) {
    Write-Host "Backing up existing VSCode settings..." -ForegroundColor Cyan
    Copy-Item $vscodeSettingsPath "$vscodeSettingsPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    # Read fortress settings
    $fortressSettings = Get-Content "C:\Users\kyleh\vscode_unicode_fortress.json" -Raw | ConvertFrom-Json
    
    # Read current settings
    $currentSettings = Get-Content $vscodeSettingsPath -Raw | ConvertFrom-Json
    
    # Merge settings
    $fortressSettings.PSObject.Properties | ForEach-Object {
        $currentSettings | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
    }
    
    # Write back
    $currentSettings | ConvertTo-Json -Depth 10 | Set-Content $vscodeSettingsPath -Encoding UTF8
    
    Write-Host "   VSCode settings updated" -ForegroundColor Green
} else {
    Write-Host "  ⏭  VSCode not found, skipping" -ForegroundColor Gray
}

Write-Host ""
Write-Host ""


# Installation Complete
Write-Host "" -ForegroundColor Green
Write-Host "                                                        " -ForegroundColor Green
Write-Host "      UNICODE FORTRESS INSTALLATION COMPLETE       " -ForegroundColor Green
Write-Host "                                                        " -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host ""

Write-Host "" -ForegroundColor Cyan
Write-Host "DEFENSE LAYERS ACTIVATED" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""
Write-Host " Layer 1: System-wide UTF-8 enforcement" -ForegroundColor Green
Write-Host " Layer 2: Real-time Guardian (scheduled task)" -ForegroundColor Green
Write-Host " Layer 3: Git pre-commit hooks" -ForegroundColor Green
Write-Host " Layer 4: VSCode UTF-8 enforcement" -ForegroundColor Green
Write-Host ""

Write-Host "" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. REBOOT your system for system-wide changes" -ForegroundColor Yellow
Write-Host "2. Guardian will auto-start on next boot" -ForegroundColor Cyan
Write-Host "3. Check guardian log: C:\Users\kyleh\unicode_guardian.log" -ForegroundColor Cyan
Write-Host ""

Write-Host "Manual Commands:" -ForegroundColor Yellow
Write-Host "  Start Guardian:  python C:\Users\kyleh\unicode_guardian.py" -ForegroundColor Cyan
Write-Host "  Check Status:    Get-ScheduledTask -TaskName UnicodeGuardian" -ForegroundColor Cyan
Write-Host "  View Log:        Get-Content C:\Users\kyleh\unicode_guardian.log -Tail 50" -ForegroundColor Cyan
Write-Host ""

Write-Host "Your system is now FORTIFIED against Unicode corruption! " -ForegroundColor Green
Write-Host ""
