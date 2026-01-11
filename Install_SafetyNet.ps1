# Requires Run as Administrator
$TaskName = "SafetyNet Listener"
$ExeName  = "SafetyNet.exe"

try {
    # Get absolute paths
    $WorkDir  = $PSScriptRoot
    $ExePath  = Join-Path $WorkDir $ExeName

    if (-not (Test-Path $ExePath)) {
        Throw "Could not find $ExeName in $WorkDir"
    }

    # 1. Action: Launch EXE with correct working directory
    $Action = New-ScheduledTaskAction -Execute $ExePath -WorkingDirectory $WorkDir

    # 2. Trigger: At Log On
    $Trigger = New-ScheduledTaskTrigger -AtLogOn

    # 3. Principal: Run as current user, Highest Privileges (Admin/Elevated)
    $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

    # 4. Settings: Battery friendly, no timeout
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
                                             -DontStopIfGoingOnBatteries `
                                             -ExecutionTimeLimit (New-TimeSpan -Seconds 0) `
                                             -StartWhenAvailable

    # 5. Register
    Register-ScheduledTask -TaskName $TaskName `
                           -Action $Action `
                           -Trigger $Trigger `
                           -Principal $Principal `
                           -Settings $Settings `
                           -Force | Out-Null

    Write-Host "Success: Task '$TaskName' installed." -ForegroundColor Green
    Write-Host "Target: $ExePath" -ForegroundColor Gray
    
    # Optional: Start it immediately so you don't have to reboot/re-log
    Write-Host "Starting task..." -ForegroundColor Cyan
    Start-ScheduledTask -TaskName $TaskName

} catch {
    Write-Error $_.Exception.Message
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")