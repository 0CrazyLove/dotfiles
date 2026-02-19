#!/bin/bash
# Optimized Dotfiles Installation Script
# Arch Linux + Hyprland Setup

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Variables ---
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.configbackup/$(date +%Y%m%d_%H%M%S)"
WALLPAPERS_DIR="$HOME/Documents/"
WALLPAPERS_REPO="https://github.com/0CrazyLove/walls"
DOTS_HYPRLAND_DIR="$HOME/dots-hyprland"
WALLPAPER="$HOME/.config/quickshell/ii/assets/images/default_wallpaper.png"

# --- Helper Functions ---
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_info "Starting dotfiles installation..."

# --- Permissions Check ---
check_home_permissions() {
  local home_owner=$(stat -c %U "$HOME")
  local current_user=$(whoami)
  
  if [ "$home_owner" != "$current_user" ]; then
    print_warning "Fixing HOME directory permissions..."
    sudo chown -R "$current_user:$current_user" "$HOME"
    chmod 755 "$HOME"
    print_success "HOME permissions corrected."
  fi
}

check_home_permissions

# --- Environment Sanity Check ---
if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Directory $DOTFILES_DIR not found!"
  print_info "Please clone the repository first."
  exit 1
fi

# Ensure critical tools for THIS script are present (not the whole system)
REQUIRED_TOOLS=("git" "rsync" "makepkg")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        print_error "Critical tool missing: $tool"
        print_info "Please run dependencies.sh first."
        exit 1
    fi
done

# --- Illogical Impulse (Submodules) ---
clone_illogical_impulse() {
  local quickshell_pkg_dir="$DOTS_HYPRLAND_DIR/sdata/dist-arch/illogical-impulse-quickshell-git"
  
  if [ -d "$quickshell_pkg_dir" ]; then
    print_success "dots-hyprland structure already exists."
    return 0
  fi
  
  print_info "Cloning Illogical Impulse (dots-hyprland)..."
  if git clone --recurse-submodules https://github.com/end-4/dots-hyprland.git "$DOTS_HYPRLAND_DIR"; then
    print_success "Illogical Impulse cloned successfully."
    return 0
  else
    print_error "Failed to clone Illogical Impulse."
    return 1
  fi
}

# --- Wallpapers ---
setup_wallpapers() {
  if [ -d "$WALLPAPERS_DIR/Walls" ]; then
    print_info "Wallpapers directory already exists. Skipping clone."
    return 0
  fi
  
  print_info "Wallpapers repository available."
  read -t 30 -p "Clone wallpapers repo? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Skipping wallpapers."
    return 0
  fi
  
  print_info "Cloning wallpapers..."
  mkdir -p "$WALLPAPERS_DIR"
  
  if git clone --depth 1 "$WALLPAPERS_REPO" "/tmp/walls_clone_temp"; then
    mv /tmp/walls_clone_temp/Walls "$WALLPAPERS_DIR/"
    rm -rf /tmp/walls_clone_temp
    print_success "Wallpapers cloned successfully."
  else
    print_error "Failed to clone wallpapers."
  fi
}
# --- Quickshell Compilation ---
install_quickshell() {
  local quickshell_dir="$DOTS_HYPRLAND_DIR/sdata/dist-arch/illogical-impulse-quickshell-git"
  
  # Check if already installed
  if pacman -Qi illogical-impulse-quickshell-git >/dev/null 2>&1; then
    print_success "illogical-impulse-quickshell-git is already installed."
    return 0
  fi

  if [ ! -d "$quickshell_dir" ]; then
    print_warning "Quickshell source not found (dots-hyprland missing?). Skipping."
    return 1
  fi

  # Handle conflicts
  local conflicts=("quickshell" "quickshell-git")
  for pkg in "${conflicts[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
        print_warning "Removing conflicting package: $pkg"
        sudo pacman -Rns --noconfirm "$pkg"
    fi
  done
  
  print_info "Building illogical-impulse-quickshell-git..."
  cd "$quickshell_dir" || return 1
  
  if makepkg -si --noconfirm; then
    print_success "Quickshell installed successfully."
    cd ~
    return 0
  else
    print_error "Failed to build Quickshell."
    cd ~
    return 1
  fi
}

# --- Shapes Submodule Logic ---
init_shapes_submodule() {
  local shapes_source="$DOTS_HYPRLAND_DIR/dots/.config/quickshell/ii/modules/common/widgets/shapes"
  local shapes_target="$HOME/.config/quickshell/ii/modules/common/widgets/shapes"
  
  if [ ! -d "$DOTS_HYPRLAND_DIR" ]; then return 0; fi

  print_info "Initializing submodule shapes..."
  cd "$DOTS_HYPRLAND_DIR" || return 1
  git submodule update --init --recursive 2>/dev/null
  
  if [ -d "$shapes_source" ]; then
    mkdir -p "$(dirname "$shapes_target")"
    cp -r "$shapes_source" "$shapes_target"
    print_success "Shapes module initialized."
  else
    print_warning "Shapes source not found after submodule update."
  fi
  cd ~
}

