#!/bin/bash
# Script to update dotfiles repository with local configurations
# Optimized with rsync and git skip-worktree for a clean status

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Printing ---
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="$HOME/dotfiles"

# --- Exclusion List ---
EXCLUDES=(
    "config.fish"
    "fish/fish_variables"
    "fish/functions/"
    "hypr/hyprland/colors.conf"
    "hypr/hyprland/general.conf"
    "hypr/hyprlock.conf"
    "hypr/hyprlock/colors.conf"
    "custom/env.conf.save"
    "quickshell/ii/services/MaterialThemeLoader.qml"
    "quickshell/ii/translations/en_US.json"
    "ii/defaults/ai/prompts/"
    ".git/"
)

# Build rsync excludes
RSYNC_EXCLUDES=""
for item in "${EXCLUDES[@]}"; do
    RSYNC_EXCLUDES+=" --exclude=$item"
done

# --- Git Ignore Logic ---
apply_git_ignore() {
    for item in "${EXCLUDES[@]}"; do
        # We only apply this to files that exist in the repo
        local repo_path=".config/$item"
        if [ -f "$repo_path" ]; then
            git update-index --skip-worktree "$repo_path" 2>/dev/null
        fi
    done
}

# Check if the dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Directory $DOTFILES_DIR not found!"
    exit 1
fi

cd "$DOTFILES_DIR" || exit
print_info "Syncing local configs..."

# Aplicar el truco de Git antes de empezar
apply_git_ignore

# --- Update Function ---
update_config() {
    local config_name="$1"
    local source_path="$HOME/.config/$config_name/"
    local dest_path=".config/$config_name"
    
    if [ -d "$source_path" ]; then
        mkdir -p "$dest_path"
        # Added -q for quiet and --ignore-errors
        rsync -aq --delete $RSYNC_EXCLUDES "$source_path" "$dest_path/"
        print_success "✓ $config_name updated"
    else
        print_warning "⚠ $config_name not found"
    fi
}

# --- Update Quickshell ---
update_quickshell() {
    local source_path="$HOME/.config/quickshell/"
    local dest_path=".config/quickshell"
    local shapes_dir="ii/modules/common/widgets/shapes"
    
    if [ ! -d "$source_path" ]; then return; fi
    
    mkdir -p "$dest_path"
    rsync -aq --delete $RSYNC_EXCLUDES "$source_path" "$dest_path/"
    
    if [ -d "$dest_path/$shapes_dir" ]; then
        rm -rf "$dest_path/$shapes_dir"/{*,.[!.]*,..?*} 2>/dev/null || true
    fi
    print_success "✓ quickshell updated"
}

# --- Update File ---
update_file() {
    local file_name="$1"
    local source_path="$HOME/.config/$file_name"
    local dest_path=".config/$file_name"
    
    if [ -f "$source_path" ]; then
        mkdir -p "$(dirname "$dest_path")"
        cp "$source_path" "$dest_path"
        print_success "✓ $file_name updated"
    fi
}

# --- SYNC PROCESS ---
DIRECTORIES=("fish" "fastfetch" "hypr" "kitty" "matugen")
for dir in "${DIRECTORIES[@]}"; do
    update_config "$dir"
done

update_quickshell
update_file "starship.toml"

# --- GIT SECTION ---
echo
echo -e "${BLUE}=== GIT STATUS ===${NC}"
# Limpiar archivos no deseados que rsync no pudo evitar (archivos nuevos)
for item in "${EXCLUDES[@]}"; do
    git checkout -- ".config/$item" 2>/dev/null
done

git status --short
echo

read -p "Do you want to commit? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add .
    for item in "${EXCLUDES[@]}"; do
        git reset HEAD ".config/$item" 2>/dev/null
    done

    print_info "Enter commit message:"
    read -e commit_msg
    [ -z "$commit_msg" ] && commit_msg="Update dotfiles - $(date +'%Y-%m-%d')"
    
    git commit -m "$commit_msg"
    print_success "Committed!"
    
    read -p "Push? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && git push && print_success "Pushed to GitHub!"
else
    print_info "No changes committed."
fi