#!/usr/bin/env node

/**
 * Clean Script - Xóa các tệp build, cache và dependencies
 * Sử dụng: node scripts/clean.js
 * hoặc: pnpm clean (từ web_vue hoặc node_backend)
 */

const fs = require('fs');
const path = require('path');

// Màu sắc cho console
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function deleteRecursive(filePath) {
  if (!fs.existsSync(filePath)) {
    return false;
  }

  try {
    if (fs.lstatSync(filePath).isDirectory()) {
      // Use built-in recursive option for better reliability
      fs.rmSync(filePath, { recursive: true, force: true, maxRetries: 3 });
    } else {
      fs.unlinkSync(filePath);
    }
    return true;
  } catch (error) {
    // Retry with alternative method on Windows
    try {
      if (fs.lstatSync(filePath).isDirectory()) {
        const files = fs.readdirSync(filePath);
        files.forEach((file) => {
          const curPath = path.join(filePath, file);
          if (fs.lstatSync(curPath).isDirectory()) {
            deleteRecursive(curPath);
          } else {
            fs.unlinkSync(curPath);
          }
        });
        fs.rmdirSync(filePath);
      } else {
        fs.unlinkSync(filePath);
      }
      return true;
    } catch (retryError) {
      log(`  ✗ Error: ${retryError.message}`, 'red');
      return false;
    }
  }
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
}

function getDirectorySize(dirPath) {
  if (!fs.existsSync(dirPath)) return 0;
  
  let totalSize = 0;
  
  function calculateSize(filePath) {
    const stats = fs.lstatSync(filePath);
    
    if (stats.isDirectory()) {
      fs.readdirSync(filePath).forEach((file) => {
        calculateSize(path.join(filePath, file));
      });
    } else {
      totalSize += stats.size;
    }
  }
  
  calculateSize(dirPath);
  return totalSize;
}

// Xác định thư mục gốc (từ script location hoặc current directory)
const currentDir = process.cwd();
const scriptDir = __dirname;
const rootDir = path.resolve(scriptDir, '..');

log('\n🧹 Clean Script - Xóa tệp build và cache\n', 'cyan');
log(`📂 Current directory: ${currentDir}`, 'blue');
log(`📂 Project root: ${rootDir}\n`, 'blue');

// Danh sách các thư mục/file cần xóa
const targets = [
  // Node.js dependencies
  { path: 'web_vue/node_modules', desc: 'Frontend dependencies' },
  { path: 'node_backend/node_modules', desc: 'Backend dependencies' },
  { path: 'node_modules', desc: 'Root dependencies' },
  
  // Build outputs
  { path: 'web_vue/dist', desc: 'Frontend build output' },
  { path: 'node_backend/dist', desc: 'Backend build output' },
  { path: 'dist', desc: 'Root build output' },
  
  // Vite cache
  { path: 'web_vue/.vite', desc: 'Vite cache' },
  { path: '.vite', desc: 'Root Vite cache' },
  
  // ESLint cache
  { path: 'web_vue/.eslintcache', desc: 'Frontend ESLint cache' },
  { path: 'node_backend/.eslintcache', desc: 'Backend ESLint cache' },
  { path: '.eslintcache', desc: 'Root ESLint cache' },
  
  // Logs
  { path: 'web_vue/npm-debug.log*', desc: 'Frontend npm logs', isGlob: true },
  { path: 'node_backend/npm-debug.log*', desc: 'Backend npm logs', isGlob: true },
  { path: '*.log', desc: 'Root log files', isGlob: true },
  
  // OS specific
  { path: '.DS_Store', desc: 'macOS metadata' },
  { path: 'Thumbs.db', desc: 'Windows thumbnail cache' }
];

let totalFreed = 0;
let deletedCount = 0;

log('🔍 Scanning for files to delete...\n', 'yellow');

targets.forEach(({ path: targetPath, desc, isGlob }) => {
  const fullPath = path.resolve(rootDir, targetPath);
  
  if (isGlob) {
    // Handle glob patterns (simple *.log matching)
    const dir = path.dirname(fullPath);
    const pattern = path.basename(fullPath);
    
    if (!fs.existsSync(dir)) return;
    
    const files = fs.readdirSync(dir).filter(file => {
      if (pattern.includes('*')) {
        const regex = new RegExp('^' + pattern.replace('*', '.*') + '$');
        return regex.test(file);
      }
      return file === pattern;
    });
    
    files.forEach(file => {
      const filePath = path.join(dir, file);
      if (fs.existsSync(filePath)) {
        const size = fs.lstatSync(filePath).size;
        if (deleteRecursive(filePath)) {
          totalFreed += size;
          deletedCount++;
          log(`  ✓ Deleted: ${file} (${formatBytes(size)})`, 'green');
        }
      }
    });
  } else {
    // Handle regular paths
    if (fs.existsSync(fullPath)) {
      const size = getDirectorySize(fullPath);
      log(`  🗑️  Deleting: ${desc} (${formatBytes(size)})...`, 'yellow');
      
      if (deleteRecursive(fullPath)) {
        totalFreed += size;
        deletedCount++;
        log(`  ✓ Deleted: ${targetPath}`, 'green');
      }
    } else {
      log(`  ⊘ Not found: ${targetPath}`, 'reset');
    }
  }
});

log('\n' + '='.repeat(60), 'cyan');
log(`🎉 Clean completed!`, 'bright');
log(`📊 Files/Folders deleted: ${deletedCount}`, 'green');
log(`💾 Disk space freed: ${formatBytes(totalFreed)}`, 'green');
log('='.repeat(60) + '\n', 'cyan');

if (totalFreed > 0) {
  log('💡 Tip: Run "pnpm install" to reinstall dependencies\n', 'blue');
}
