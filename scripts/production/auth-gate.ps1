# Authentication Gate Script
# Yêu cầu xác thực trước khi truy cập ứng dụng

param(
    [string]$Action = "check",  # check, add-user, remove-user, list-users
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"
$authFile = Join-Path $PSScriptRoot ".auth\users.json"
$authDir = Join-Path $PSScriptRoot ".auth"

function Get-Hash {
    param([string]$Text)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash).Replace("-", "").ToLower()
}

function Initialize-AuthSystem {
    if (-not (Test-Path $authDir)) {
        New-Item -Path $authDir -ItemType Directory | Out-Null
        
        # Add to .gitignore
        $gitignorePath = Join-Path $PSScriptRoot ".gitignore"
        if (Test-Path $gitignorePath) {
            Add-Content -Path $gitignorePath -Value "`n# Authentication`n.auth/" -ErrorAction SilentlyContinue
        }
    }
    
    if (-not (Test-Path $authFile)) {
        # Create with default admin user (CHANGE THIS!)
        $defaultUsers = @{
            users = @(
                @{
                    username = "admin"
                    passwordHash = Get-Hash "admin123"  # CHANGE THIS!
                    role = "admin"
                    createdAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    lastLogin = $null
                }
            )
        }
        
        $defaultUsers | ConvertTo-Json -Depth 10 | Out-File -FilePath $authFile -Encoding utf8
        
        Write-Host "`n⚠️  WARNING: Default admin account created!" -ForegroundColor Red
        Write-Host "  Username: admin" -ForegroundColor Yellow
        Write-Host "  Password: admin123" -ForegroundColor Yellow
        Write-Host "`n  ⚠️  CHANGE THIS IMMEDIATELY!" -ForegroundColor Red
        Write-Host "  Run: .\auth-gate.ps1 -Action add-user`n" -ForegroundColor Cyan
    }
}

function Get-Users {
    if (-not (Test-Path $authFile)) {
        return @()
    }
    
    $data = Get-Content $authFile -Raw | ConvertFrom-Json
    return $data.users
}

function Save-Users {
    param($Users)
    
    $data = @{ users = $Users }
    $data | ConvertTo-Json -Depth 10 | Out-File -FilePath $authFile -Encoding utf8
}

function Add-User {
    param(
        [string]$Username,
        [string]$Password,
        [string]$Role = "user"
    )
    
    Initialize-AuthSystem
    
    $users = Get-Users
    
    # Check if user exists
    if ($users | Where-Object { $_.username -eq $Username }) {
        Write-Host "`n❌ User '$Username' already exists!" -ForegroundColor Red
        return $false
    }
    
    # Add new user
    $newUser = @{
        username = $Username
        passwordHash = Get-Hash $Password
        role = $Role
        createdAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        lastLogin = $null
    }
    
    $users += $newUser
    Save-Users $users
    
    Write-Host "`n✅ User '$Username' added successfully!" -ForegroundColor Green
    return $true
}

function Remove-User {
    param([string]$Username)
    
    $users = Get-Users
    $users = $users | Where-Object { $_.username -ne $Username }
    Save-Users $users
    
    Write-Host "`n✅ User '$Username' removed" -ForegroundColor Green
}

function Test-Credentials {
    param(
        [string]$Username,
        [string]$Password
    )
    
    $users = Get-Users
    $user = $users | Where-Object { $_.username -eq $Username }
    
    if (-not $user) {
        return $false
    }
    
    $passwordHash = Get-Hash $Password
    
    if ($user.passwordHash -eq $passwordHash) {
        # Update last login
        $user.lastLogin = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Save-Users $users
        return $true
    }
    
    return $false
}

