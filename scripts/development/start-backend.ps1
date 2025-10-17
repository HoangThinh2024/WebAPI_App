# Start Backend with Network Access
# Run this before start-network.ps1

Write-Host "`n🚀 Starting Backend in Network Mode...`n" -ForegroundColor Cyan

# Get local IP
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -like "192.168.*"}).IPAddress

if (-not $localIP) {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress | Select-Object -First 1
}

Write-Host "✅ Local IP: $localIP`n" -ForegroundColor Green

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Backend will listen on:" -ForegroundColor White
Write-Host "    - http://localhost:3000" -ForegroundColor Yellow
Write-Host "    - http://${localIP}:3000" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Change to backend directory
Set-Location (Join-Path $PSScriptRoot "node_backend")

# Start Node.js server
Write-Host "Starting: node src/server.js`n" -ForegroundColor Gray

node src/server.js
