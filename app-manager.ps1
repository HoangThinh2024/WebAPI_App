<# 
.SYNOPSIS
    WebAPI App Manager - Master script to manage the entire project

.DESCRIPTION
    Interactive menu to manage development, production, and maintenance tasks.
    
    Features:
    - Development: Start Vue, Backend, Full Stack
    - Production: Security audit, Build, Deploy
    - Maintenance: Cleanup, Authentication, Reports
    - Documentation: Guides, Structure

.EXAMPLE
    .\app-manager.ps1
    Shows interactive menu

.EXAMPLE
    .\app-manager.ps1 -Help
    Shows help information

.NOTES
    Version: 2.2.2
    Author: HoangThinh2024
    Last Updated: 2025-10-17
#>

param(
    [switch]$Help
)

# Colors
$colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Header = "Magenta"
}

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor $colors.Header
    Write-Host "║          WebAPI_App - Project Manager                 ║" -ForegroundColor $colors.Header
    Write-Host "║                   Version 2.2.2                        ║" -ForegroundColor $colors.Header
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor $colors.Header
    Write-Host ""
}

function Show-Menu {
    Write-Host "  DEVELOPMENT" -ForegroundColor $colors.Info
    Write-Host "  [1] Start Vue app (Network mode)" -ForegroundColor White
    Write-Host "  [2] Start Backend API" -ForegroundColor White
    Write-Host "  [3] Start Full Stack (Vue + Backend)" -ForegroundColor White
    Write-Host ""
    Write-Host "  PRODUCTION" -ForegroundColor $colors.Warning
    Write-Host "  [4] Security Audit" -ForegroundColor White
    Write-Host "  [5] Build Production" -ForegroundColor White
    Write-Host "  [6] Deploy Application" -ForegroundColor White
    Write-Host "  [7] Quick Security Fixes" -ForegroundColor White
    Write-Host ""
    Write-Host "  MAINTENANCE" -ForegroundColor $colors.Success
    Write-Host "  [8] Cleanup (cache/logs)" -ForegroundColor White
    Write-Host "  [9] Authentication Management" -ForegroundColor White
    Write-Host "  [10] View Security Report" -ForegroundColor White
    Write-Host ""
    Write-Host "  DOCUMENTATION" -ForegroundColor $colors.Header
    Write-Host "  [11] Open Documentation" -ForegroundColor White
    Write-Host "  [12] View Project Structure" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor $colors.Error
    Write-Host ""
}

function Start-Vue {
    Write-Host "🚀 Starting Vue app on network..." -ForegroundColor $colors.Info
    & "$PSScriptRoot\scripts\development\start-network.ps1"
}

function Start-Backend {
    Write-Host "🚀 Starting Backend API..." -ForegroundColor $colors.Info
    & "$PSScriptRoot\scripts\development\start-backend.ps1"
}

function Start-FullStack {
    Write-Host "🚀 Starting Full Stack..." -ForegroundColor $colors.Info
    Write-Host "Opening 2 terminals..." -ForegroundColor $colors.Warning
    
    # Start backend in new terminal
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot'; .\scripts\development\start-backend.ps1"
    
    # Wait a bit
    Start-Sleep -Seconds 2
    
    # Start Vue in current terminal
    & "$PSScriptRoot\scripts\development\start-network.ps1"
}

function Invoke-SecurityAudit {
    Write-Host "🔒 Running security audit..." -ForegroundColor $colors.Warning
    & "$PSScriptRoot\scripts\production\security-audit.ps1"
}

function Build-Production {
    Write-Host "🏗️  Building for production..." -ForegroundColor $colors.Warning
    & "$PSScriptRoot\scripts\production\build-production.ps1"
}

function Deploy-Application {
    Write-Host "🚀 Deploy application..." -ForegroundColor $colors.Warning
    Write-Host ""
    Write-Host "Choose deploy target:" -ForegroundColor $colors.Info
    Write-Host "  [1] Local (test deployment)"
    Write-Host "  [2] Server (network share)"
    Write-Host "  [3] Cloud"
    Write-Host ""
    $target = Read-Host "Enter choice (1-3)"
    
    switch ($target) {
        "1" { & "$PSScriptRoot\scripts\production\deploy-production.ps1" -DeployTarget local }
        "2" { 
            $serverPath = Read-Host "Enter server path (e.g., \\server\share)"
            & "$PSScriptRoot\scripts\production\deploy-production.ps1" -DeployTarget server -ServerPath $serverPath
        }
        "3" { & "$PSScriptRoot\scripts\production\deploy-production.ps1" -DeployTarget cloud }
        default { Write-Host "Invalid choice!" -ForegroundColor $colors.Error }
    }
}

function Invoke-SecurityFix {
    Write-Host "🔧 Quick security fixes..." -ForegroundColor $colors.Warning
    Write-Host ""
    Write-Host "Choose fix:" -ForegroundColor $colors.Info
    Write-Host "  [1] XSS Protection"
    Write-Host "  [2] File Permissions (requires Admin)"
    Write-Host "  [3] Environment Setup"
    Write-Host "  [4] All fixes"
    Write-Host ""
    $fix = Read-Host "Enter choice (1-4)"
    
    switch ($fix) {
        "1" { & "$PSScriptRoot\scripts\production\security-fix.ps1" -XSS }
        "2" { & "$PSScriptRoot\scripts\production\security-fix.ps1" -Permissions }
        "3" { & "$PSScriptRoot\scripts\production\security-fix.ps1" -Environment }
        "4" { & "$PSScriptRoot\scripts\production\security-fix.ps1" -All }
        default { Write-Host "Invalid choice!" -ForegroundColor $colors.Error }
    }
}

