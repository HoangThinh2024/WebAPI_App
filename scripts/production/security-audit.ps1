# Security Audit Script for WebAPI_App
# Kiểm tra bảo mật toàn diện trước khi deploy

param(
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$issues = @()
$criticalIssues = 0
$warningIssues = 0

function Write-Section {
    param($Title)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Add-Issue {
    param(
        [string]$Severity,  # "CRITICAL", "WARNING", "INFO"
        [string]$Category,
        [string]$Description,
        [string]$Fix = ""
    )
    
    $script:issues += [PSCustomObject]@{
        Severity = $Severity
        Category = $Category
        Description = $Description
        Fix = $Fix
    }
    
    if ($Severity -eq "CRITICAL") { $script:criticalIssues++ }
    if ($Severity -eq "WARNING") { $script:warningIssues++ }
}

Write-Host "`n🔒 Security Audit for WebAPI_App" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

# ============================================================================
# 1. CHECK SENSITIVE FILES
# ============================================================================
Write-Section "1. Sensitive Files Check"

$sensitiveFiles = @(
    ".env",
    "web_vue/.env",
    "node_backend/.env",
    "streamlit_app/.env",
    ".env.local",
    ".env.production",
    "config/secrets.json",
    "config/credentials.json"
)

foreach ($file in $sensitiveFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  ⚠️  Found: $file" -ForegroundColor Yellow
        
        # Check if file contains actual secrets
        $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
        if ($content -match "token|password|secret|key|api_key" -and $content -notmatch "YOUR_|EXAMPLE_|PLACEHOLDER") {
            Add-Issue -Severity "CRITICAL" -Category "Secrets" `
                -Description "$file contains real secrets" `
                -Fix "Add to .gitignore and remove from git history"
        }
    }
}

# Check .gitignore
$gitignorePath = Join-Path $PSScriptRoot ".gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    $requiredIgnores = @(".env", ".env.local", ".env.production", "*.log", "node_modules", "dist", "__pycache__")
    
    foreach ($pattern in $requiredIgnores) {
        if ($gitignoreContent -notmatch [regex]::Escape($pattern)) {
            Add-Issue -Severity "WARNING" -Category "Git" `
                -Description ".gitignore missing: $pattern" `
                -Fix "Add '$pattern' to .gitignore"
        }
    }
    Write-Host "  ✅ .gitignore exists" -ForegroundColor Green
} else {
    Add-Issue -Severity "CRITICAL" -Category "Git" `
        -Description ".gitignore not found" `
        -Fix "Create .gitignore file"
}

# ============================================================================
# 2. CHECK FOR HARDCODED SECRETS
# ============================================================================
Write-Section "2. Hardcoded Secrets Scan"

$codeFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.js,*.vue,*.py,*.ts -Exclude node_modules,dist,venv,.venv,__pycache__

