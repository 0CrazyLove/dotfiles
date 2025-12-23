#!/bin/bash
# Dotfiles installation script
# Arch Linux + Hyprland Setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.configbackup$(date +%Y%m%d_%H%M%S)"
WALLPAPERS_DIR="$HOME/Documents/walls"
DOTS_HYPRLAND_DIR="$HOME/dots-hyprland"

print_info "Starting dotfiles installation..."

check_home_permissions() {
  local home_owner=$(stat -c %U "$HOME")
  local current_user=$(whoami)
  
  if [ "$home_owner" != "$current_user" ]; then
    print_error "HOME directory has incorrect permissions"
    print_info "Fixing HOME directory permissions..."
    sudo chown -R "$current_user:$current_user" "$HOME"
    chmod 755 "$HOME"
    chmod -R u+w "$HOME"
    print_success "✓ HOME directory permissions corrected"
  fi
}

check_home_permissions

if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Directory $DOTFILES_DIR not found!"
  print_info "Clone the repository first:"
  echo "git clone https://github.com/0CrazyLove/dotfiles.git $DOTFILES_DIR"
  exit 1
fi

# Function to clone dots-hyprland (Illogical Impulse)
clone_illogical_impulse() {
  local quickshell_pkg_dir="$DOTS_HYPRLAND_DIR/sdata/dist-arch/illogical-impulse-quickshell-git"
  
  # If it already exists with correct structure, do nothing
  if [ -d "$quickshell_pkg_dir" ]; then
    print_success "✓ dots-hyprland already exists with correct structure"
    return 0
  fi
  
  # If it doesn't exist, clone it
  print_info "Cloning Illogical Impulse repository (dots-hyprland)..."
  if git clone --recurse-submodules https://github.com/end-4/dots-hyprland.git "$DOTS_HYPRLAND_DIR"; then
    print_success "✓ Illogical Impulse repository cloned"
    return 0
  else
    print_error "✗ Error cloning Illogical Impulse repository"
    return 1
  fi
}

# Function to install Illogical Impulse Quickshell
install_illogical_impulse_quickshell() {
  local quickshell_dir="$DOTS_HYPRLAND_DIR/sdata/dist-arch/illogical-impulse-quickshell-git"
  
  if [ ! -d "$quickshell_dir" ]; then
    print_error "✗ Directory $quickshell_dir not found"
    return 1
  fi
  
  # Check if illogical-impulse-quickshell-git is already installed
  print_info "Checking if illogical-impulse-quickshell-git is installed..."
  if pacman -Qi illogical-impulse-quickshell-git >/dev/null 2>&1; then
    print_success "✓ illogical-impulse-quickshell-git is already installed"
    return 0
  fi
  
  # Check if another version of quickshell is installed
  local has_quickshell=false
  local packages_to_remove=()
  
  print_info "Checking for other quickshell versions..."
  if pacman -Qi quickshell >/dev/null 2>&1; then
    packages_to_remove+=("quickshell")
    has_quickshell=true
  fi
  
  if pacman -Qi quickshell-git >/dev/null 2>&1; then
    packages_to_remove+=("quickshell-git")
    has_quickshell=true
  fi
  
  # Only attempt to remove if packages are installed
  if [ "$has_quickshell" = true ]; then
    print_warning "⚠ Different version of quickshell detected: ${packages_to_remove[*]}"
    print_info "Removing previous versions..."
    sudo pacman -Rns --noconfirm "${packages_to_remove[@]}"
    if [ $? -eq 0 ]; then
      print_success "✓ Previous quickshell version(s) removed"
    else
      print_error "✗ Error removing previous quickshell version"
      return 1
    fi
  else
    print_info "No previous quickshell versions found"
  fi
  
  print_info "Building and installing illogical-impulse-quickshell-git..."
  cd "$quickshell_dir" || {
    print_error "✗ Could not access $quickshell_dir"
    return 1
  }
  
  makepkg -si --noconfirm
  if [ $? -eq 0 ]; then
    print_success "✓ illogical-impulse-quickshell-git installed successfully"
    cd "$HOME" || cd ~
    return 0
  else
    print_error "✗ Error building/installing illogical-impulse-quickshell-git"
    cd "$HOME" || cd ~
    return 1
  fi
}

