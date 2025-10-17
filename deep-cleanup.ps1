# 🧹 Deep Cleanup Script - Remove Redundant Files
# Xóa các file dư thừa để giảm dung lượng và tối ưu hệ thống

param(
    [switch]$DryRun,           # Chỉ hiển thị, không xóa
    [switch]$KeepNodeModules,  # Giữ node_modules
    [switch]$Force             # Không hỏi xác nhận
)

$colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
}

Write-Host "`n🧹 Deep Cleanup - Remove Redundant Files`n" -ForegroundColor $colors.Info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor $colors.Info

$totalSize = 0
$deletedCount = 0

function Get-FolderSize {
    param([string]$Path)
    $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum).Sum
    return [math]::Round($size / 1MB, 2)
}

function Remove-ItemSafe {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        $size = 0
        if (Test-Path $Path -PathType Container) {
            $size = Get-FolderSize $Path
        } else {
            $size = [math]::Round((Get-Item $Path).Length / 1MB, 2)
        }
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would delete: $Description ($size MB)" -ForegroundColor $colors.Warning
        } else {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  ✅ Deleted: $Description ($size MB)" -ForegroundColor $colors.Success
            $script:totalSize += $size
            $script:deletedCount++
        }
    }
}

# 1. Cache folders
Write-Host "1️⃣  Checking cache folders..." -ForegroundColor $colors.Info
Write-Host ""

$cachePaths = @(
    @{Path="web_vue\.vite"; Desc="Vite cache"},
    @{Path="web_vue\dist"; Desc="Vue build output"},
    @{Path="web_vue\.cache"; Desc="Vue cache"},
    @{Path="node_backend\dist"; Desc="Backend build output"},
    @{Path="node_backend\.cache"; Desc="Backend cache"},
    @{Path=".streamlit\cache"; Desc="Streamlit cache"}
)

foreach ($item in $cachePaths) {
    if (Test-Path $item.Path) {
        Remove-ItemSafe -Path $item.Path -Description $item.Desc
    }
}

# 2. Log files
Write-Host "`n2️⃣  Checking log files..." -ForegroundColor $colors.Info
Write-Host ""

$logFiles = Get-ChildItem -Recurse -Include "*.log", "npm-debug.log*", "yarn-debug.log*", "yarn-error.log*", "pnpm-debug.log*" -ErrorAction SilentlyContinue

foreach ($file in $logFiles) {
    Remove-ItemSafe -Path $file.FullName -Description "Log file: $($file.Name)"
}

# 3. Temp files
Write-Host "`n3️⃣  Checking temporary files..." -ForegroundColor $colors.Info
Write-Host ""

$tempFiles = Get-ChildItem -Recurse -Include "*.tmp", "*.temp", "~*", ".DS_Store", "Thumbs.db", "desktop.ini" -Force -ErrorAction SilentlyContinue

foreach ($file in $tempFiles) {
    Remove-ItemSafe -Path $file.FullName -Description "Temp file: $($file.Name)"
}

# 4. Backup files
Write-Host "`n4️⃣  Checking backup files..." -ForegroundColor $colors.Info
Write-Host ""

$backupFiles = Get-ChildItem -Recurse -Include "*.bak", "*.backup", "*.old", "*~", "*backup*" -ErrorAction SilentlyContinue | 
               Where-Object { $_.FullName -notmatch 'node_modules' }

foreach ($file in $backupFiles) {
    Remove-ItemSafe -Path $file.FullName -Description "Backup file: $($file.Name)"
}

# 5. Duplicate/old files in root
Write-Host "`n5️⃣  Checking duplicate files in root..." -ForegroundColor $colors.Info
Write-Host ""

$duplicates = @(
    "app-manager.backup.ps1",
    "app-manager-clean.ps1",
    "app-manager-old.ps1",
    "app_vue.html"  # Legacy HTML file
)

foreach ($file in $duplicates) {
    if (Test-Path $file) {
        Remove-ItemSafe -Path $file -Description "Duplicate/old file: $file"
    }
}

# 6. Coverage reports
Write-Host "`n6️⃣  Checking coverage reports..." -ForegroundColor $colors.Info
Write-Host ""

$coveragePaths = @(
    "web_vue\coverage",
    "node_backend\coverage",
    ".nyc_output"
)

foreach ($path in $coveragePaths) {
    if (Test-Path $path) {
        Remove-ItemSafe -Path $path -Description "Coverage report: $path"
    }
}