$secretPatterns = @{
    "API Keys" = "(?i)(api[_-]?key|apikey)\s*[:=]\s*['\`"][a-zA-Z0-9_-]{20,}['\`"]"
    "Passwords" = "(?i)(password|passwd|pwd)\s*[:=]\s*['\`"][^'\`"]{8,}['\`"]"
    "Tokens" = "(?i)(token|auth[_-]?token)\s*[:=]\s*['\`"][a-zA-Z0-9_-]{30,}['\`"]"
    "Base64 Secrets" = "(?i)(secret|key)\s*[:=]\s*['\`"][A-Za-z0-9+/]{40,}={0,2}['\`"]"
}

$foundSecrets = 0
foreach ($file in $codeFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    foreach ($patternName in $secretPatterns.Keys) {
        if ($content -match $secretPatterns[$patternName]) {
            # Exclude common false positives
            if ($content -notmatch "process\.env\.|import\.|example|placeholder|YOUR_|TODO") {
                $foundSecrets++
                Add-Issue -Severity "CRITICAL" -Category "Hardcoded Secrets" `
                    -Description "$patternName found in $($file.Name)" `
                    -Fix "Move to environment variables"
                Write-Host "  ⚠️  $patternName in: $($file.Name)" -ForegroundColor Red
            }
        }
    }
}

if ($foundSecrets -eq 0) {
    Write-Host "  ✅ No hardcoded secrets found" -ForegroundColor Green
}

# ============================================================================
# 3. CHECK DEPENDENCIES VULNERABILITIES
# ============================================================================
Write-Section "3. Dependencies Security Check"

# Check Node.js dependencies
$packageJsonPath = Join-Path $PSScriptRoot "web_vue\package.json"
if (Test-Path $packageJsonPath) {
    Write-Host "  🔍 Checking npm packages..." -ForegroundColor Yellow
    
    Push-Location (Join-Path $PSScriptRoot "web_vue")
    
    # Check for package-lock.json
    if (-not (Test-Path "package-lock.json") -and -not (Test-Path "pnpm-lock.yaml")) {
        Add-Issue -Severity "WARNING" -Category "Dependencies" `
            -Description "No lock file found for npm packages" `
            -Fix "Run 'npm install' or 'pnpm install'"
    }
    
    # Run npm audit (if npm is available)
    try {
        $auditResult = npm audit --json 2>$null | ConvertFrom-Json
        if ($auditResult.metadata.vulnerabilities.critical -gt 0) {
            Add-Issue -Severity "CRITICAL" -Category "Dependencies" `
                -Description "$($auditResult.metadata.vulnerabilities.critical) critical npm vulnerabilities" `
                -Fix "Run 'npm audit fix'"
        }
        if ($auditResult.metadata.vulnerabilities.high -gt 0) {
            Add-Issue -Severity "WARNING" -Category "Dependencies" `
                -Description "$($auditResult.metadata.vulnerabilities.high) high npm vulnerabilities" `
                -Fix "Run 'npm audit fix'"
        }
        Write-Host "  ✅ npm audit completed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  npm audit failed or npm not found" -ForegroundColor Yellow
    }
    
    Pop-Location
}

# Check Python dependencies
$requirementsPath = Join-Path $PSScriptRoot "streamlit_app\requirements.txt"
if (Test-Path $requirementsPath) {
    Write-Host "  🔍 Checking Python packages..." -ForegroundColor Yellow
    
    try {
        # Check if safety is installed
        $safetyCheck = pip show safety 2>$null
        if ($safetyCheck) {
            $safetyResult = safety check --json --file $requirementsPath 2>$null | ConvertFrom-Json
            if ($safetyResult.Count -gt 0) {
                Add-Issue -Severity "WARNING" -Category "Dependencies" `
                    -Description "$($safetyResult.Count) Python package vulnerabilities" `
                    -Fix "Run 'pip install --upgrade <package>'"
            }
            Write-Host "  ✅ Python packages checked" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️  Install 'safety' for Python security checks: pip install safety" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "  ⚠️  Python security check skipped" -ForegroundColor Yellow
    }
}

# ============================================================================
# 4. CHECK CODE QUALITY & SECURITY PATTERNS
# ============================================================================
Write-Section "4. Code Security Patterns"

# Check for console.log in production code
Write-Host "  🔍 Checking for debug statements..." -ForegroundColor Yellow
$jsFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "web_vue\src") -Recurse -Include *.js,*.vue -ErrorAction SilentlyContinue
$consoleLogCount = 0
foreach ($file in $jsFiles) {
    $foundMatches = Select-String -Path $file.FullName -Pattern "console\.(log|debug|info)" -ErrorAction SilentlyContinue
    if ($foundMatches) {
        $consoleLogCount += $foundMatches.Count
    }
}

if ($consoleLogCount -gt 0) {
    Add-Issue -Severity "WARNING" -Category "Code Quality" `
        -Description "$consoleLogCount console.log statements found" `
        -Fix "Remove or wrap in if(DEBUG) checks"
    Write-Host "  ⚠️  $consoleLogCount console statements found" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ No console.log in code" -ForegroundColor Green
}

# Check for eval() usage (dangerous) - exclude node_modules
$evalFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.js,*.vue,*.ts | 
    Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\dist\\' }
foreach ($file in $evalFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match "\beval\s*\(") {
        Add-Issue -Severity "CRITICAL" -Category "Code Security" `
            -Description "eval() usage in $($file.Name)" `
            -Fix "Remove eval() - it's a security risk"
    }
}

# Check for v-html without sanitization
$vueFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "web_vue\src") -Recurse -Include *.vue -ErrorAction SilentlyContinue
$unsafeHtmlCount = 0
foreach ($file in $vueFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match "v-html" -and $content -notmatch "DOMPurify|sanitize") {
        $unsafeHtmlCount++
    }
}

if ($unsafeHtmlCount -gt 0) {
    Add-Issue -Severity "WARNING" -Category "XSS Protection" `
        -Description "$unsafeHtmlCount v-html without sanitization" `
        -Fix "Use DOMPurify to sanitize HTML content"
    Write-Host "  ⚠️  $unsafeHtmlCount unsafe v-html usage" -ForegroundColor Yellow
}

# ============================================================================
# 5. CHECK CORS CONFIGURATION
# ============================================================================
Write-Section "5. CORS & Network Security"

$serverFile = Join-Path $PSScriptRoot "node_backend\src\server.js"
if (Test-Path $serverFile) {
    $serverContent = Get-Content $serverFile -Raw
    
    if ($serverContent -match "cors\(\{[^}]*origin:\s*true") {
        Add-Issue -Severity "WARNING" -Category "CORS" `
            -Description "CORS allows all origins (origin: true)" `
            -Fix "Specify allowed origins explicitly"
        Write-Host "  ⚠️  CORS allows all origins" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ CORS configured" -ForegroundColor Green
    }
    
    # Check if listening on 0.0.0.0 in production
    if ($serverContent -match "listen\([^,]+,\s*['\`"]0\.0\.0\.0['\`"]") {
        Add-Issue -Severity "INFO" -Category "Network" `
            -Description "Server listens on 0.0.0.0 (all interfaces)" `
            -Fix "For production, consider specific IP or use reverse proxy"
    }
}

# ============================================================================
# 6. CHECK FILE PERMISSIONS (Windows)
# ============================================================================
Write-Section "6. File Permissions Check"

$sensitiveFiles = @(
    "web_vue\.env",
    "node_backend\.env",
    "start-backend.ps1",
    "start-network.ps1"
)

foreach ($file in $sensitiveFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        $acl = Get-Acl $fullPath
        $everyoneAccess = $acl.Access | Where-Object { $_.IdentityReference -like "*Everyone*" -or $_.IdentityReference -like "*Users*" }
        
        if ($everyoneAccess) {
            Add-Issue -Severity "WARNING" -Category "Permissions" `
                -Description "$file accessible by Everyone/Users" `
                -Fix "Restrict file permissions"
            Write-Host "  ⚠️  $file has wide permissions" -ForegroundColor Yellow
        }
    }
}

Write-Host "  ✅ Permission check completed" -ForegroundColor Green

# ============================================================================
# 7. CHECK ENVIRONMENT VARIABLES
# ============================================================================
Write-Section "7. Environment Variables Check"

# Check if production env vars are properly set
$requiredEnvVars = @{
    "NODE_ENV" = "Should be 'production' for production builds"
    "VITE_API_TARGET" = "Should point to production API"
}

foreach ($varName in $requiredEnvVars.Keys) {
    $value = [System.Environment]::GetEnvironmentVariable($varName)
    if (-not $value) {
        Add-Issue -Severity "INFO" -Category "Environment" `
            -Description "$varName not set: $($requiredEnvVars[$varName])"
    }
}