# --- Generic Config Installer ---
install_item() {
  local source="$1"
  local target="$2"
  local name="$3"

  if [ ! -e "$source" ]; then
    print_warning "Source not found for $name. Skipping."
    return
  fi

  # Create parent directory
  mkdir -p "$(dirname "$target")"

  # Backup if exists
  if [ -e "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    # Move to backup using rsync semantics or mv
    mv "$target" "$BACKUP_DIR/"
    print_info "Backed up existing $name."
  fi

  # Copy new config
  if cp -r "$source" "$target"; then
    print_success "Installed $name."
  else
    print_error "Failed to install $name."
  fi
}

# --- MAIN EXECUTION FLOW ---

# Setup Environment
mkdir -p "$HOME/.config" "$HOME/.local/share"
mkdir -p "$BACKUP_DIR"

#  External Repos
if clone_illogical_impulse; then
    install_quickshell
fi
setup_wallpapers

# Install Configs (Batch Processing)
print_info "Installing configuration files..."

# List of items to install: "Source Path : Target Path : Description"
# We use a custom delimiter ':' to split string
ITEMS=(
  "$DOTFILES_DIR/bin/rm:/usr/local/bin/rm:RM Protection Script"
  "$DOTFILES_DIR/.config/fish:$HOME/.config/fish:Fish Shell"
  "$DOTFILES_DIR/.config/fastfetch:$HOME/.config/fastfetch:Fastfetch"
  "$DOTFILES_DIR/.config/hypr:$HOME/.config/hypr:Hyprland"
  "$DOTFILES_DIR/.config/kitty:$HOME/.config/kitty:Kitty"
  "$DOTFILES_DIR/.config/nvim:$HOME/.config/nvim:Neovim"
  "$DOTFILES_DIR/.config/quickshell:$HOME/.config/quickshell:Quickshell Config"
  "$DOTFILES_DIR/.config/illogical-impulse:$HOME/.config/illogical-impulse:Illogical Impulse"
  "$DOTFILES_DIR/wal:$HOME/.config/wal:Pywal"
  "$DOTFILES_DIR/.config/matugen:$HOME/.config/matugen:Matugen"
  "$DOTFILES_DIR/.config/xdg-desktop-portal:$HOME/.config/xdg-desktop-portal:XDG Portal"
  "$DOTFILES_DIR/.local/share/icons:$HOME/.local/share/icons:Icons"
  "$DOTFILES_DIR/.config/starship.toml:$HOME/.config/starship.toml:Starship"
)

for item in "${ITEMS[@]}"; do
    IFS=':' read -r source target desc <<< "$item"
    
    # Special handling for RM script (needs sudo)
    if [[ "$target" == "/usr/local/bin/rm" ]]; then
        if [ -f "$source" ]; then
            print_info "Installing $desc..."
            sudo cp "$source" "$target"
            sudo chmod +x "$target"
            print_success "$desc installed."
        fi
    else
        install_item "$source" "$target" "$desc"
    fi
done

# Post-Config Logic
if [ -d "$HOME/.config/quickshell" ]; then
    init_shapes_submodule
fi

# Fish Starship Hook
if [ -f "$HOME/.config/fish/config.fish" ] && ! grep -q "starship init fish" "$HOME/.config/fish/config.fish"; then
    echo "starship init fish | source" >> "$HOME/.config/fish/config.fish"
    print_success "Added starship init to fish config."
fi

# Apply Pywal + Color Scheme
if [ -f "$WALLPAPER" ]; then
    command -v wal >/dev/null 2>&1 && wal -i "$WALLPAPER" -q
    command -v kitty >/dev/null 2>&1 && killall -SIGUSR1 kitty
    command -v matugen >/dev/null 2>&1 && matugen image "$WALLPAPER" --mode dark
    if [ -f ~/.cache/wal/colors-kde.conf ]; then
        cp ~/.cache/wal/colors-kde.conf ~/.config/kdeglobals
        command -v qdbus >/dev/null 2>&1 && qdbus org.kde.KWin /KWin reconfigure
    fi
fi

echo
print_success "Installation completed successfully! OWO"
print_info "Backup stored at: $BACKUP_DIR"
print_warning "If something looks wrong, check the missing packages with dependencies.sh"
print_info "Please reboot your system."