function Invoke-Cleanup {
    Write-Host "🧹 Cleanup..." -ForegroundColor $colors.Success
    Write-Host ""
    Write-Host "Choose cleanup mode:" -ForegroundColor $colors.Info
    Write-Host "  [1] Dry run (show what will be deleted)"
    Write-Host "  [2] Normal cleanup"
    Write-Host "  [3] Deep clean (includes node_modules)"
    Write-Host ""
    $mode = Read-Host "Enter choice (1-3)"
    
    switch ($mode) {
        "1" { & "$PSScriptRoot\scripts\production\cleanup.ps1" -DryRun }
        "2" { & "$PSScriptRoot\scripts\production\cleanup.ps1" }
        "3" { & "$PSScriptRoot\scripts\production\cleanup.ps1" -DeepClean }
        default { Write-Host "Invalid choice!" -ForegroundColor $colors.Error }
    }
}

function Manage-Authentication {
    Write-Host "🔐 Authentication Management..." -ForegroundColor $colors.Warning
    Write-Host ""
    Write-Host "Choose action:" -ForegroundColor $colors.Info
    Write-Host "  [1] Add user"
    Write-Host "  [2] Remove user"
    Write-Host "  [3] List users"
    Write-Host "  [4] Reset password"
    Write-Host ""
    $action = Read-Host "Enter choice (1-4)"
    
    switch ($action) {
        "1" { & "$PSScriptRoot\scripts\production\auth-gate.ps1" -Action add-user }
        "2" { & "$PSScriptRoot\scripts\production\auth-gate.ps1" -Action remove-user }
        "3" { & "$PSScriptRoot\scripts\production\auth-gate.ps1" -Action list-users }
        "4" { & "$PSScriptRoot\scripts\production\auth-gate.ps1" -Action reset-password }
        default { Write-Host "Invalid choice!" -ForegroundColor $colors.Error }
    }
}

function Show-SecurityReport {
    $reportPath = "$PSScriptRoot\scripts\production\security-audit-report.json"
    if (Test-Path $reportPath) {
        Write-Host "📊 Security Report:" -ForegroundColor $colors.Info
        Write-Host ""
        $report = Get-Content $reportPath | ConvertFrom-Json
        
        Write-Host "  Total Issues: $($report.TotalIssues)" -ForegroundColor White
        Write-Host "  Critical: $($report.Critical)" -ForegroundColor $(if ($report.Critical -eq 0) { $colors.Success } else { $colors.Error })
        Write-Host "  Warnings: $($report.Warnings)" -ForegroundColor $colors.Warning
        Write-Host ""
        
        Write-Host "  Details:" -ForegroundColor $colors.Info
        foreach ($issue in $report.Issues) {
            $color = switch ($issue.Severity) {
                "CRITICAL" { $colors.Error }
                "WARNING" { $colors.Warning }
                default { $colors.Info }
            }
            Write-Host "    [$($issue.Severity)] $($issue.Description)" -ForegroundColor $color
        }
        Write-Host ""
        Write-Host "  Full report: $reportPath" -ForegroundColor $colors.Info
    } else {
        Write-Host "⚠️  No security report found. Run security audit first." -ForegroundColor $colors.Warning
    }
}

function Open-Documentation {
    Write-Host "📚 Opening documentation..." -ForegroundColor $colors.Info
    $docsPath = "$PSScriptRoot\docs\README.md"
    if (Test-Path $docsPath) {
        Start-Process $docsPath
    } else {
        Write-Host "⚠️  Documentation not found!" -ForegroundColor $colors.Error
    }
}

function Show-ProjectStructure {
    Write-Host "📁 Project Structure:" -ForegroundColor $colors.Info
    Write-Host ""
    Write-Host "WebAPI_App/" -ForegroundColor $colors.Header
    Write-Host "├── 📚 docs/                    # Documentation" -ForegroundColor $colors.Success
    Write-Host "├── 🔧 scripts/                 # Automation scripts" -ForegroundColor $colors.Success
    Write-Host "│   ├── production/            # Production scripts" -ForegroundColor White
    Write-Host "│   └── development/           # Development scripts" -ForegroundColor White
    Write-Host "├── 🎨 web_vue/                # Vue 3 Frontend" -ForegroundColor $colors.Success
    Write-Host "├── ⚙️  node_backend/          # Node.js Backend" -ForegroundColor $colors.Success
    Write-Host "├── 📊 streamlit_app/          # Streamlit app" -ForegroundColor $colors.Success
    Write-Host "└── 🚀 app-manager.ps1         # This script" -ForegroundColor $colors.Warning
    Write-Host ""
}

# Main loop
if ($Help) {
    Show-Header
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit
}

do {
    Show-Header
    Show-Menu
    
    $choice = Read-Host "Enter your choice (0-12)"
    Write-Host ""
    
    switch ($choice) {
        "1" { Start-Vue }
        "2" { Start-Backend }
        "3" { Start-FullStack }
        "4" { Invoke-SecurityAudit }
        "5" { Build-Production }
        "6" { Deploy-Application }
        "7" { Invoke-SecurityFix }
        "8" { Invoke-Cleanup }
        "9" { Manage-Authentication }
        "10" { Show-SecurityReport }
        "11" { Open-Documentation }
        "12" { Show-ProjectStructure }
        "0" { 
            Write-Host "👋 Goodbye!" -ForegroundColor $colors.Success
            exit 
        }
        default { 
            Write-Host "❌ Invalid choice! Please enter 0-12" -ForegroundColor $colors.Error 
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Write-Host "Press any key to continue..." -ForegroundColor $colors.Info
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($true)