function Show-LoginPrompt {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  🔐 WebAPI_App Authentication" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
    
    $maxAttempts = 3
    $attempts = 0
    
    while ($attempts -lt $maxAttempts) {
        $username = Read-Host "Username"
        $passwordSecure = Read-Host "Password" -AsSecureString
        $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordSecure)
        )
        
        if (Test-Credentials -Username $username -Password $password) {
            Write-Host "`n✅ Authentication successful!" -ForegroundColor Green
            Write-Host "Welcome, $username!`n" -ForegroundColor Cyan
            return $true
        } else {
            $attempts++
            $remaining = $maxAttempts - $attempts
            
            if ($remaining -gt 0) {
                Write-Host "`n❌ Invalid credentials. $remaining attempts remaining.`n" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n❌ Authentication failed. Access denied.`n" -ForegroundColor Red
    return $false
}

# ============================================================================
# MAIN
# ============================================================================

Initialize-AuthSystem

switch ($Action.ToLower()) {
    "check" {
        # Show login prompt
        if (-not (Show-LoginPrompt)) {
            exit 1
        }
        
        # If authenticated, show options
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "  What would you like to do?" -ForegroundColor White
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "`n  1. Start Development Server" -ForegroundColor Yellow
        Write-Host "  2. Start Network Mode" -ForegroundColor Yellow
        Write-Host "  3. Build Production" -ForegroundColor Yellow
        Write-Host "  4. Run Security Audit" -ForegroundColor Yellow
        Write-Host "  5. View Application Status" -ForegroundColor Yellow
        Write-Host "  6. Exit`n" -ForegroundColor Yellow
        
        $choice = Read-Host "Enter choice (1-6)"
        
        switch ($choice) {
            "1" {
                Write-Host "`n🚀 Starting development server...`n" -ForegroundColor Cyan
                & (Join-Path $PSScriptRoot "start-backend.ps1")
            }
            "2" {
                Write-Host "`n🌐 Starting network mode...`n" -ForegroundColor Cyan
                & (Join-Path $PSScriptRoot "start-network.ps1")
            }
            "3" {
                Write-Host "`n🏗️  Building production...`n" -ForegroundColor Cyan
                & (Join-Path $PSScriptRoot "build-production.ps1")
            }
            "4" {
                Write-Host "`n🔒 Running security audit...`n" -ForegroundColor Cyan
                & (Join-Path $PSScriptRoot "security-audit.ps1")
            }
            "5" {
                Write-Host "`n📊 Application Status:`n" -ForegroundColor Cyan
                
                # Check backend
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
                    Write-Host "  ✅ Backend: Running (port 3000)" -ForegroundColor Green
                } catch {
                    Write-Host "  ❌ Backend: Not running" -ForegroundColor Red
                }
                
                # Check frontend
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:5173" -TimeoutSec 2 -ErrorAction SilentlyContinue
                    Write-Host "  ✅ Frontend: Running (port 5173)" -ForegroundColor Green
                } catch {
                    Write-Host "  ❌ Frontend: Not running" -ForegroundColor Red
                }
                
                Write-Host ""
            }
            "6" {
                Write-Host "`nGoodbye!`n" -ForegroundColor Cyan
                exit 0
            }
            default {
                Write-Host "`n❌ Invalid choice`n" -ForegroundColor Red
                exit 1
            }
        }
    }
    
    "add-user" {
        if (-not $Username) {
            $Username = Read-Host "Username"
        }
        if (-not $Password) {
            $passwordSecure = Read-Host "Password" -AsSecureString
            $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordSecure)
            )
        }
        
        $role = Read-Host "Role (admin/user) [default: user]"
        if (-not $role) { $role = "user" }
        
        Add-User -Username $Username -Password $Password -Role $role
    }
    
    "remove-user" {
        if (-not $Username) {
            $Username = Read-Host "Username to remove"
        }
        
        $confirm = Read-Host "Are you sure you want to remove user '$Username'? (Y/N)"
        if ($confirm -eq 'Y') {
            Remove-User -Username $Username
        }
    }
    
    "list-users" {
        $users = Get-Users
        
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "  Registered Users" -ForegroundColor White
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
        
        foreach ($user in $users) {
            Write-Host "  👤 $($user.username)" -ForegroundColor Yellow
            Write-Host "     Role: $($user.role)" -ForegroundColor Gray
            Write-Host "     Created: $($user.createdAt)" -ForegroundColor Gray
            if ($user.lastLogin) {
                Write-Host "     Last Login: $($user.lastLogin)" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        Write-Host "  Total: $($users.Count) users`n" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "`n❌ Invalid action: $Action" -ForegroundColor Red
        Write-Host "`nUsage:" -ForegroundColor Yellow
        Write-Host "  .\auth-gate.ps1 -Action check" -ForegroundColor White
        Write-Host "  .\auth-gate.ps1 -Action add-user" -ForegroundColor White
        Write-Host "  .\auth-gate.ps1 -Action remove-user -Username <user>" -ForegroundColor White
        Write-Host "  .\auth-gate.ps1 -Action list-users`n" -ForegroundColor White
        exit 1
    }
}
