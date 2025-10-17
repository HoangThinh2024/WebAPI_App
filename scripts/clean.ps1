# Clean Script for Windows PowerShell
# Xóa các tệp build, cache và dependencies
# Sử dụng: .\scripts\clean.ps1

$ErrorActionPreference = "Continue"

# Màu sắc
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-Host ""
Write-ColorOutput Cyan "🧹 Clean Script - Xóa tệp build và cache"
Write-Host ""

$rootDir = Split-Path -Parent $PSScriptRoot
Write-ColorOutput Blue "📂 Project root: $rootDir"
Write-Host ""

# Danh sách các thư mục/file cần xóa
$targets = @(
    @{ Path = "web_vue\node_modules"; Desc = "Frontend dependencies" },
    @{ Path = "node_backend\node_modules"; Desc = "Backend dependencies" },
    @{ Path = "node_modules"; Desc = "Root dependencies" },
    @{ Path = "web_vue\dist"; Desc = "Frontend build output" },
    @{ Path = "node_backend\dist"; Desc = "Backend build output" },
    @{ Path = "dist"; Desc = "Root build output" },
    @{ Path = "web_vue\.vite"; Desc = "Vite cache" },
    @{ Path = ".vite"; Desc = "Root Vite cache" },
    @{ Path = "web_vue\.eslintcache"; Desc = "Frontend ESLint cache" },
    @{ Path = "node_backend\.eslintcache"; Desc = "Backend ESLint cache" },
    @{ Path = ".eslintcache"; Desc = "Root ESLint cache" },
    @{ Path = ".DS_Store"; Desc = "macOS metadata" },
    @{ Path = "Thumbs.db"; Desc = "Windows thumbnail cache" }
)

$deletedCount = 0
$totalFreed = 0

Write-ColorOutput Yellow "🔍 Scanning for files to delete..."
Write-Host ""

foreach ($target in $targets) {
    $fullPath = Join-Path $rootDir $target.Path
    
    if (Test-Path $fullPath) {
        $size = (Get-ChildItem -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        
        if ($null -eq $size) { $size = 0 }
        
        Write-ColorOutput Yellow "  🗑️  Deleting: $($target.Desc) ($([math]::Round($size/1MB, 2)) MB)..."
        
        try {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction Stop
            $totalFreed += $size
            $deletedCount++
            Write-ColorOutput Green "  ✓ Deleted: $($target.Path)"
        } catch {
            Write-ColorOutput Red "  ✗ Error: $_"
        }
    } else {
        Write-Host "  ⊘ Not found: $($target.Path)"
    }
}

# Xóa log files
$logFiles = Get-ChildItem -Path $rootDir -Filter "*.log" -Recurse -ErrorAction SilentlyContinue
foreach ($log in $logFiles) {
    try {
        $size = $log.Length
        Remove-Item -Path $log.FullName -Force
        $totalFreed += $size
        $deletedCount++
        Write-ColorOutput Green "  ✓ Deleted log: $($log.Name)"
    } catch {
        Write-ColorOutput Red "  ✗ Error deleting $($log.Name)"
    }
}

Write-Host ""
Write-ColorOutput Cyan "============================================================"
Write-ColorOutput White "🎉 Clean completed!"
Write-ColorOutput Green "📊 Files/Folders deleted: $deletedCount"
Write-ColorOutput Green "💾 Disk space freed: $([math]::Round($totalFreed/1MB, 2)) MB"
Write-ColorOutput Cyan "============================================================"
Write-Host ""

if ($totalFreed -gt 0) {
    Write-ColorOutput Blue "💡 Tip: Run 'pnpm install' to reinstall dependencies"
    Write-Host ""
}
