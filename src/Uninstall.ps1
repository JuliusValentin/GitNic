# dev-uninstall.ps1
$ErrorActionPreference = 'Stop'

Write-Host "=== Uninstalling GitNic (dev script) ==="

# Install dir must match what the installer used
$installDir = Join-Path $env:ProgramFiles 'GitNic'

Write-Host "Install directory: $installDir"

# Registry keys we created in the installer template
$keys = @(
    'HKCU:\Software\Classes\Directory\shell\GitNic',
    'HKCU:\Software\Classes\Directory\Background\shell\GitNic',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\GitNic'
)

foreach ($k in $keys) {
    if (Test-Path $k) {
        Write-Host "Removing registry key: $k"
        Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Registry key not found (already removed?): $k"
    }
}

# Remove Program Files\GitNic
if (Test-Path $installDir) {
    Write-Host "Removing folder: $installDir"
    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Install directory not found (already removed?): $installDir"
}

Write-Host "=== GitNic uninstall complete ==="
