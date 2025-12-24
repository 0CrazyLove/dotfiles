#!/bin/bash
# Optimized Script for Arch Linux + Hyprland
# Setup: Dependencies and Configuration

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Printing Functions ---
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Initial Checks ---
# Verify we are running on Arch Linux
if ! command -v pacman >/dev/null 2>&1; then
    print_error "This script is designed for Arch Linux only."
    exit 1
fi

print_info "Starting dependency installation..."

# --- Fix HOME Permissions ---
# Ensures the user owns their own home folder (fixes common issues with sudo usage)
check_home_permissions() {
    local home_owner=$(stat -c %U "$HOME")
    local current_user=$(whoami)
    if [ "$home_owner" != "$current_user" ]; then
        print_warning "HOME directory permissions incorrect. Fixing..."
        sudo chown -R "$current_user:$current_user" "$HOME"
        chmod 755 "$HOME"
        print_success "Permissions fixed."
    fi
}

# --- Manage PGP Keys ---
# Fixes common 'signature is unknown trust' errors
fix_pgp_keys() {
    print_info "Verifying keyring status..."
    
    # If trustdb is missing or Arch keys are not listed, initialize
    if [ ! -f /etc/pacman.d/gnupg/trustdb.gpg ] || ! sudo pacman-key --list-keys "Arch Linux" >/dev/null 2>&1; then
        print_warning "Initializing pacman keyring..."
        sudo pacman-key --init
        sudo pacman-key --populate archlinux
        sudo pacman-key --refresh-keys
    fi

    # Quick update test to see if keys work
    if ! timeout 10 sudo pacman -Sy >/dev/null 2>&1; then
        print_warning "Signature issues detected. Reinstalling keyrings..."
        sudo pacman -S --noconfirm archlinux-keyring
        sudo pacman-key --init
        sudo pacman-key --populate archlinux
    else
        print_success "Keyring verified successfully."
    fi
}

# --- Install Yay (AUR Helper) ---
# Installs 'yay' only if it's not present
install_yay() {
    if ! command -v yay >/dev/null 2>&1; then
        print_info "Installing yay (AUR Helper)..."
        # Install base build dependencies first
        sudo pacman -S --needed --noconfirm git base-devel
        
        cd /tmp || exit
        rm -rf yay
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si --noconfirm
        cd ~ || exit
        print_success "yay installed successfully."
    else
        print_success "yay is already installed."
    fi
}

# --- PACKAGE LISTS ---
# Consolidated list for batch installation 
OFFICIAL_PACKAGES=(
  "base-devel" "fish" "starship" "hyprland" "kitty" "neovim" "qt5-tools" 
  "dolphin" "eza" "python-pywal" "cliphist" "ddcutil" "python-pillow" 
  "fuzzel" "glib2" "hypridle" "hyprutils" "hyprlock" "hyprpicker" 
  "nm-connection-editor" "swww" "grim" "slurp" "geoclue" "nano" 
  "brightnessctl" "axel" "bc" "coreutils" "cmake" "curl" "rsync" "wget" 
  "ripgrep" "jq" "meson" "xdg-user-dirs" "fontconfig" "breeze" "tinyxml2" 
  "gtkmm3" "cairomm" "gtk4" "libadwaita" "libsoup3" "gobject-introspection" 
  "sassc" "python-opencv" "tesseract" "tesseract-data-eng" "wf-recorder" 
  "kdialog" "less" "qt6-base" "qt6-declarative" "qt6-imageformats" 
  "qt6-multimedia" "qt6-positioning" "qt6-quicktimeline" "qt6-sensors" 
  "qt6-svg" "qt6-tools" "qt6-translations" "qt6-wayland" "upower" 
  "qt6-5compat" "syntax-highlighting" "imagemagick" "python-pip" "go" 
  "cava" "gnome-system-monitor" "pavucontrol-qt" "fastfetch" "songrec" 
  "python-colorthief" "hyprsunset"
)

AUR_PACKAGES=(
  "translate-shell" "python-materialyoucolor" "wlogout" "adw-gtk-theme-git"
  "breeze-plus" "darkly-bin" "matugen-bin" "otf-space-grotesk" 
  "ttf-gabarito-git" "ttf-jetbrains-mono-nerd" "ttf-material-symbols-variable-git"
  "ttf-readex-pro" "ttf-rubik-vf" "ttf-twemoji" "hyprcursor" 
  "hyprland-qt-support" "hyprlang" "hyprsunset" "hyprwayland-scanner" 
  "xdg-desktop-portal-hyprland" "wl-clipboard" "bluedevil" "gnome-keyring" 
  "networkmanager" "plasma-nm" "polkit-kde-agent" "systemsettings" "uv" 
  "hyprshot" "swappy" "wtype" "ydotool" "google-breakpad" "qt6-avif-image-plugin"
)

OPTIONAL_PACKAGES=(
  "visual-studio-code-bin" "discord" "brave-bin"
)

# --- MAIN EXECUTION ---

check_home_permissions
fix_pgp_keys

print_info "Updating system..."
sudo pacman -Syu --noconfirm

# Install Official Packages 
print_info "Installing official packages (pacman)..."
if sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"; then
    print_success "Official packages installed."
else
    print_error "There was an error installing some official packages."
    print_warning "Attempting to continue..."
fi

# Install AUR Packages
install_yay
print_info "Installing AUR packages..."
# Yay also supports batch installation
if yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"; then
    print_success "AUR packages installed."
else
    print_warning "Some AUR packages failed. You can retry manually with:"
    echo "yay -S ${AUR_PACKAGES[*]}"
fi

# Optional Packages
print_info "Optional packages available: ${OPTIONAL_PACKAGES[*]}"
read -t 30 -p "Install optional packages? (y/N) [timeout 30s]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    yay -S --needed --noconfirm "${OPTIONAL_PACKAGES[@]}"
fi

# --- Post-Installation Configuration ---

print_info "Configuring color tools (wal)..."
if command -v wal >/dev/null 2>&1; then
    mkdir -p "$HOME/.cache/wal"
    print_success "Wal cache directory created."
else
    print_error "pywal was not installed correctly."
fi

# --- Final Verification ---
print_info "Performing final verification..."
MISSING_PACKAGES=()

# Quick check function using pacman database
check_installed() {
    if ! pacman -Qi "$1" >/dev/null 2>&1; then
        MISSING_PACKAGES+=("$1")
    fi
}

# We check a critical sample to ensure the system is usable
CRITICAL_CHECK=("hyprland" "kitty" "python-pywal" "imagemagick" "xdg-desktop-portal-hyprland")

for pkg in "${CRITICAL_CHECK[@]}"; do
    check_installed "$pkg"
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    print_success "All critical systems are ready! UWU"
    print_info "A system reboot is recommended."
else
    print_error "The following critical packages seem to be missing:"
    printf "  - %s\n" "${MISSING_PACKAGES[@]}"
fi