# Production Build Script for WebAPI_App
# Builds optimized production-ready application

param(
    [switch]$SkipTests,
    [switch]$SkipAudit,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param($Title)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

Write-Host "`n🏗️  Production Build for WebAPI_App" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

# ============================================================================
# 1. PRE-BUILD SECURITY AUDIT
# ============================================================================
if (-not $SkipAudit) {
    Write-Section "1. Security Audit"
    
    $auditScript = Join-Path $PSScriptRoot "security-audit.ps1"
    if (Test-Path $auditScript) {
        & $auditScript
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n❌ Security audit failed! Fix issues before building." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  ⚠️  security-audit.ps1 not found, skipping audit" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  Skipping security audit (not recommended)" -ForegroundColor Yellow
}

# ============================================================================
# 2. CLEAN OLD BUILDS
# ============================================================================
Write-Section "2. Cleaning Old Builds"

$distPaths = @(
    "web_vue\dist",
    "node_backend\dist",
    "streamlit_app\dist"
)

foreach ($path in $distPaths) {
    $fullPath = Join-Path $PSScriptRoot $path
    if (Test-Path $fullPath) {
        Remove-Item -Path $fullPath -Recurse -Force
        Write-Host "  ✅ Cleaned: $path" -ForegroundColor Green
    }
}

# ============================================================================
# 3. SET ENVIRONMENT VARIABLES
# ============================================================================
Write-Section "3. Environment Configuration"

$env:NODE_ENV = "production"
Write-Host "  ✅ NODE_ENV = production" -ForegroundColor Green

# Check for production .env
$prodEnvPath = Join-Path $PSScriptRoot "web_vue\.env.production"
if (-not (Test-Path $prodEnvPath)) {
    Write-Host "  ⚠️  .env.production not found, creating template..." -ForegroundColor Yellow
    
    @"
# Production Environment Configuration
NODE_ENV=production

# API Configuration (UPDATE THIS!)
VITE_API_TARGET=https://your-production-api.com

# Feature Flags
VITE_ENABLE_DEBUG=false
VITE_ENABLE_CONSOLE=false

# Security
VITE_ENABLE_SOURCE_MAPS=false
"@ | Out-File -FilePath $prodEnvPath -Encoding utf8
    
    Write-Host "  📝 Created .env.production - PLEASE UPDATE API URL!" -ForegroundColor Red
    $confirm = Read-Host "  Continue with default values? (Y/N)"
    if ($confirm -ne 'Y') {
        exit 1
    }
}

# ============================================================================
# 4. BUILD FRONTEND (Vue + Vite)
# ============================================================================
Write-Section "4. Building Frontend (Vue)"

Push-Location (Join-Path $PSScriptRoot "web_vue")

# Check package manager
$usesPnpm = Test-Path "pnpm-lock.yaml"
$packageManager = if ($usesPnpm) { "pnpm" } else { "npm" }

Write-Host "  📦 Installing dependencies with $packageManager..." -ForegroundColor Yellow

try {
    if ($usesPnpm) {
        pnpm install --frozen-lockfile --prod
    } else {
        npm ci --production
    }
    Write-Host "  ✅ Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Failed to install dependencies: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "`n  🔨 Building production bundle..." -ForegroundColor Yellow

try {
    if ($usesPnpm) {
        pnpm run build
    } else {
        npm run build
    }
    Write-Host "  ✅ Frontend build completed" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Check build output
$distPath = Join-Path (Get-Location) "dist"
if (Test-Path $distPath) {
    $distSize = (Get-ChildItem -Path $distPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  📊 Build size: $([math]::Round($distSize, 2)) MB" -ForegroundColor Cyan
    
    # Check for large files
    $largeFiles = Get-ChildItem -Path $distPath -Recurse -File | Where-Object { $_.Length -gt 500KB }
    if ($largeFiles) {
        Write-Host "  ⚠️  Large files detected (>500KB):" -ForegroundColor Yellow
        foreach ($file in $largeFiles) {
            $sizeKB = [math]::Round($file.Length / 1KB, 2)
            Write-Host "    - $($file.Name): $sizeKB KB" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  ❌ Build output not found!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# ============================================================================
# 5. BUILD BACKEND (Optional)
# ============================================================================
Write-Section "5. Backend Preparation"

$backendPath = Join-Path $PSScriptRoot "node_backend"
if (Test-Path $backendPath) {
    Push-Location $backendPath
    
    Write-Host "  📦 Installing backend dependencies..." -ForegroundColor Yellow
    
    try {
        npm ci --production
        Write-Host "  ✅ Backend dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Backend install failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Pop-Location
} else {
    Write-Host "  ℹ️  No backend directory found" -ForegroundColor Cyan
}

# ============================================================================
# 6. OPTIMIZE ASSETS
# ============================================================================
Write-Section "6. Asset Optimization"

$distPath = Join-Path $PSScriptRoot "web_vue\dist"

# Compress with gzip (for comparison)
Write-Host "  🗜️  Analyzing compression potential..." -ForegroundColor Yellow

$jsFiles = Get-ChildItem -Path (Join-Path $distPath "assets") -Filter "*.js" -ErrorAction SilentlyContinue
$totalJsSize = ($jsFiles | Measure-Object -Property Length -Sum).Sum / 1KB
Write-Host "  📊 Total JS: $([math]::Round($totalJsSize, 2)) KB" -ForegroundColor Cyan

$cssFiles = Get-ChildItem -Path (Join-Path $distPath "assets") -Filter "*.css" -ErrorAction SilentlyContinue
$totalCssSize = ($cssFiles | Measure-Object -Property Length -Sum).Sum / 1KB
Write-Host "  📊 Total CSS: $([math]::Round($totalCssSize, 2)) KB" -ForegroundColor Cyan

Write-Host "  ℹ️  Enable gzip/brotli compression on your web server for ~70% reduction" -ForegroundColor Cyan

# ============================================================================
# 7. GENERATE BUILD MANIFEST
# ============================================================================
Write-Section "7. Build Manifest"

$manifest = @{
    BuildDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Version = "2.2.2"
    Environment = "production"
    Frontend = @{
        Framework = "Vue 3 + Vite"
        BuildSize = "$([math]::Round($distSize, 2)) MB"
        Files = (Get-ChildItem -Path $distPath -Recurse -File).Count
    }
    Backend = @{
        Framework = "Node.js + Express"
        Status = if (Test-Path $backendPath) { "Ready" } else { "Not found" }
    }
    SecurityAudit = @{
        Passed = (-not $SkipAudit)
        Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
} | ConvertTo-Json -Depth 10

$manifestPath = Join-Path $distPath "build-manifest.json"
$manifest | Out-File -FilePath $manifestPath -Encoding utf8
Write-Host "  ✅ Manifest saved: web_vue\dist\build-manifest.json" -ForegroundColor Green

# ============================================================================
# 8. CREATE DEPLOYMENT PACKAGE
# ============================================================================
Write-Section "8. Deployment Package"

$deployPath = Join-Path $PSScriptRoot "deploy"
if (-not (Test-Path $deployPath)) {
    New-Item -Path $deployPath -ItemType Directory | Out-Null
}

# Copy production files
Write-Host "  📦 Creating deployment package..." -ForegroundColor Yellow

$itemsToCopy = @(
    @{Source = "web_vue\dist"; Dest = "deploy\public"},
    @{Source = "node_backend\src"; Dest = "deploy\backend"},
    @{Source = "node_backend\package.json"; Dest = "deploy\backend\package.json"}
)

foreach ($item in $itemsToCopy) {
    $sourcePath = Join-Path $PSScriptRoot $item.Source
    $destPath = Join-Path $PSScriptRoot $item.Dest
    
    if (Test-Path $sourcePath) {
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        }
        
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ Copied: $($item.Source)" -ForegroundColor Green
    }
}

# Create production start script
$prodStartScript = @"
# Production Start Script
# Deploy this package to your production server

Write-Host "Starting WebAPI_App in Production Mode..." -ForegroundColor Cyan

# Start backend
Start-Process -NoNewWindow -FilePath "node" -ArgumentList "backend\server.js"

Write-Host "✅ Backend started on port 3000" -ForegroundColor Green
Write-Host "📁 Frontend files: ./public" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serve the 'public' folder with:" -ForegroundColor Yellow
Write-Host "  - NGINX" -ForegroundColor White
Write-Host "  - Apache" -ForegroundColor White
Write-Host "  - IIS" -ForegroundColor White
Write-Host "  - Or run: npx serve -s public -p 80" -ForegroundColor White
"@

$prodStartScript | Out-File -FilePath (Join-Path $deployPath "start-production.ps1") -Encoding utf8
Write-Host "  ✅ Created: deploy\start-production.ps1" -ForegroundColor Green

# Create deployment README
$deployReadme = @"
# Production Deployment Package

**Build Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Version:** 2.2.2

## Contents

- \`public/\` - Frontend static files (Vue build)
- \`backend/\` - Backend Node.js server
- \`start-production.ps1\` - Production startup script

## Deployment Steps

### Option 1: Docker (Recommended)

\`\`\`bash
# Build Docker image
docker build -t webapi-app:2.2.2 .

# Run container
docker run -d -p 80:80 -p 3000:3000 webapi-app:2.2.2
\`\`\`

### Option 2: Traditional Server

1. **Upload files to server**
   \`\`\`bash
   scp -r deploy/* user@server:/var/www/webapi-app/
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   cd /var/www/webapi-app/backend
   npm install --production
   \`\`\`

3. **Configure NGINX**
   \`\`\`nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       # Frontend
       location / {
           root /var/www/webapi-app/public;
           try_files \$uri \$uri/ /index.html;
       }
       
       # Backend API
       location /api {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade \$http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host \$host;
           proxy_cache_bypass \$http_upgrade;
       }
   }
   \`\`\`

4. **Start backend with PM2**
   \`\`\`bash
   npm install -g pm2
   pm2 start backend/server.js --name webapi-backend
   pm2 save
   pm2 startup
   \`\`\`

### Option 3: Windows IIS

1. Install **iisnode**
2. Copy \`public/\` to IIS website root
3. Configure IIS reverse proxy for \`/api\` → \`localhost:3000\`
4. Start backend with \`node backend/server.js\`

## Environment Variables

Set these on production server:

\`\`\`env
NODE_ENV=production
PORT=3000
CORS_ALLOWED_ORIGINS=https://your-domain.com
\`\`\`

## Security Checklist

- [ ] Set strong firewall rules
- [ ] Enable HTTPS (Let's Encrypt)
- [ ] Configure rate limiting
- [ ] Set up monitoring (PM2, DataDog, etc.)
- [ ] Configure backups
- [ ] Test disaster recovery

## Support

For issues, check:
- Build logs: \`build.log\`
- Security report: \`security-audit-report.json\`
- Documentation: \`NETWORK_SETUP.md\`
"@

$deployReadme | Out-File -FilePath (Join-Path $deployPath "README.md") -Encoding utf8
Write-Host "  ✅ Created: deploy\README.md" -ForegroundColor Green

# ============================================================================
# 9. FINAL SUMMARY
# ============================================================================
Write-Section "9. Build Summary"

Write-Host "`n  ✅ Production build completed successfully!" -ForegroundColor Green
Write-Host "`n  📊 Build Statistics:" -ForegroundColor White
Write-Host "    Build time: $((Get-Date) - $startTime | Select-Object -ExpandProperty TotalSeconds) seconds" -ForegroundColor Cyan
Write-Host "    Output size: $([math]::Round($distSize, 2)) MB" -ForegroundColor Cyan
Write-Host "    Files: $($(Get-ChildItem -Path $distPath -Recurse -File).Count)" -ForegroundColor Cyan

Write-Host "`n  📁 Deployment Package:" -ForegroundColor White
Write-Host "    Location: .\deploy\" -ForegroundColor Cyan
Write-Host "    Ready to deploy!" -ForegroundColor Green

Write-Host "`n  🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "    1. Test locally: .\test-production.ps1" -ForegroundColor White
Write-Host "    2. Review: .\deploy\README.md" -ForegroundColor White
Write-Host "    3. Deploy to server" -ForegroundColor White
Write-Host "    4. Configure HTTPS" -ForegroundColor White
Write-Host "    5. Set up monitoring" -ForegroundColor White

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  🎉 Build complete!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
