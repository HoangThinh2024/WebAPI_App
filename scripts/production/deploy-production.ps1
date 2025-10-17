# Complete Production Deployment Script
# Tự động hóa toàn bộ quy trình: audit → cleanup → build → test → deploy

param(
    [switch]$SkipAudit,
    [switch]$SkipTests,
    [switch]$AutoConfirm,
    [string]$DeployTarget = "local"  # local, staging, production
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

function Write-Section {
    param($Title, $Color = "Cyan")
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Color
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Color
}

function Confirm-Step {
    param($Message)
    
    if ($AutoConfirm) {
        return $true
    }
    
    $response = Read-Host "$Message (Y/N)"
    return $response -eq 'Y'
}

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 WebAPI_App Production Deployment    ║" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`nTarget: $DeployTarget" -ForegroundColor Yellow
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

# ============================================================================
# STEP 1: AUTHENTICATION
# ============================================================================
Write-Section "Step 1: Authentication Required" "Red"

$authenticated = $false
if (Test-Path (Join-Path $PSScriptRoot "auth-gate.ps1")) {
    Write-Host "  🔐 Running authentication check..." -ForegroundColor Yellow
    
    # Run auth in same session
    $authScript = Join-Path $PSScriptRoot "auth-gate.ps1"
    & $authScript -Action check
    
    if ($LASTEXITCODE -eq 0) {
        $authenticated = $true
        Write-Host "  ✅ Authentication successful" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Authentication failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ⚠️  auth-gate.ps1 not found, skipping auth" -ForegroundColor Yellow
    if (-not (Confirm-Step "Continue without authentication?")) {
        exit 1
    }
}

# ============================================================================
# STEP 2: PRE-DEPLOYMENT CHECKS
# ============================================================================
Write-Section "Step 2: Pre-Deployment Checks"

Write-Host "  🔍 Checking Git status..." -ForegroundColor Yellow
try {
    $gitStatus = git status --porcelain 2>&1
    if ($gitStatus) {
        Write-Host "  ⚠️  Uncommitted changes detected:" -ForegroundColor Yellow
        Write-Host "    $gitStatus" -ForegroundColor Gray
        
        if (-not (Confirm-Step "Continue with uncommitted changes?")) {
            Write-Host "`n  💡 Tip: Commit your changes first:" -ForegroundColor Cyan
            Write-Host "    git add ." -ForegroundColor White
            Write-Host "    git commit -m 'Pre-deployment commit'" -ForegroundColor White
            exit 1
        }
    } else {
        Write-Host "  ✅ Git working tree clean" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Git not available or not a repository" -ForegroundColor Yellow
}

Write-Host "`n  🔍 Checking disk space..." -ForegroundColor Yellow
$drive = (Get-Location).Drive
$freeSpace = ($drive.Free / 1GB)
if ($freeSpace -lt 1) {
    Write-Host "  ⚠️  Low disk space: $([math]::Round($freeSpace, 2)) GB" -ForegroundColor Red
    if (-not (Confirm-Step "Continue with low disk space?")) {
        exit 1
    }
} else {
    Write-Host "  ✅ Disk space: $([math]::Round($freeSpace, 2)) GB available" -ForegroundColor Green
}

# ============================================================================
# STEP 3: SECURITY AUDIT
# ============================================================================
if (-not $SkipAudit) {
    Write-Section "Step 3: Security Audit"
    
    $auditScript = Join-Path $PSScriptRoot "security-audit.ps1"
    if (Test-Path $auditScript) {
        & $auditScript
        
        if ($LASTEXITCODE -eq 1) {
            Write-Host "`n  ❌ Critical security issues found!" -ForegroundColor Red
            Write-Host "  Review security-audit-report.json for details" -ForegroundColor Yellow
            
            if (-not (Confirm-Step "Deploy anyway? (NOT RECOMMENDED)")) {
                exit 1
            }
        }
    } else {
        Write-Host "  ⚠️  Security audit script not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  Skipping security audit (not recommended)" -ForegroundColor Yellow
}

# ============================================================================
# STEP 4: CLEANUP
# ============================================================================
Write-Section "Step 4: Cleanup Old Builds"

$cleanupScript = Join-Path $PSScriptRoot "cleanup.ps1"
if (Test-Path $cleanupScript) {
    Write-Host "  🧹 Running cleanup..." -ForegroundColor Yellow
    & $cleanupScript -Cache
    Write-Host "  ✅ Cleanup completed" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Cleanup script not found, skipping" -ForegroundColor Yellow
}

# ============================================================================
# STEP 5: BUILD
# ============================================================================
Write-Section "Step 5: Production Build"

$buildScript = Join-Path $PSScriptRoot "build-production.ps1"
if (Test-Path $buildScript) {
    Write-Host "  🏗️  Building production bundle..." -ForegroundColor Yellow
    & $buildScript -SkipAudit
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n  ❌ Build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "  ✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "  ❌ Build script not found!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 6: TESTING
# ============================================================================
if (-not $SkipTests) {
    Write-Section "Step 6: Testing Production Build"
    
    Write-Host "  🧪 Starting test server..." -ForegroundColor Yellow
    
    # Test backend health
    Push-Location (Join-Path $PSScriptRoot "node_backend")
    $backendJob = Start-Job -ScriptBlock {
        param($Path)
        Set-Location $Path
        node src/server.js
    } -ArgumentList (Get-Location)
    Pop-Location
    
    Start-Sleep -Seconds 3
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "  ✅ Backend health check passed" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Backend health check failed" -ForegroundColor Red
        Stop-Job $backendJob
        Remove-Job $backendJob
        exit 1
    }
    
    Stop-Job $backendJob
    Remove-Job $backendJob
    
    # Test frontend build
    $distPath = Join-Path $PSScriptRoot "web_vue\dist"
    if (Test-Path $distPath) {
        $indexPath = Join-Path $distPath "index.html"
        if (Test-Path $indexPath) {
            Write-Host "  ✅ Frontend build structure valid" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Frontend index.html not found" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  ❌ Frontend dist folder not found" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ⚠️  Skipping tests" -ForegroundColor Yellow
}

# ============================================================================
# STEP 7: DEPLOYMENT PREPARATION
# ============================================================================
Write-Section "Step 7: Deployment Preparation"

$deployPath = Join-Path $PSScriptRoot "deploy"
if (Test-Path $deployPath) {
    $deploySize = (Get-ChildItem -Path $deployPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  📦 Package size: $([math]::Round($deploySize, 2)) MB" -ForegroundColor Cyan
    Write-Host "  📁 Package location: $deployPath" -ForegroundColor Cyan
    
    # Create archive
    $archiveName = "webapi-app-v2.2.2-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
    $archivePath = Join-Path $PSScriptRoot $archiveName
    
    Write-Host "`n  📦 Creating deployment archive..." -ForegroundColor Yellow
    Compress-Archive -Path "$deployPath\*" -DestinationPath $archivePath -Force
    
    $archiveSize = (Get-Item $archivePath).Length / 1MB
    Write-Host "  ✅ Archive created: $archiveName ($([math]::Round($archiveSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Deploy folder not found!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 8: DEPLOYMENT (Based on Target)
# ============================================================================
Write-Section "Step 8: Deployment to $DeployTarget"

switch ($DeployTarget.ToLower()) {
    "local" {
        Write-Host "  ℹ️  Local deployment selected" -ForegroundColor Cyan
        Write-Host "  📁 Files ready in: $deployPath" -ForegroundColor White
        Write-Host "`n  To test locally:" -ForegroundColor Yellow
        Write-Host "    cd deploy" -ForegroundColor White
        Write-Host "    .\start-production.ps1" -ForegroundColor White
    }
    
    "staging" {
        Write-Host "  🚀 Deploying to staging server..." -ForegroundColor Yellow
        Write-Host "  ⚠️  Manual step required:" -ForegroundColor Yellow
        Write-Host "    1. Upload $archiveName to staging server" -ForegroundColor White
        Write-Host "    2. Extract and run deploy\start-production.ps1" -ForegroundColor White
        Write-Host "    3. Configure environment variables" -ForegroundColor White
    }
    
    "production" {
        Write-Host "  ⚠️  PRODUCTION DEPLOYMENT" -ForegroundColor Red
        Write-Host "  This will deploy to LIVE production server!" -ForegroundColor Red
        
        if (-not (Confirm-Step "`n  Are you ABSOLUTELY SURE you want to deploy to production?")) {
            Write-Host "`n  Deployment cancelled" -ForegroundColor Yellow
            exit 0
        }
        
        Write-Host "`n  🚀 Production deployment steps:" -ForegroundColor Yellow
        Write-Host "    1. Backup current production" -ForegroundColor White
        Write-Host "    2. Upload $archiveName" -ForegroundColor White
        Write-Host "    3. Extract to production directory" -ForegroundColor White
        Write-Host "    4. Update environment variables" -ForegroundColor White
        Write-Host "    5. Restart services (PM2/IIS)" -ForegroundColor White
        Write-Host "    6. Test production URL" -ForegroundColor White
        Write-Host "    7. Monitor logs for errors" -ForegroundColor White
        
        # Create deployment checklist
        $checklistPath = Join-Path $PSScriptRoot "deployment-checklist-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        @"
# Production Deployment Checklist

**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Version:** 2.2.2
**Archive:** $archiveName

## Pre-Deployment

- [ ] Backup current production files
- [ ] Backup production database (if applicable)
- [ ] Notify team of deployment window
- [ ] Prepare rollback plan

## Deployment Steps

1. [ ] Stop production services
   \`\`\`bash
   pm2 stop webapi-backend
   \`\`\`

2. [ ] Backup current directory
   \`\`\`bash
   cp -r /var/www/webapi-app /var/www/webapi-app.backup
   \`\`\`

3. [ ] Upload and extract new version
   \`\`\`bash
   scp $archiveName user@server:/tmp/
   cd /var/www/webapi-app
   unzip /tmp/$archiveName
   \`\`\`

4. [ ] Install dependencies
   \`\`\`bash
   cd backend
   npm install --production
   \`\`\`

5. [ ] Update environment variables
   \`\`\`bash
   nano .env
   # Set production values
   \`\`\`

6. [ ] Start services
   \`\`\`bash
   pm2 restart webapi-backend
   pm2 save
   \`\`\`

7. [ ] Test health endpoints
   \`\`\`bash
   curl https://your-domain.com/api/health
   \`\`\`

8. [ ] Monitor logs
   \`\`\`bash
   pm2 logs webapi-backend
   \`\`\`

## Post-Deployment

- [ ] Test critical user flows
- [ ] Check error rates in monitoring
- [ ] Verify API responses
- [ ] Test authentication
- [ ] Monitor performance metrics

## Rollback (if needed)

\`\`\`bash
pm2 stop webapi-backend
rm -rf /var/www/webapi-app
mv /var/www/webapi-app.backup /var/www/webapi-app
pm2 start webapi-backend
\`\`\`

## Notes

- Deployment time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- Deployed by: $env:USERNAME
- Issues encountered: ___________

"@ | Out-File -FilePath $checklistPath -Encoding utf8
        
        Write-Host "`n  📋 Checklist saved: $(Split-Path $checklistPath -Leaf)" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "  ❌ Invalid deploy target: $DeployTarget" -ForegroundColor Red
        Write-Host "  Valid targets: local, staging, production" -ForegroundColor Yellow
        exit 1
    }
}

# ============================================================================
# STEP 9: FINAL REPORT
# ============================================================================
Write-Section "Step 9: Deployment Report" "Green"

$elapsedTime = (Get-Date) - $startTime

Write-Host "`n  ✅ Deployment process completed successfully!" -ForegroundColor Green
Write-Host "`n  📊 Summary:" -ForegroundColor White
Write-Host "    Target: $DeployTarget" -ForegroundColor Cyan
Write-Host "    Version: 2.2.2" -ForegroundColor Cyan
Write-Host "    Time: $($elapsedTime.TotalMinutes.ToString('0.00')) minutes" -ForegroundColor Cyan
Write-Host "    Archive: $archiveName" -ForegroundColor Cyan
Write-Host "    Size: $([math]::Round($archiveSize, 2)) MB" -ForegroundColor Cyan

Write-Host "`n  📁 Generated Files:" -ForegroundColor White
Write-Host "    - $archiveName (deployment package)" -ForegroundColor Gray
Write-Host "    - deploy\README.md (deployment guide)" -ForegroundColor Gray
Write-Host "    - security-audit-report.json (security report)" -ForegroundColor Gray
if ($DeployTarget -eq "production") {
    Write-Host "    - deployment-checklist-*.md (checklist)" -ForegroundColor Gray
}

Write-Host "`n  🔗 Next Steps:" -ForegroundColor Yellow
if ($DeployTarget -eq "local") {
    Write-Host "    1. cd deploy" -ForegroundColor White
    Write-Host "    2. .\start-production.ps1" -ForegroundColor White
    Write-Host "    3. Open http://localhost" -ForegroundColor White
} else {
    Write-Host "    1. Review deployment checklist" -ForegroundColor White
    Write-Host "    2. Upload $archiveName to server" -ForegroundColor White
    Write-Host "    3. Follow deployment guide in deploy\README.md" -ForegroundColor White
}

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  🎉 Deployment Ready!                   ║" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════╝`n" -ForegroundColor Green
