# Network Mode Startup Script for WebAPI_App
# Run this to share your Vue app on LAN

Write-Host "`n🌐 Starting WebAPI_App in Network Mode...`n" -ForegroundColor Cyan

# Get local IP address
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -like "192.168.*"}).IPAddress

if (-not $localIP) {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress | Select-Object -First 1
}

if (-not $localIP) {
    Write-Host "❌ Cannot detect local IP address!" -ForegroundColor Red
    Write-Host "Please run 'ipconfig' to find your IPv4 address manually`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Detected Local IP: $localIP`n" -ForegroundColor Green

# Check if .env exists
$envPath = Join-Path $PSScriptRoot "web_vue\.env"
$envExamplePath = Join-Path $PSScriptRoot "web_vue\.env.example"

if (-not (Test-Path $envPath)) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
    
    if (Test-Path $envExamplePath) {
        Copy-Item $envExamplePath $envPath
    } else {
        # Create .env with detected IP
        @"
# Backend API Configuration
VITE_API_TARGET=http://${localIP}:3000

# Debug mode
# DEBUG=true
"@ | Out-File -FilePath $envPath -Encoding utf8
    }
    
    Write-Host "✅ Created .env file with IP: $localIP`n" -ForegroundColor Green
}

# Display access URLs
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  📍 Access URLs:" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  On this computer (localhost):" -ForegroundColor Yellow
Write-Host "    Frontend: http://localhost:5173" -ForegroundColor White
Write-Host "    Backend:  http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "  On other devices (same network):" -ForegroundColor Yellow
Write-Host "    Frontend: http://${localIP}:5173" -ForegroundColor Green
Write-Host "    Backend:  http://${localIP}:3000" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "🔍 Checking backend status..." -ForegroundColor Yellow

$backendRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        $backendRunning = $true
        Write-Host "✅ Backend is running on port 3000`n" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Backend not responding on port 3000" -ForegroundColor Red
    Write-Host "   Please start backend first:`n" -ForegroundColor Yellow
    Write-Host "   Option 1 (Node.js):" -ForegroundColor Cyan
    Write-Host "     cd node_backend" -ForegroundColor White
    Write-Host "     node server.js`n" -ForegroundColor White
    Write-Host "   Option 2 (Python):" -ForegroundColor Cyan
    Write-Host "     cd streamlit_app" -ForegroundColor White
    Write-Host "     python api_server.py`n" -ForegroundColor White
}

# Check if firewall rules exist
Write-Host "🔍 Checking firewall rules..." -ForegroundColor Yellow

$firewallRules = @(
    @{Port=5173; Name="Vite Dev Server"},
    @{Port=3000; Name="Node Backend API"}
)

$missingRules = @()

foreach ($rule in $firewallRules) {
    $existingRule = Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        $missingRules += $rule
    } else {
        Write-Host "  ✅ Firewall rule exists: $($rule.Name)" -ForegroundColor Green
    }
}

if ($missingRules.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  Missing firewall rules detected!" -ForegroundColor Yellow
    Write-Host "   Network access may be blocked by Windows Firewall`n" -ForegroundColor Red
    
    $createRules = Read-Host "Do you want to create firewall rules? (Y/N)"
    
    if ($createRules -eq 'Y' -or $createRules -eq 'y') {
        Write-Host "`n📝 Creating firewall rules (requires admin)..." -ForegroundColor Cyan
        
        foreach ($rule in $missingRules) {
            try {
                New-NetFirewallRule -DisplayName $rule.Name `
                    -Direction Inbound `
                    -LocalPort $rule.Port `
                    -Protocol TCP `
                    -Action Allow `
                    -ErrorAction Stop | Out-Null
                
                Write-Host "  ✅ Created rule: $($rule.Name) (Port $($rule.Port))" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Failed to create rule: $($rule.Name)" -ForegroundColor Red
                Write-Host "     Run PowerShell as Administrator and try again" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "⚠️  Skipped firewall configuration" -ForegroundColor Yellow
        Write-Host "   If network access fails, manually allow ports 5173 and 3000`n" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  🚀 Starting Vite Dev Server..." -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Change to web_vue directory
Set-Location (Join-Path $PSScriptRoot "web_vue")

# Start Vite with network mode
Write-Host "Starting: pnpm run dev -- --host 0.0.0.0`n" -ForegroundColor Gray


pnpm run dev -- --host 0.0.0.0