# 7. node_modules (optional - BIG cleanup)
if (-not $KeepNodeModules) {
    Write-Host "`n7️⃣  Checking node_modules folders..." -ForegroundColor $colors.Info
    Write-Host ""
    Write-Host "  ⚠️  This will delete ALL node_modules!" -ForegroundColor $colors.Warning
    Write-Host "  You'll need to run 'pnpm install' after cleanup." -ForegroundColor $colors.Warning
    Write-Host ""
    
    if (-not $Force -and -not $DryRun) {
        $confirm = Read-Host "Delete node_modules? (y/N)"
        if ($confirm -ne "y") {
            Write-Host "  ⏭️  Skipped node_modules" -ForegroundColor $colors.Info
        } else {
            $nodeModulesPaths = @(
                "node_modules",
                "web_vue\node_modules",
                "node_backend\node_modules"
            )
            
            foreach ($path in $nodeModulesPaths) {
                if (Test-Path $path) {
                    Remove-ItemSafe -Path $path -Description "Node modules: $path"
                }
            }
        }
    } elseif ($DryRun) {
        Write-Host "  [DRY RUN] Would ask to delete node_modules (~63 MB)" -ForegroundColor $colors.Warning
    } else {
        $nodeModulesPaths = @(
            "node_modules",
            "web_vue\node_modules",
            "node_backend\node_modules"
        )
        
        foreach ($path in $nodeModulesPaths) {
            if (Test-Path $path) {
                Remove-ItemSafe -Path $path -Description "Node modules: $path"
            }
        }
    }
}

# 8. Git objects optimization (optional)
Write-Host "`n8️⃣  Git optimization..." -ForegroundColor $colors.Info
Write-Host ""

if (Test-Path ".git") {
    $gitSize = Get-FolderSize ".git"
    Write-Host "  Current .git size: $gitSize MB" -ForegroundColor $colors.Info
    
    if (-not $DryRun) {
        Write-Host "  Running git gc (garbage collection)..." -ForegroundColor $colors.Info
        git gc --aggressive --prune=now 2>$null
        $newGitSize = Get-FolderSize ".git"
        $saved = $gitSize - $newGitSize
        if ($saved -gt 0) {
            Write-Host "  ✅ Git optimized: Saved $saved MB" -ForegroundColor $colors.Success
        } else {
            Write-Host "  ✅ Git already optimized" -ForegroundColor $colors.Success
        }
    } else {
        Write-Host "  [DRY RUN] Would run: git gc --aggressive --prune=now" -ForegroundColor $colors.Warning
    }
}

# Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $colors.Info
Write-Host "📊 Cleanup Summary" -ForegroundColor $colors.Info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor $colors.Info

if ($DryRun) {
    Write-Host "  ℹ️  DRY RUN MODE - No files were actually deleted" -ForegroundColor $colors.Warning
    Write-Host "  Run without -DryRun to perform actual cleanup" -ForegroundColor $colors.Info
} else {
    Write-Host "  ✅ Files deleted: $deletedCount" -ForegroundColor $colors.Success
    Write-Host "  ✅ Space freed: $totalSize MB" -ForegroundColor $colors.Success
    
    if (-not $KeepNodeModules -and $deletedCount -gt 0) {
        Write-Host "`n  ⚠️  Remember to reinstall dependencies:" -ForegroundColor $colors.Warning
        Write-Host "     pnpm install" -ForegroundColor $colors.Info
    }
}

Write-Host ""

# Recommendations
Write-Host "💡 Recommendations:" -ForegroundColor $colors.Info
Write-Host ""
Write-Host "  1. Run this cleanup periodically (weekly/monthly)" -ForegroundColor White
Write-Host "  2. Add to .gitignore: *.log, *.tmp, *.bak, .cache/" -ForegroundColor White
Write-Host "  3. Use 'pnpm store prune' to clean pnpm cache" -ForegroundColor White
Write-Host "  4. Consider using 'git lfs' for large binary files" -ForegroundColor White
Write-Host ""

<#
.SYNOPSIS
    Deep cleanup script to remove redundant files and free up space

.DESCRIPTION
    Removes cache, logs, temp files, backups, and optionally node_modules
    
    What gets cleaned:
    - Vite cache (.vite, dist)
    - Log files (*.log, npm-debug.log, etc.)
    - Temp files (*.tmp, *.temp, ~*)
    - Backup files (*.bak, *.backup, *.old)
    - Duplicate/old files in root
    - Coverage reports
    - node_modules (optional)
    - Git optimization (git gc)

.PARAMETER DryRun
    Show what would be deleted without actually deleting

.PARAMETER KeepNodeModules
    Keep node_modules folders (don't delete)

.PARAMETER Force
    Don't ask for confirmation (auto-yes)

.EXAMPLE
    .\deep-cleanup.ps1 -DryRun
    Preview what will be deleted

.EXAMPLE
    .\deep-cleanup.ps1
    Perform cleanup (asks for confirmation for node_modules)

.EXAMPLE
    .\deep-cleanup.ps1 -KeepNodeModules
    Cleanup everything except node_modules

.EXAMPLE
    .\deep-cleanup.ps1 -Force
    Cleanup everything including node_modules without confirmation

.NOTES
    Version: 1.0.0
    Author: HoangThinh2024
    Last Updated: 2025-10-17
#>