Write-Host "  ✅ Environment check completed" -ForegroundColor Green

# ============================================================================
# 8. GENERATE REPORT
# ============================================================================
Write-Section "8. Security Audit Report"

Write-Host "`n  📊 Summary:" -ForegroundColor White
Write-Host "    Total Issues: $($issues.Count)" -ForegroundColor $(if ($issues.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "    Critical: $criticalIssues" -ForegroundColor $(if ($criticalIssues -eq 0) { "Green" } else { "Red" })
Write-Host "    Warnings: $warningIssues" -ForegroundColor $(if ($warningIssues -eq 0) { "Green" } else { "Yellow" })
Write-Host "    Info: $($issues.Count - $criticalIssues - $warningIssues)" -ForegroundColor Cyan

if ($issues.Count -gt 0) {
    Write-Host "`n  📋 Issues Details:`n" -ForegroundColor White
    
    foreach ($issue in $issues) {
        $color = switch ($issue.Severity) {
            "CRITICAL" { "Red" }
            "WARNING" { "Yellow" }
            default { "Cyan" }
        }
        
        Write-Host "  [$($issue.Severity)] $($issue.Category)" -ForegroundColor $color
        Write-Host "    ➜ $($issue.Description)" -ForegroundColor White
        if ($issue.Fix) {
            Write-Host "    💡 Fix: $($issue.Fix)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Save report to file
$reportPath = Join-Path $PSScriptRoot "security-audit-report.json"
$reportData = @{
    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    TotalIssues = $issues.Count
    Critical = $criticalIssues
    Warnings = $warningIssues
    Issues = $issues
} | ConvertTo-Json -Depth 10

$reportData | Out-File -FilePath $reportPath -Encoding utf8
Write-Host "  💾 Report saved: security-audit-report.json" -ForegroundColor Cyan

# ============================================================================
# 9. DECISION
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($criticalIssues -gt 0) {
    Write-Host "  ❌ FAILED: $criticalIssues critical security issues found!" -ForegroundColor Red
    Write-Host "  ⛔ DO NOT deploy to production!" -ForegroundColor Red
    exit 1
} elseif ($warningIssues -gt 0) {
    Write-Host "  ⚠️  PASSED WITH WARNINGS: $warningIssues issues found" -ForegroundColor Yellow
    Write-Host "  ℹ️  Review warnings before deploying" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  ✅ PASSED: No security issues found!" -ForegroundColor Green
    Write-Host "  🚀 Safe to deploy to production" -ForegroundColor Green
    exit 0
}
