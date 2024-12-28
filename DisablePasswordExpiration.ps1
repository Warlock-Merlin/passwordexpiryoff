# Function to check if the script is running as Administrator
function Test-Admin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as Administrator, restart the script with elevated privileges
if (-not (Test-Admin)) {
    Write-Host "This script requires Administrator privileges. Restarting with elevated privileges..." -ForegroundColor Yellow
    
    # Restart the script with administrator privileges
    $script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    exit
}

# Set the execution policy to allow script execution for the current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Get the current username
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]

# Disable password expiration
try {
    # Disable password expiration for the user
    wmic useraccount where name="$username" set PasswordExpires="FALSE"
    Write-Host "Password expiration has been disabled for user: $username" -ForegroundColor Green
} catch {
    Write-Host "Error: Unable to disable password expiration for user: $username" -ForegroundColor Red
}
