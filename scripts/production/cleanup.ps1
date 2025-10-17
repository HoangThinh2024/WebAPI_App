# Cleanup Script for WebAPI_App
# Xóa cache, logs, temporary files, và sensitive data

param(
    [switch]$Deep,      # Deep clean including node_modules
    [switch]$Logs,      # Clean only logs
    [switch]$Cache,     # Clean only cache
    [switch]$All,       # Clean everything
    [switch]$DryRun     # Show what would be deleted without actually deleting
)

$ErrorActionPreference = "Continue"
$totalSize = 0
$fileCount = 0

function Write-Section {
    param($Title)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Get-FolderSize {
    param($Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

function Remove-ItemSafe {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (-not (Test-Path $Path)) {
        return
    }
    
    $size = Get-FolderSize $Path
    $script:totalSize += $size
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would delete: $Description ($size MB)" -ForegroundColor Yellow
    } else {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Host "  ✅ Deleted: $Description ($size MB)" -ForegroundColor Green
            $script:fileCount++
        } catch {
            Write-Host "  ❌ Failed to delete: $Description - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n🧹 Cleanup Script for WebAPI_App" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "  ℹ️  DRY RUN MODE - No files will be deleted" -ForegroundColor Cyan
}

# ============================================================================
# 1. CLEAN NODE.JS CACHE & BUILDS
# ============================================================================
if ($Cache -or $All -or (-not $Logs)) {
    Write-Section "1. Node.js Cache & Build Artifacts"
    
    # Frontend
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "web_vue\dist") -Description "Frontend build (dist)"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "web_vue\.vite") -Description "Vite cache"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "web_vue\node_modules\.cache") -Description "Node modules cache"
    
    # Backend
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "node_backend\dist") -Description "Backend build"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "node_backend\.cache") -Description "Backend cache"
    
    if ($Deep -or $All) {
        Write-Host "`n  ⚠️  DEEP CLEAN: Removing node_modules..." -ForegroundColor Yellow
        Remove-ItemSafe -Path (Join-Path $PSScriptRoot "web_vue\node_modules") -Description "Frontend node_modules"
        Remove-ItemSafe -Path (Join-Path $PSScriptRoot "node_backend\node_modules") -Description "Backend node_modules"
    }
}

# ============================================================================
# 2. CLEAN PYTHON CACHE
# ============================================================================
if ($Cache -or $All -or (-not $Logs)) {
    Write-Section "2. Python Cache & Build Artifacts"
    
    # Python cache directories
    $pycacheDirs = Get-ChildItem -Path $PSScriptRoot -Recurse -Directory -Filter "__pycache__" -ErrorAction SilentlyContinue
    foreach ($dir in $pycacheDirs) {
        Remove-ItemSafe -Path $dir.FullName -Description "Python cache ($($dir.FullName.Replace($PSScriptRoot, '')))"
    }
    
    # .pyc files
    $pycFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.pyc" -ErrorAction SilentlyContinue
    foreach ($file in $pycFiles) {
        Remove-ItemSafe -Path $file.FullName -Description "Compiled Python ($($file.Name))"
    }
    
    # Python build artifacts
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "streamlit_app\build") -Description "Python build"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "streamlit_app\dist") -Description "Python dist"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "streamlit_app\*.egg-info") -Description "Egg info"
    
    if ($Deep -or $All) {
        Remove-ItemSafe -Path (Join-Path $PSScriptRoot "streamlit_app\venv") -Description "Python virtual env"
        Remove-ItemSafe -Path (Join-Path $PSScriptRoot "streamlit_app\.venv") -Description "Python virtual env (alt)"
    }
}

# ============================================================================
# 3. CLEAN LOG FILES
# ============================================================================
if ($Logs -or $All -or (-not $Cache)) {
    Write-Section "3. Log Files"
    
    $logPatterns = @("*.log", "*.log.*", "npm-debug.log*", "yarn-debug.log*", "yarn-error.log*")
    
    foreach ($pattern in $logPatterns) {
        $logFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter $pattern -ErrorAction SilentlyContinue |
                    Where-Object { $_.DirectoryName -notmatch "node_modules" }
        
        foreach ($file in $logFiles) {
            $sizeKB = [math]::Round($file.Length / 1KB, 2)
            Remove-ItemSafe -Path $file.FullName -Description "Log file ($($file.Name) - $sizeKB KB)"
        }
    }
    
    # Clean Windows event logs (optional)
    Write-Host "`n  ℹ️  Check Windows Event Viewer for application logs" -ForegroundColor Cyan
}

