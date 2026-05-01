param (
    [string]$directoryPath
)

# Set error action preference
$ErrorActionPreference = 'Continue'

# Print the script title
Write-Ascii "Git Backup Save Files"

# Change the working directory
Set-Location $directoryPath
Write-Host "`n............................"
Write-Host "Performing back up at $directoryPath"
Write-Host "............................`n"

$changes = git status --porcelain

if ($changes) {
    git status
    Write-Host "`n............................`n"
    Write-Host "`nThere are changes to commit.`n"
    Write-Host "`n............................`n"
} else {
    Write-Host "`nNo changes to commit."
    exit
}

# Get the current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Add all modified or newly added files to the staging area
Write-Host "`nAdding changes to the staging area..."
git add -A
Write-Host "Changes added to the staging area.`n"

# Commit the changes with the timestamp as the commit message
Write-Host "`nCommitting changes with timestamp: $timestamp..."
git commit -m "Changes as of $timestamp"
Write-Host "Changes committed.`n"

# Push the changes
Write-Host "`nPushing changes to the remote repository..."
git push
Write-Host "Changes pushed to the remote repository.`n"

# Sleep for 3 seconds
Write-Host "`nScript execution completed. Sleeping for 3 seconds..."
Start-Sleep -Seconds 3
Write-Host "Sleep completed. Exiting script."