# Function to initialize shapes submodule in quickshell config
init_shapes_submodule() {
  local dots_hyprland_dir="$DOTS_HYPRLAND_DIR"
  local shapes_source="$dots_hyprland_dir/dots/.config/quickshell/ii/modules/common/widgets/shapes"
  local shapes_target="$HOME/.config/quickshell/ii/modules/common/widgets/shapes"
  
  # Verify that dots-hyprland exists
  if [ ! -d "$dots_hyprland_dir" ]; then
    print_warning "⚠ dots-hyprland directory not found, skipping shapes initialization"
    return 0
  fi
  
  print_info "Initializing dots-hyprland submodules..."
  cd "$dots_hyprland_dir" || {
    print_error "✗ Could not access $dots_hyprland_dir"
    return 1
  }
  
  # Initialize submodules
  if git submodule update --init --recursive 2>/dev/null; then
    print_success "✓ dots-hyprland submodules initialized"
  else
    print_warning "⚠ Could not initialize submodules"
    cd "$HOME" || cd ~
    return 1
  fi
  
  # Verify that shapes exists after initializing submodules
  if [ ! -d "$shapes_source" ]; then
    print_error "✗ shapes directory not found at $shapes_source"
    cd "$HOME" || cd ~
    return 1
  fi
  
  # Create target directory if it doesn't exist
  mkdir -p "$(dirname "$shapes_target")"
  
  # Copy shapes
  print_info "Copying shapes module to quickshell config..."
  if cp -r "$shapes_source" "$shapes_target"; then
    print_success "✓ shapes module copied successfully"
  else
    print_error "✗ Error copying shapes module"
    cd "$HOME" || cd ~
    return 1
  fi
  
  cd "$HOME" || cd ~
  return 0
}

# List of required dependencies 
DEPENDENCIES=(
  "nano"
  "fish"               
  "hyprland"             
  "kitty"               
  "neovim"                         
  "qt5-tools"         
  "starship"             
  "dolphin"              
  "eza"                 
  "python-pywal"         
  "cliphist"            
  "ddcutil"           
  "python-pillow"      
  "fuzzel"              
  "glib2"                
  "hypridle"           
  "hyprutils"       
  "hyprlock"           
  "hyprpicker"        
  "nm-connection-editor"
  "geoclue"
  "brightnessctl"
  "axel"
  "bc"
  "coreutils"
  "cmake"
  "curl"
  "rsync"
  "wget"
  "ripgrep"
  "jq"
  "meson"
  "xdg-user-dirs"
  "fontconfig"
  "breeze"
  "tinyxml2"
  "gtkmm3"
  "cairomm"
  "gtk4"
  "libadwaita"
  "libsoup3"
  "gobject-introspection"
  "sassc"
  "python-opencv"
  "tesseract"
  "tesseract-data-eng"
  "wf-recorder"
  "kdialog"
  "less" 
  "qt6-base"
  "qt6-declarative"
  "qt6-imageformats"
  "qt6-multimedia"
  "qt6-positioning"
  "qt6-quicktimeline"
  "qt6-sensors"
  "qt6-svg"
  "qt6-tools"
  "qt6-translations"
  "qt6-wayland"
  "upower"
  "qt6-5compat"
  "syntax-highlighting"
  "fastfetch"
  "songrec"
  "python-colorthief"
  "hyprsunset"
)

HYPRLAND_DEPS=(
  "swww"  
  "grim"  
  "slurp"  
)

AUR_DEPENDENCIES=(
  "neofetch"               
  "translate-shell"        
  "python-materialyoucolor" 
  "wlogout"               
  "adw-gtk-theme-git"
  "breeze-plus"
  "darkly-bin"
  "matugen-bin"
  "otf-space-grotesk"
  "ttf-gabarito-git"
  "ttf-jetbrains-mono-nerd"
  "ttf-material-symbols-variable-git"
  "ttf-readex-pro"
  "ttf-rubik-vf"
  "ttf-twemoji"
  "hyprcursor"
  "hyprland-qt-support"
  "hyprlang"
  "hyprsunset"
  "hyprwayland-scanner"
  "xdg-desktop-portal-hyprland"
  "wl-clipboard"
  "bluedevil"
  "gnome-keyring"
  "networkmanager"
  "plasma-nm"
  "polkit-kde-agent"
  "systemsettings"
  "uv"
  "hyprshot"
  "swappy"
  "wtype"
  "ydotool"
  "google-breakpad"          
  "qt6-avif-image-plugin"
)

OPTIONAL_DEPS=(
  "visual-studio-code-bin"
  "discord"
  "brave-bin"
)

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

print_info "Checking main dependencies..."
missing_deps=()
missing_hyprland=()
missing_aur=()
missing_optional=()

for dep in "${DEPENDENCIES[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_deps+=("$dep")
    print_error "✗ $dep not found"
  else
    print_success "✓ $dep found"
  fi
done

print_info "Checking Hyprland dependencies..."
for dep in "${HYPRLAND_DEPS[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_hyprland+=("$dep")
    print_error "✗ $dep not found"
  else
    print_success "✓ $dep found"
  fi
done

