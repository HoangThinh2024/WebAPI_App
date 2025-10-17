# Quick Fix Script for Security Issues
# Tự động fix các vấn đề từ security audit

param(
    [switch]$XSS,           # Fix XSS protection
    [switch]$Permissions,   # Fix file permissions
    [switch]$Environment,   # Setup environment variables
    [switch]$All            # Fix all issues
)

$ErrorActionPreference = "Continue"

function Write-Section {
    param($Title)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

Write-Host "`n🔧 Security Quick Fix" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

$fixCount = 0

# ============================================================================
# 1. FIX XSS PROTECTION (v-html sanitization)
# ============================================================================
if ($XSS -or $All) {
    Write-Section "1. Installing DOMPurify for XSS Protection"
    
    Push-Location (Join-Path $PSScriptRoot "web_vue")
    
    try {
        Write-Host "  📦 Installing dompurify..." -ForegroundColor Yellow
        
        # Check if pnpm or npm
        if (Test-Path "pnpm-lock.yaml") {
            pnpm add dompurify
            pnpm add -D @types/dompurify
        } else {
            npm install dompurify
            npm install --save-dev @types/dompurify
        }
        
        Write-Host "  ✅ DOMPurify installed" -ForegroundColor Green
        $fixCount++
        
        # Create sanitizer utility
        $sanitizerPath = Join-Path "src\utils" "sanitizer.js"
        if (-not (Test-Path (Split-Path $sanitizerPath -Parent))) {
            New-Item -Path (Split-Path $sanitizerPath -Parent) -ItemType Directory -Force | Out-Null
        }
        
        @"
// HTML Sanitizer utility using DOMPurify
import DOMPurify from 'dompurify'

/**
 * Sanitize HTML content to prevent XSS attacks
 * @param {string} dirty - Unsanitized HTML string
 * @param {object} config - DOMPurify configuration
 * @returns {string} - Sanitized HTML string
 */
export function sanitizeHTML(dirty, config = {}) {
  const defaultConfig = {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'u', 'a', 'ul', 'ol', 'li', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'div', 'span'],
    ALLOWED_ATTR: ['href', 'target', 'class', 'style'],
    ALLOW_DATA_ATTR: false
  }
  
  return DOMPurify.sanitize(dirty, { ...defaultConfig, ...config })
}

/**
 * Create a safe HTML render function for Vue
 * Usage: v-html="safeHTML(content)"
 */
export function useSafeHTML() {
  return {
    safeHTML: (html) => sanitizeHTML(html)
  }
}
"@ | Out-File -FilePath $sanitizerPath -Encoding utf8
        
        Write-Host "  ✅ Created: src\utils\sanitizer.js" -ForegroundColor Green
        Write-Host "`n  💡 Update MessagesList.vue to use sanitizer:" -ForegroundColor Yellow
        Write-Host "     import { sanitizeHTML } from '@/utils/sanitizer'" -ForegroundColor Gray
        Write-Host "     <div v-html=`"sanitizeHTML(message.body)`"></div>" -ForegroundColor Gray
        
    } catch {
        Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Pop-Location
}

# ============================================================================
# 2. FIX FILE PERMISSIONS
# ============================================================================
if ($Permissions -or $All) {
    Write-Section "2. Restricting File Permissions"
    
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "  ⚠️  Administrator rights required to modify permissions" -ForegroundColor Yellow
        Write-Host "  Please run PowerShell as Administrator and execute:" -ForegroundColor Cyan
        Write-Host "    .\security-fix.ps1 -Permissions`n" -ForegroundColor White
    } else {
        $filesToSecure = @(
            "web_vue\.env",
            "start-backend.ps1",
            "start-network.ps1",
            "auth-gate.ps1",
            ".auth\users.json"
        )
        
        foreach ($file in $filesToSecure) {
            $fullPath = Join-Path $PSScriptRoot $file
            
            if (Test-Path $fullPath) {
                try {
                    # Get current ACL
                    $acl = Get-Acl $fullPath
                    
                    # Remove inheritance
                    $acl.SetAccessRuleProtection($true, $false)
                    
                    # Remove all existing rules
                    $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
                    
                    # Add Administrator full control
                    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                        "BUILTIN\Administrators", "FullControl", "Allow"
                    )
                    $acl.SetAccessRule($adminRule)
                    
                    # Add current user full control
                    $userRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                        $env:USERNAME, "FullControl", "Allow"
                    )
                    $acl.SetAccessRule($userRule)
                    
                    # Apply ACL
                    Set-Acl -Path $fullPath -AclObject $acl
                    
                    Write-Host "  ✅ Secured: $file" -ForegroundColor Green
                    $fixCount++
                } catch {
                    Write-Host "  ❌ Failed to secure $file : $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
}

# ============================================================================
# 3. SETUP ENVIRONMENT VARIABLES
# ============================================================================
if ($Environment -or $All) {
    Write-Section "3. Environment Variables Setup"
    
    # Check current environment
    $nodeEnv = $env:NODE_ENV
    $apiTarget = $env:VITE_API_TARGET
    
    Write-Host "  Current settings:" -ForegroundColor Yellow
    Write-Host "    NODE_ENV: $(if ($nodeEnv) { $nodeEnv } else { 'Not set' })" -ForegroundColor Gray
    Write-Host "    VITE_API_TARGET: $(if ($apiTarget) { $apiTarget } else { 'Not set' })`n" -ForegroundColor Gray
    
    # Production .env.production
    $prodEnvPath = Join-Path $PSScriptRoot "web_vue\.env.production"
    if (-not (Test-Path $prodEnvPath)) {
        @"
# Production Environment Configuration
NODE_ENV=production

# API Configuration
VITE_API_TARGET=https://your-production-api.com

# Feature Flags
VITE_ENABLE_DEBUG=false
VITE_ENABLE_CONSOLE=false

# Security
VITE_ENABLE_SOURCE_MAPS=false
"@ | Out-File -FilePath $prodEnvPath -Encoding utf8
        
        Write-Host "  ✅ Created: web_vue\.env.production" -ForegroundColor Green
        $fixCount++
    }
    
    # Development .env (if not exists)
    $devEnvPath = Join-Path $PSScriptRoot "web_vue\.env"
    if (-not (Test-Path $devEnvPath)) {
        @"
# Development Environment Configuration
VITE_API_TARGET=http://localhost:3000

# Feature Flags
VITE_ENABLE_DEBUG=true
"@ | Out-File -FilePath $devEnvPath -Encoding utf8
        
        Write-Host "  ✅ Created: web_vue\.env (development)" -ForegroundColor Green
        $fixCount++
    }
    
    Write-Host "`n  💡 Environment files created:" -ForegroundColor Cyan
    Write-Host "    - .env (development)" -ForegroundColor White
    Write-Host "    - .env.production (production)" -ForegroundColor White
}

# ============================================================================
# 4. UPDATE .GITIGNORE
# ============================================================================
if ($All) {
    Write-Section "4. Updating .gitignore"
    
    $gitignorePath = Join-Path $PSScriptRoot ".gitignore"
    $gitignoreContent = if (Test-Path $gitignorePath) { Get-Content $gitignorePath -Raw } else { "" }
    
    $requiredPatterns = @(
        "# Environment files",
        ".env",
        ".env.local",
        ".env.production",
        ".env.*.local",
        "",
        "# Authentication",
        ".auth/",
        "",
        "# Security reports",
        "security-audit-report.json",
        "",
        "# Deployment",
        "deploy/",
        "*.zip"
    )
    
    $needsUpdate = $false
    foreach ($pattern in $requiredPatterns) {
        if ($pattern -and $gitignoreContent -notmatch [regex]::Escape($pattern)) {
            $needsUpdate = $true
            break
        }
    }
    
    if ($needsUpdate) {
        $requiredPatterns -join "`n" | Add-Content -Path $gitignorePath
        Write-Host "  ✅ Updated .gitignore" -ForegroundColor Green
        $fixCount++
    } else {
        Write-Host "  ✅ .gitignore already up to date" -ForegroundColor Green
    }
}

# ============================================================================
# SUMMARY
# ============================================================================
Write-Section "Summary"

Write-Host "`n  📊 Fixes Applied: $fixCount" -ForegroundColor Cyan

if ($fixCount -gt 0) {
    Write-Host "  ✅ Security improvements completed!" -ForegroundColor Green
    
    Write-Host "`n  🔄 Next steps:" -ForegroundColor Yellow
    Write-Host "    1. Update MessagesList.vue to use sanitizer" -ForegroundColor White
    Write-Host "    2. Run: .\security-audit.ps1 (verify fixes)" -ForegroundColor White
    Write-Host "    3. Test application" -ForegroundColor White
    Write-Host "    4. Commit changes" -ForegroundColor White
} else {
    Write-Host "  ℹ️  No fixes selected or already applied" -ForegroundColor Cyan
    Write-Host "`n  Usage:" -ForegroundColor Yellow
    Write-Host "    .\security-fix.ps1 -XSS          # Fix XSS protection" -ForegroundColor White
    Write-Host "    .\security-fix.ps1 -Permissions  # Fix file permissions" -ForegroundColor White
    Write-Host "    .\security-fix.ps1 -Environment  # Setup env vars" -ForegroundColor White
    Write-Host "    .\security-fix.ps1 -All          # Fix all issues" -ForegroundColor White
}

Write-Host "`n✅ Done!`n" -ForegroundColor Green
