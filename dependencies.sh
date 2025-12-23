#!/bin/bash
# Script to install all necessary dependencies
# Arch Linux + Hyprland Setup
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_info "Installing dependencies for dotfiles..."
# Check if we are on Arch Linux
if ! command -v pacman >/dev/null 2>&1; then
  print_error "This script is designed for Arch Linux"
  exit 1
fi
# Check and fix HOME directory permissions
check_home_permissions() {
  local home_owner=$(stat -c %U "$HOME")
  local current_user=$(whoami)
  if [ "$home_owner" != "$current_user" ]; then
    print_error "HOME directory has incorrect permissions"
    print_info "Fixing HOME directory permissions..."
    sudo chown -R "$current_user:$current_user" "$HOME"
    chmod 755 "$HOME"
    print_success "✓ HOME directory permissions fixed"
  fi
}
# Check and repair PGP keys
fix_pgp_keys() {
  print_info "Checking pacman keyring status..."
  
  # Check if keyring is initialized
  if [ ! -f /etc/pacman.d/gnupg/trustdb.gpg ]; then
    print_warning "Keyring not initialized, initializing..."
    echo
    sudo pacman-key --init
    echo
    sudo pacman-key --populate archlinux
    echo
    print_success "✓ Keyring initialized"
    return 0
  fi
  
  # Check if main Arch keys are present
  print_info "Verifying Arch Linux keys..."
  local archlinux_keys_present=false
  
  # Try to list keys to verify keyring works
  echo
  if sudo pacman-key --list-keys | grep -q "Arch Linux"; then
    archlinux_keys_present=true
    echo
    print_success "✓ Arch Linux keys already present"
  fi
  
  # Check if pacman can use keyring correctly
  print_info "Verifying keyring functionality..."
  echo
  local pacman_test_output
  pacman_test_output=$(timeout 10 sudo pacman -Sy 2>&1)
  local pacman_exit=$?
  echo "$pacman_test_output"
  
  if echo "$pacman_test_output" | grep -qi "signature"; then
    print_warning "⚠ Signature issues detected, updating keys..."
    archlinux_keys_present=false
  elif [ $pacman_exit -eq 0 ]; then
    print_success "✓ Keyring works correctly"
    if $archlinux_keys_present; then
      print_info "Skipping key update (already configured)"
      return 0
    fi
  fi
  
  # Only update if necessary
  if ! $archlinux_keys_present; then
    print_info "Updating Arch Linux keys..."
    echo
    sudo pacman-key --populate archlinux
    
    print_info "Refreshing keys from servers (with 60s timeout)..."
    echo
    if timeout 60 sudo pacman-key --refresh-keys; then
      echo
      print_success "✓ Keys updated successfully"
    else
      echo
      print_warning "⚠ Timeout or error refreshing keys"
      print_info "Checking if basic keys work..."
      echo
      if timeout 10 sudo pacman -Sy; then
        echo
        print_success "✓ Basic keys work, continuing..."
      else
        echo
        print_error "✗ Keyring problem"
        print_info "Try manually: sudo pacman-key --init && sudo pacman-key --populate archlinux"
        return 1
      fi
    fi
  fi
  
  print_success "✓ Keyring verified and ready"
  return 0
}
# AUR helper (yay)
install_yay_optional() {
  if ! command -v yay >/dev/null 2>&1; then
    print_info "Install yay (AUR helper)?"
    print_warning "Required for some additional dependencies"
    read -p "Recommended for some additional packages (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_info "Installing yay..."
      
      local yay_deps=("git" "base-devel")
      for dep in "${yay_deps[@]}"; do
        if ! is_package_installed "$dep"; then
          print_info "Installing dependency: $dep"
          sudo pacman -S --noconfirm "$dep"
        fi
      done
      
      cd /tmp
      git clone https://aur.archlinux.org/yay.git
      cd yay
      makepkg -si --noconfirm
      cd ~
      print_success "✓ yay installed"
      return 0
    else
      print_warning "Without yay, AUR packages will be skipped"
      return 1
    fi
  else
    print_success "✓ yay already installed"
    return 0
  fi
}
check_home_permissions
fix_pgp_keys
print_info "Updating system..."
sudo pacman -Syu --noconfirm
# Main dependencies
MAIN_PACKAGES=(
  "base-devel"         
  "fish"                
  "starship"            
  "hyprland"             
  "kitty"               
  "neovim"                            
  "qt5-tools"           
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
)
HYPRLAND_PACKAGES=(
  "swww"  
  "grim"  
  "slurp"  
)
NEW_PACMAN_PACKAGES=(
  "geoclue"
  "nano"
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
  "imagemagick"           
  "python-pip"           
  "go"     
  "cava"
  "gnome-system-monitor"         
  "pavucontrol-qt"
  "fastfetch"
  "songrec"
  "python-colorthief"
  "hyprsunset"     
)
AUR_PACKAGES=(              
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
OPTIONAL_PACKAGES=(
  "visual-studio-code-bin"
  "discord"
  "brave-bin"
)
is_package_installed() {
  local package="$1"
  pacman -Qi "$package" >/dev/null 2>&1
}
install_package() {
  local package="$1"
  local max_retries=3
  local retry=0
  if is_package_installed "$package"; then
    print_success "✓ $package already installed"
    return 0
  fi
  while [ $retry -lt $max_retries ]; do
    print_info "Installing $package... (attempt $((retry + 1)))"
    
    if timeout 180 sudo pacman -S --noconfirm "$package"; then
      print_success "✓ $package installed successfully"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error installing $package (attempt $((retry + 1)))"
      
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout installing $package"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Waiting 5 seconds before next attempt..."
        
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Retrying in $i seconds..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Retrying now...                    "
        
        sudo pacman -Sc --noconfirm
      fi
    fi
  done
  print_error "✗ Could not install $package after $max_retries attempts"
  return 1
}
is_aur_package_installed() {
  local package="$1"
  yay -Qi "$package" 2>/dev/null >/dev/null
}
install_aur_package() {
  local package="$1"
  local max_retries=3
  local retry=0
  if is_aur_package_installed "$package"; then
    print_success "✓ $package already installed"
    return 0
  fi
  while [ $retry -lt $max_retries ]; do
    print_info "Installing $package from AUR... (attempt $((retry + 1)))"
    
    if timeout 300 yay -S --noconfirm "$package"; then
      print_success "✓ $package installed successfully from AUR"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error installing $package from AUR (attempt $((retry + 1)))"
      
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout installing $package from AUR"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Waiting 5 seconds before next attempt..."
        
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Retrying in $i seconds..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Retrying now...                    "
        
        yay -Sc --noconfirm
      fi
    fi
  done
  print_error "✗ Could not install $package from AUR after $max_retries attempts"
  return 1
}
# Install main packages
print_info "Installing main packages..."
failed_packages=()
for package in "${MAIN_PACKAGES[@]}"; do
  if ! install_package "$package"; then
    failed_packages+=("$package")
  fi
done
print_info "Installing Hyprland packages..."
for package in "${HYPRLAND_PACKAGES[@]}"; do
  if ! install_package "$package"; then
    failed_packages+=("$package")
  fi
done
print_info "Installing new dependencies with pacman..."
for package in "${NEW_PACMAN_PACKAGES[@]}"; do
  if [[ ! " ${MAIN_PACKAGES[@]} " =~ " ${package} " ]] && [[ ! " ${HYPRLAND_PACKAGES[@]} " =~ " ${package} " ]]; then
    if ! install_package "$package"; then
      failed_packages+=("$package")
    fi
  else
    if is_package_installed "$package"; then
      print_success "✓ $package already installed (skipping duplicate)"
    else
      print_info "Skipping $package (already included in another list)"
    fi
  fi
done
yay_installed=false
if install_yay_optional; then
  yay_installed=true
fi
if $yay_installed || command -v yay >/dev/null 2>&1; then
  print_info "Installing dependencies from AUR..."
  failed_aur_packages=()
  for package in "${AUR_PACKAGES[@]}"; do
    if ! install_aur_package "$package"; then
      failed_aur_packages+=("$package")
    fi
  done
  failed_packages+=("${failed_aur_packages[@]}")
else
  print_warning "⚠ yay not available, skipping AUR packages"
  print_info "AUR packages that were skipped:"
  for package in "${AUR_PACKAGES[@]}"; do
    echo "  • $package"
  done
  echo
fi
if [ ${#failed_packages[@]} -ne 0 ]; then
  print_warning "Packages that could not be installed:"
  for package in "${failed_packages[@]}"; do
    echo "  • $package"
  done
  echo
  print_info "You can try to install them manually later:"
  echo "Pacman: sudo pacman -S [package]"
  if command -v yay >/dev/null 2>&1; then
    echo "AUR: yay -S [package]"
  fi
  echo
fi
if command -v yay >/dev/null 2>&1; then
  echo
  print_info "Optional packages available:"
  for package in "${OPTIONAL_PACKAGES[@]}"; do
    echo "  • $package"
  done
  read -t 30 -p "Install optional packages? (y/N) [timeout 30s]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for package in "${OPTIONAL_PACKAGES[@]}"; do
      install_aur_package "$package"
    done
  else
    if [ -z "$REPLY" ]; then
      print_info "Timeout reached, skipping optional packages"
    fi
  fi
else
  print_info "Optional packages skipped (require yay)"
fi
print_info "Configuring color tools for wal..."
if command -v wal >/dev/null 2>&1; then
  print_success "✓ pywal (wal) is available"
  mkdir -p "$HOME/.cache/wal"
  print_success "✓ wal cache directory created"
  if command -v convert >/dev/null 2>&1; then
    print_success "✓ ImageMagick available for wal"
  else
    print_warning "⚠ ImageMagick not found (recommended for wal)"
  fi
else
  print_error "✗ pywal not available"
  print_info "Install with: sudo pacman -S python-pywal"
fi
if command -v matugen >/dev/null 2>&1; then
  print_success "✓ matugen available for Material You schemes"
else
  print_warning "⚠ matugen not found (will be installed from AUR if yay is available)"
fi
if command -v fastfetch >/dev/null 2>&1; then
  print_success "✓ fastfetch available"
else
  print_warning "⚠ fastfetch not found (will be installed from AUR if yay is available)"
fi
print_success "Dependencies installed!"
print_warning "NOTE: Quickshell will be installed with Illogical Impulse during install.sh"
echo
print_info "Final verification of main dependencies..."
declare -A PACKAGE_TO_COMMAND=(
  ["python-pywal"]="wal"
  ["imagemagick"]="convert"
  ["python-pillow"]="python3 -c 'import PIL'"
  ["fish"]="fish"
  ["starship"]="starship"
  ["hyprland"]="Hyprland"
  ["kitty"]="kitty"
  ["neovim"]="nvim"
  ["git"]="git"
  ["dolphin"]="dolphin"
  ["eza"]="eza"
  ["cliphist"]="cliphist"
  ["ddcutil"]="ddcutil"
  ["fuzzel"]="fuzzel"
  ["brightnessctl"]="brightnessctl"
  ["ripgrep"]="rg"
  ["jq"]="jq"
  ["curl"]="curl"
  ["wget"]="wget"
  ["rsync"]="rsync"
  ["bc"]="bc"
  ["fastfetch"]="fastfetch"
  ["matugen-bin"]="matugen"
)
all_good=true
all_packages=("${MAIN_PACKAGES[@]}" "${HYPRLAND_PACKAGES[@]}" "${NEW_PACMAN_PACKAGES[@]}")
print_info "Verifying critical dependencies for wal..."
WAL_CRITICAL=("python-pywal" "imagemagick" "python-pillow")
for package in "${WAL_CRITICAL[@]}"; do
  if [[ -n "${PACKAGE_TO_COMMAND[$package]}" ]]; then
    if eval "${PACKAGE_TO_COMMAND[$package]}" --version >/dev/null 2>&1 || eval "${PACKAGE_TO_COMMAND[$package]}" >/dev/null 2>&1; then
      print_success "✓ $package (critical for wal)"
    elif is_package_installed "$package"; then
      print_success "✓ $package installed (critical for wal)"
    else
      print_error "✗ $package (critical for wal)"
      all_good=false
    fi
  else
    if is_package_installed "$package"; then
      print_success "✓ $package (critical for wal)"
    else
      print_error "✗ $package (critical for wal)"
      all_good=false
    fi
  fi
done
print_info "Verifying other dependencies..."
for package in "${all_packages[@]}"; do
  if [[ ! " ${WAL_CRITICAL[@]} " =~ " ${package} " ]]; then
    if [[ -n "${PACKAGE_TO_COMMAND[$package]}" ]]; then
      if eval "${PACKAGE_TO_COMMAND[$package]}" --version >/dev/null 2>&1 || eval "${PACKAGE_TO_COMMAND[$package]}" >/dev/null 2>&1; then
        print_success "✓ $package"
      elif is_package_installed "$package"; then
        print_success "✓ $package installed"
      else
        print_error "✗ $package"
        all_good=false
      fi
    else
      if is_package_installed "$package"; then
        print_success "✓ $package"
      else
        print_error "✗ $package"
        all_good=false
      fi
    fi
  fi
done
echo
if [[ $all_good == true ]]; then
  print_success "All main dependencies are ready UWU "
else
  print_warning "⚠ Some dependencies failed, but you can continue"
  print_info "To retry only missing packages, check the list above"
fi