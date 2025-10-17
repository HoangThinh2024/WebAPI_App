#!/bin/bash

# Clean Script for Unix/Linux/macOS
# Xóa các tệp build, cache và dependencies
# Sử dụng: bash scripts/clean.sh

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}🧹 Clean Script - Xóa tệp build và cache${NC}\n"

# Xác định thư mục gốc
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}📂 Project root: $ROOT_DIR${NC}\n"

# Danh sách các thư mục/file cần xóa
declare -a targets=(
    "web_vue/node_modules:Frontend dependencies"
    "node_backend/node_modules:Backend dependencies"
    "node_modules:Root dependencies"
    "web_vue/dist:Frontend build output"
    "node_backend/dist:Backend build output"
    "dist:Root build output"
    "web_vue/.vite:Vite cache"
    ".vite:Root Vite cache"
    "web_vue/.eslintcache:Frontend ESLint cache"
    "node_backend/.eslintcache:Backend ESLint cache"
    ".eslintcache:Root ESLint cache"
    ".DS_Store:macOS metadata"
    "Thumbs.db:Windows thumbnail cache"
)

deleted_count=0
total_freed=0

echo -e "${YELLOW}🔍 Scanning for files to delete...${NC}\n"

for target in "${targets[@]}"; do
    IFS=':' read -r path desc <<< "$target"
    full_path="$ROOT_DIR/$path"
    
    if [ -e "$full_path" ]; then
        # Tính size
        if [ -d "$full_path" ]; then
            size=$(du -sb "$full_path" 2>/dev/null | cut -f1)
        else
            size=$(stat -f%z "$full_path" 2>/dev/null || stat -c%s "$full_path" 2>/dev/null || echo 0)
        fi
        
        size_mb=$(echo "scale=2; $size/1024/1024" | bc)
        echo -e "${YELLOW}  🗑️  Deleting: $desc (${size_mb} MB)...${NC}"
        
        if rm -rf "$full_path" 2>/dev/null; then
            total_freed=$((total_freed + size))
            deleted_count=$((deleted_count + 1))
            echo -e "${GREEN}  ✓ Deleted: $path${NC}"
        else
            echo -e "${RED}  ✗ Error deleting: $path${NC}"
        fi
    else
        echo -e "  ⊘ Not found: $path"
    fi
done

# Xóa log files
find "$ROOT_DIR" -name "*.log" -type f 2>/dev/null | while read -r log_file; do
    size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo 0)
    if rm -f "$log_file" 2>/dev/null; then
        total_freed=$((total_freed + size))
        deleted_count=$((deleted_count + 1))
        echo -e "${GREEN}  ✓ Deleted log: $(basename "$log_file")${NC}"
    fi
done

total_freed_mb=$(echo "scale=2; $total_freed/1024/1024" | bc)

echo -e "\n${CYAN}============================================================${NC}"
echo -e "${NC}🎉 Clean completed!${NC}"
echo -e "${GREEN}📊 Files/Folders deleted: $deleted_count${NC}"
echo -e "${GREEN}💾 Disk space freed: ${total_freed_mb} MB${NC}"
echo -e "${CYAN}============================================================${NC}\n"

if [ "$total_freed" -gt 0 ]; then
    echo -e "${BLUE}💡 Tip: Run 'pnpm install' to reinstall dependencies${NC}\n"
fi
