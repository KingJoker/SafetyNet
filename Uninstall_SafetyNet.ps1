# Requires Run as Administrator
$TaskName = "SafetyNet Listener"
$ProcessName = "SafetyNet" # Name without .exe

try {
    # 1. Stop the running process
    $RunningProc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($RunningProc) {
        Stop-Process -Name $ProcessName -Force
        Write-Host "Stopped running process: $ProcessName" -ForegroundColor Yellow
    }

    # 2. Remove the Scheduled Task
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($Task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed Scheduled Task: $TaskName" -ForegroundColor Green
    } else {
        Write-Host "Task '$TaskName' not found." -ForegroundColor Gray
    }

    # 3. Clean up Logs and Config (Optional - prompting ensures safety)
    $WorkDir = $PSScriptRoot
    Write-Host "`nScanning for artifacts in $WorkDir..."
    
    $Artifacts = @("SafetyNet.ini", "Recovered_*.txt")
    $FilesFound = Get-ChildItem -Path $WorkDir -Include $Artifacts -Recurse

    if ($FilesFound) {
        Write-Host "Found $($FilesFound.Count) log/config files." -ForegroundColor Cyan
        $FilesFound | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor Gray }
        
        $Response = Read-Host "`nDelete these files? (Y/N)"
        if ($Response -eq 'Y') {
            $FilesFound | Remove-Item -Force
            Write-Host "Artifacts deleted." -ForegroundColor Green
        } else {
            Write-Host "Files kept." -ForegroundColor Gray
        }
    } else {
        Write-Host "No logs or config files found." -ForegroundColor Gray
    }

} catch {
    Write-Error $_.Exception.Message
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")