print_info "Checking AUR dependencies..."
for dep in "${AUR_DEPENDENCIES[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_aur+=("$dep")
    print_error "✗ $dep not found"
  else
    print_success "✓ $dep found"
  fi
done

for dep in "${OPTIONAL_DEPS[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_optional+=("$dep")
    print_warning "⚠ $dep not found (optional)"
  else
    print_success "✓ $dep found"
  fi
done

total_missing=$((${#missing_deps[@]} + ${#missing_hyprland[@]} + ${#missing_aur[@]}))

if [ $total_missing -ne 0 ]; then
  print_error "Required dependencies are missing!"
  echo
  
  if [ ${#missing_deps[@]} -ne 0 ]; then
    print_info "Missing main dependencies:"
    echo "sudo pacman -S ${missing_deps[*]}"
    echo
  fi
  
  if [ ${#missing_hyprland[@]} -ne 0 ]; then
    print_info "Missing Hyprland dependencies:"
    echo "sudo pacman -S ${missing_hyprland[*]}"
    echo
  fi
  
  if [ ${#missing_aur[@]} -ne 0 ]; then
    print_info "Missing AUR dependencies:"
    echo "yay -S ${missing_aur[*]}"
    echo
  fi
  
  print_info "Or run the dependencies script first:"
  echo "./dependencies.sh"
  echo
  
  read -p "Continue without missing dependencies? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installation cancelled. Install dependencies first."
    exit 1
  fi
fi

print_info "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# NEW: Clone dots-hyprland for Illogical Impulse
if ! clone_illogical_impulse; then
  print_error "Error cloning dots-hyprland"
  read -p "Continue without Illogical Impulse? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# NEW: Install Illogical Impulse Quickshell
if [ -d "$DOTS_HYPRLAND_DIR" ]; then
  if ! install_illogical_impulse_quickshell; then
    print_error "Error installing illogical-impulse-quickshell-git"
    read -p "Continue without Illogical Impulse quickshell? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
else
  print_warning "⚠ Skipping quickshell installation (dots-hyprland not available)"
fi

configure_wifi_module() {
  print_info "Configuring automatic WiFi module loading..."
  
  if [ -f "/etc/modules-load.d/wifi.conf" ]; then
    print_warning "File /etc/modules-load.d/wifi.conf already exists"
    if grep -q "rtl8xxxu" /etc/modules-load.d/wifi.conf; then
      print_success "✓ rtl8xxxu module already configured"
      return
    fi
  fi
  
  if echo "rtl8xxxu" | sudo tee /etc/modules-load.d/wifi.conf >/dev/null 2>&1; then
    print_success "✓ WiFi module configured for automatic loading"
    
    if sudo modprobe rtl8xxxu >/dev/null 2>&1; then
      print_success "✓ WiFi module loaded successfully"
    else
      print_warning "⚠ Could not load module immediately (will load on next reboot)"
    fi
  else
    print_error "✗ Error configuring WiFi module"
    print_warning "You can run manually: echo 'rtl8xxxu' | sudo tee /etc/modules-load.d/wifi.conf"
  fi
}

install_rm_script() {
  print_info "Installing rm protection script..."
  
  if [ ! -f "$DOTFILES_DIR/bin/rm" ]; then
    print_warning "⚠ rm script not found at $DOTFILES_DIR/bin/rm, skipping"
    return
  fi
  
  if [ -f "/usr/local/bin/rm" ]; then
    print_warning "Backing up existing rm"
    sudo cp /usr/local/bin/rm "$BACKUP_DIR/rm.backup"
  fi
  
  if sudo cp "$DOTFILES_DIR/bin/rm" "/usr/local/bin/rm"; then
    sudo chmod +x "/usr/local/bin/rm"
    print_success "✓ rm protection script installed at /usr/local/bin/rm"
  else
    print_error "✗ Error installing rm protection script"
    return 1
  fi
}

install_config() {
  local source="$1"
  local target="$2"
  local name="$3"
  
  print_info "Installing $name configuration..."
  
  if [ ! -d "$source" ]; then
    print_warning "⚠ $source not found, skipping $name"
    return
  fi
  
  mkdir -p "$(dirname "$target")"
  
  if [ -e "$target" ]; then
    print_warning "Backing up existing $target"
    mv "$target" "$BACKUP_DIR/"
  fi
  
  if cp -r "$source" "$target"; then
    print_success "✓ $name configured"
  else
    print_error "✗ Error copying $name"
    return 1
  fi
}

install_file() {
  local source="$1"
  local target="$2"
  local name="$3"
  
  print_info "Installing $name..."
  
  if [ ! -f "$source" ]; then
    print_warning "⚠ $source not found, skipping $name"
    return
  fi
  
  mkdir -p "$(dirname "$target")"
  
  if [ -f "$target" ]; then
    print_warning "Backing up existing $target"
    mv "$target" "$BACKUP_DIR/"
  fi
  
  if cp "$source" "$target"; then
    print_success "✓ $name configured"
  else
    print_error "✗ Error copying $name"
    return 1
  fi
}

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share" 

print_info "Installing configurations..."

install_rm_script
install_config "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish" "Fish shell"
install_config "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
install_config "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr" "Hyprland"
install_config "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty" "Kitty terminal"
install_config "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch" "Neofetch"
install_config "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim"
install_config "$DOTFILES_DIR/.config/quickshell" "$HOME/.config/quickshell" "Quickshell"
install_config "$DOTFILES_DIR/.config/illogical-impulse" "$HOME/.config/illogical-impulse" "Illogical Impulse (Quickshell design)"
install_config "$DOTFILES_DIR/wal" "$HOME/.config/wal" "Wal (Color schemes)"
install_config "$DOTFILES_DIR/.config/matugen" "$HOME/.config/matugen" "Matugen"
install_config "$DOTFILES_DIR/.config/xdg-desktop-portal" "$HOME/.config/xdg-desktop-portal" "XDG Desktop Portal (KDE)"
install_config "$DOTFILES_DIR/.local/share/icons" "$HOME/.local/share/icons" "Custom icons"
install_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship"

# NEW: Initialize shapes submodule after copying quickshell config
if [ -d "$HOME/.config/quickshell" ]; then
  init_shapes_submodule
fi

configure_wifi_module

if [ -d "$DOTFILES_DIR/walls" ]; then
  print_info "Installing wallpapers..."
  mkdir -p "$(dirname "$WALLPAPERS_DIR")"
  
  if [ -d "$WALLPAPERS_DIR" ]; then
    print_warning "Backing up existing wallpapers"
    mv "$WALLPAPERS_DIR" "$BACKUP_DIR/"
  fi
  
  if cp -r "$DOTFILES_DIR/walls" "$WALLPAPERS_DIR"; then
    print_success "✓ Wallpapers installed at $WALLPAPERS_DIR"
  else
    print_warning "⚠ Error copying wallpapers"
  fi
else
  print_warning "walls folder not found at $DOTFILES_DIR"
fi

if command_exists fish; then
  print_info "Configuring Fish shell..."
  
  if command_exists starship && [ -f "$HOME/.config/fish/config.fish" ]; then
    if ! grep -q "starship init fish" "$HOME/.config/fish/config.fish"; then
      echo "starship init fish | source" >>"$HOME/.config/fish/config.fish"
      print_success "✓ Starship added to Fish config"
    fi
  fi
fi

print_success "Installation completed!"
print_info "Backup saved at: $BACKUP_DIR"
echo

print_info "Verifying installation..."
configs_ok=true

check_config() {
  local config_path="$1"
  local name="$2"
  
  if [ -e "$config_path" ]; then
    print_success "✓ $name configured"
  else
    print_error "✗ $name not found"
    configs_ok=false
  fi
}

check_config "$HOME/.config/fish" "Fish"
check_config "$HOME/.config/fastfetch" "Fastfetch"
check_config "$HOME/.config/hypr" "Hyprland"
check_config "$HOME/.config/kitty" "Kitty"
check_config "$HOME/.config/neofetch" "Neofetch"
check_config "$HOME/.config/nvim" "Neovim"
check_config "$HOME/.config/quickshell" "Quickshell"
check_config "$HOME/.config/illogical-impulse" "Illogical Impulse"
check_config "$HOME/.config/starship.toml" "Starship"
check_config "$HOME/.config/wal" "Wal"
check_config "$HOME/.config/xdg-desktop-portal" "XDG Desktop Portal"
check_config "$HOME/.config/matugen" "Matugen"
check_config "$HOME/.local/share/icons" "Custom icons"
check_config "/usr/local/bin/rm" "rm protection script"

# Verify quickshell installation
if pacman -Qi illogical-impulse-quickshell-git >/dev/null 2>&1; then
  print_success "✓ illogical-impulse-quickshell-git installed"
else
  print_warning "⚠ illogical-impulse-quickshell-git not installed"
  configs_ok=false
fi

echo

if $configs_ok; then
  print_success "All configurations are in place OWO"
else
  print_warning "⚠ Some configurations may have issues"
fi

echo
print_info "Configurations installed as independent files."
print_info "You can delete the ~/dotfiles directory if you want."
print_info "The ~/dots-hyprland directory contains Illogical Impulse files."
echo
print_warning "To update in the future, use: ./update.sh from ~/dotfiles"