# ============================================================================
# 4. CLEAN TEMPORARY FILES
# ============================================================================
if ($All -or (-not $Logs -and -not $Cache)) {
    Write-Section "4. Temporary Files"
    
    # Temp directories
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "temp") -Description "Temp directory"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot "tmp") -Description "Tmp directory"
    Remove-ItemSafe -Path (Join-Path $PSScriptRoot ".tmp") -Description "Hidden tmp"
    
    # OS temp files
    $tempFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Include "*.tmp", "*.temp", "*~" -ErrorAction SilentlyContinue |
                 Where-Object { $_.DirectoryName -notmatch "node_modules" }
    
    foreach ($file in $tempFiles) {
        Remove-ItemSafe -Path $file.FullName -Description "Temp file ($($file.Name))"
    }
    
    # Thumbnail cache
    $thumbsDb = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "Thumbs.db" -ErrorAction SilentlyContinue
    foreach ($file in $thumbsDb) {
        Remove-ItemSafe -Path $file.FullName -Description "Thumbs.db"
    }
    
    # DS_Store (Mac)
    $dsStore = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter ".DS_Store" -ErrorAction SilentlyContinue
    foreach ($file in $dsStore) {
        Remove-ItemSafe -Path $file.FullName -Description ".DS_Store"
    }
}

# ============================================================================
# 5. CLEAN SENSITIVE DATA (CAREFUL!)
# ============================================================================
if ($All) {
    Write-Section "5. Sensitive Data (⚠️ CAREFUL!)"
    
    Write-Host "`n  ⚠️  WARNING: This will delete sensitive configuration files!" -ForegroundColor Red
    Write-Host "  Files to be removed:" -ForegroundColor Yellow
    Write-Host "    - .env files (keep .env.example)" -ForegroundColor White
    Write-Host "    - security-audit-report.json" -ForegroundColor White
    Write-Host "    - Any backup files (*.bak)" -ForegroundColor White
    
    $confirm = Read-Host "`n  Type 'YES' to confirm deletion of sensitive data"
    
    if ($confirm -eq 'YES') {
        # .env files (but keep .env.example)
        $envFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter ".env" -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -eq ".env" -and $_.DirectoryName -notmatch "node_modules" }
        
        foreach ($file in $envFiles) {
            Remove-ItemSafe -Path $file.FullName -Description ".env file ($($file.FullName.Replace($PSScriptRoot, '')))"
        }
        
        # Security reports
        Remove-ItemSafe -Path (Join-Path $PSScriptRoot "security-audit-report.json") -Description "Security audit report"
        
        # Backup files
        $backupFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Include "*.bak", "*.backup", "*.old" -ErrorAction SilentlyContinue |
                       Where-Object { $_.DirectoryName -notmatch "node_modules" }
        
        foreach ($file in $backupFiles) {
            Remove-ItemSafe -Path $file.FullName -Description "Backup file ($($file.Name))"
        }
    } else {
        Write-Host "  ℹ️  Skipped sensitive data cleanup" -ForegroundColor Cyan
    }
}

# ============================================================================
# 6. CLEAN GIT ARTIFACTS
# ============================================================================
if ($All) {
    Write-Section "6. Git Artifacts"
    
    # Git cache
    $gitDir = Join-Path $PSScriptRoot ".git"
    if (Test-Path $gitDir) {
        # Run git gc to optimize repository
        try {
            Push-Location $PSScriptRoot
            git gc --aggressive --prune=now 2>&1 | Out-Null
            Write-Host "  ✅ Git repository optimized" -ForegroundColor Green
            Pop-Location
        } catch {
            Write-Host "  ⚠️  Git optimization skipped" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# 7. CLEAN BROWSER CACHE (IF APPLICABLE)
# ============================================================================
if ($All) {
    Write-Section "7. Development Browser Cache"
    
    Write-Host "  ℹ️  To clean browser cache:" -ForegroundColor Cyan
    Write-Host "    Chrome/Edge: Ctrl+Shift+Delete" -ForegroundColor White
    Write-Host "    Firefox: Ctrl+Shift+Delete" -ForegroundColor White
    Write-Host "    Or use browser DevTools → Application → Clear storage" -ForegroundColor White
}

# ============================================================================
# 8. SUMMARY
# ============================================================================
Write-Section "8. Cleanup Summary"

Write-Host "`n  📊 Results:" -ForegroundColor White
Write-Host "    Items processed: $fileCount" -ForegroundColor Cyan
Write-Host "    Space freed: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`n  ℹ️  This was a DRY RUN - no files were actually deleted" -ForegroundColor Yellow
    Write-Host "  Run without -DryRun to perform actual cleanup" -ForegroundColor Cyan
}

# Recommendations
Write-Host "`n  💡 Recommendations:" -ForegroundColor White

if (-not $Deep -and -not $All) {
    Write-Host "    - Run with -Deep to remove node_modules (saves ~500MB)" -ForegroundColor Cyan
    Write-Host "      Then run: npm install / pnpm install" -ForegroundColor Gray
}

if (-not $All) {
    Write-Host "    - Run with -All for complete cleanup (includes sensitive data)" -ForegroundColor Cyan
}

Write-Host "`n  🔄 Next steps:" -ForegroundColor White
Write-Host "    1. Run: .\security-audit.ps1" -ForegroundColor Cyan
Write-Host "    2. If passed, run: .\build-production.ps1" -ForegroundColor Cyan
Write-Host "    3. Test build: .\test-production.ps1" -ForegroundColor Cyan

Write-Host "`n✅ Cleanup completed!" -ForegroundColor Green
