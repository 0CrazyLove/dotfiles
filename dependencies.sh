#!/bin/bash
# Script para instalar todas las dependencias necesarias
# Arch Linux + Hyprland Setup

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_info "🚀 Instalando dependencias para dotfiles..."

# Verificar si estamos en Arch Linux
if ! command -v pacman >/dev/null 2>&1; then
  print_error "Este script está diseñado para Arch Linux"
  exit 1
fi

# Verificar y arreglar permisos del directorio HOME
check_home_permissions() {
  local home_owner=$(stat -c %U "$HOME")
  local current_user=$(whoami)

  if [ "$home_owner" != "$current_user" ]; then
    print_error "Directorio HOME tiene permisos incorrectos"
    print_info "Arreglando permisos del directorio HOME..."
    sudo chown -R "$current_user:$current_user" "$HOME"
    chmod 755 "$HOME"
    print_success "✓ Permisos del directorio HOME corregidos"
  fi
}

# Verificar y reparar claves PGP
fix_pgp_keys() {
  print_info "Verificando claves PGP de pacman..."

  # Inicializar keyring si no existe
  if [ ! -f /etc/pacman.d/gnupg/trustdb.gpg ]; then
    print_info "Inicializando keyring de pacman..."
    sudo pacman-key --init
  fi

  # Actualizar claves archlinux
  print_info "Actualizando claves de Arch Linux..."
  sudo pacman-key --populate archlinux

  # Actualizar claves desde servidores
  print_info "Actualizando claves desde servidores..."
  sudo pacman-key --refresh-keys

  print_success "✓ Claves PGP verificadas"
}

# Verificar permisos HOME
check_home_permissions

# Arreglar claves PGP
fix_pgp_keys

# Actualizar sistema
print_info "Actualizando sistema..."
sudo pacman -Syu --noconfirm

# Dependencias principales (sin wlogout)
MAIN_PACKAGES=(
  "fish"                 # Shell
  "starship"             # Cross-shell prompt
  "hyprland"             # Window manager
  "kitty"                # Terminal
  "neovim"               # Editor
  "git"                  # Version control
  "qt5-tools"            # Qt5 tools
  "dolphin"              # File manager
  "eza"                  # Modern ls replacement
  "python-pywal"         # Color scheme generator
  "cliphist"             # Clipboard manager
  "ddcutil"              # Display control utility
  "python-pillow"        # Python imaging library
  "fuzzel"               # Application launcher
  "glib2"                # GLib library
  "hypridle"             # Hyprland idle daemon
  "hyprutils"            # Hyprland utilities
  "hyprlock"             # Hyprland lock screen
  "hyprpicker"           # Color picker for Hyprland
  "nm-connection-editor" # Network manager connection editor
)

# Dependencias de Hyprland
HYPRLAND_PACKAGES=(
  "swww"   # Wallpaper daemon
  "grim"   # Screenshot utility
  "slurp"  # Screen selection
  "waybar" # Status bar
)

# Nuevas dependencias con pacman
NEW_PACMAN_PACKAGES=(
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
)

# Dependencias AUR (yay) - ahora incluye wlogout
AUR_PACKAGES=(
  "neofetch"                # System info
  "translate-shell"         # Command-line translator
  "python-materialyoucolor" # Material You color library
  "quickshell-git"          # Shell for Qt Quick
  "wlogout"                 # Logout menu for Wayland (movido de pacman a AUR)
  # Nuevos paquetes AUR
  "adw-gtk-theme-git"
  "breeze-plus"
  "darkly-bin"
  "kde-material-you-colors"
  "matugen-bin"
  "otf-space-grotesk"
  "ttf-gabarito-git"
  "ttf-jetbrains-mono-nerd"
  "ttf-material-symbols-variable-git"
  "ttf-readex-pro"
  "ttf-rubik-vf"
  "ttf-twemoji"
  "hyprcursor"
  "hyprland-qtutils"
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
  "qt6-avif-image-plugin"
  "wtype"
  "ydotool"
)

# Paquetes opcionales
OPTIONAL_PACKAGES=(
  "code"    # VS Code
  "discord" # Communication
  "spotify" # Music
)

# Función para instalar paquetes con retry
install_package() {
  local package="$1"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package... (intento $((retry + 1)))"
    if sudo pacman -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente"
      return 0
    else
      print_warning "⚠ Error instalando $package (intento $((retry + 1)))"
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        sleep 5
        # Actualizar claves si falla
        sudo pacman-key --refresh-keys >/dev/null 2>&1
      fi
    fi
  done

  print_error "✗ No se pudo instalar $package después de $max_retries intentos"
  return 1
}

# Función para instalar paquetes AUR con yay
install_aur_package() {
  local package="$1"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package desde AUR... (intento $((retry + 1)))"
    if yay -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente desde AUR"
      return 0
    else
      print_warning "⚠ Error instalando $package desde AUR (intento $((retry + 1)))"
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        sleep 5
      fi
    fi
  done

  print_error "✗ No se pudo instalar $package desde AUR después de $max_retries intentos"
  return 1
}

# Instalar paquetes principales
print_info "Instalando paquetes principales..."
failed_packages=()

for package in "${MAIN_PACKAGES[@]}"; do
  if ! install_package "$package"; then
    failed_packages+=("$package")
  fi
done

# Instalar paquetes de Hyprland
print_info "Instalando paquetes de Hyprland..."
for package in "${HYPRLAND_PACKAGES[@]}"; do
  if ! install_package "$package"; then
    failed_packages+=("$package")
  fi
done

# Instalar nuevas dependencias con pacman
print_info "Instalando nuevas dependencias con pacman..."
for package in "${NEW_PACMAN_PACKAGES[@]}"; do
  # Evitar duplicados con paquetes ya definidos
  if [[ ! " ${MAIN_PACKAGES[@]} " =~ " ${package} " ]] && [[ ! " ${HYPRLAND_PACKAGES[@]} " =~ " ${package} " ]]; then
    if ! install_package "$package"; then
      failed_packages+=("$package")
    fi
  else
    print_info "Saltando $package (ya incluido en otra lista)"
  fi
done

# AUR helper (yay) - Instalar primero si no existe
if ! command -v yay >/dev/null 2>&1; then
  print_info "¿Instalar yay (AUR helper)?"
  print_warning "Requerido para algunas dependencias adicionales"
  read -p "Recomendado para algunos paquetes adicionales (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Instalando yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    print_success "✓ yay instalado"
  else
    print_warning "Sin yay, se omitirán paquetes AUR"
  fi
fi

# Instalar paquetes AUR si yay está disponible
if command -v yay >/dev/null 2>&1; then
  print_info "Instalando dependencias desde AUR..."
  failed_aur_packages=()

  for package in "${AUR_PACKAGES[@]}"; do
    if ! install_aur_package "$package"; then
      failed_aur_packages+=("$package")
    fi
  done

  # Agregar paquetes AUR fallidos a la lista general
  failed_packages+=("${failed_aur_packages[@]}")
else
  print_warning "yay no está disponible, omitiendo paquetes AUR"
  failed_packages+=("${AUR_PACKAGES[@]}")
fi

# Mostrar paquetes que fallaron
if [ ${#failed_packages[@]} -ne 0 ]; then
  print_warning "Paquetes que no se pudieron instalar:"
  for package in "${failed_packages[@]}"; do
    echo "  • $package"
  done
  echo
  print_info "Puedes intentar instalarlos manualmente más tarde:"
  echo "Pacman: sudo pacman -S [paquete]"
  echo "AUR: yay -S [paquete]"
  echo
fi

# Preguntar por paquetes opcionales
echo
print_info "Paquetes opcionales disponibles:"
for package in "${OPTIONAL_PACKAGES[@]}"; do
  echo "  • $package"
done
read -p "¿Instalar paquetes opcionales? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  for package in "${OPTIONAL_PACKAGES[@]}"; do
    install_package "$package"
  done
fi

# Configurar Fish como shell por defecto
if command -v fish >/dev/null 2>&1; then
  current_shell=$(echo $SHELL)
  if [[ "$current_shell" != *"fish"* ]]; then
    print_info "¿Configurar Fish como shell por defecto?"
    read -p "(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      chsh -s /usr/bin/fish
      print_success "✓ Fish configurado como shell por defecto"
      print_warning "⚠ Reinicia la sesión para aplicar cambios"
    fi
  fi
fi

print_success "🎉 ¡Dependencias instaladas!"
echo

# Verificar estado final
print_info "Verificación final de dependencias principales..."
all_good=true
all_packages=("${MAIN_PACKAGES[@]}" "${HYPRLAND_PACKAGES[@]}" "${NEW_PACMAN_PACKAGES[@]}")

for package in "${all_packages[@]}"; do
  if command -v "$package" >/dev/null 2>&1 || pacman -Qi "$package" >/dev/null 2>&1; then
    print_success "✓ $package"
  else
    print_error "✗ $package"
    all_good=false
  fi
done

echo
if $all_good; then
  print_success "✅ Todas las dependencias principales están listas"
  print_info "Ahora puedes ejecutar:"
  echo "  ./install.sh"
else
  print_warning "⚠ Algunas dependencias fallaron, pero puedes continuar"
  print_info "Para reintentar solo los paquetes faltantes, consulta la lista anterior"
fi

echo
print_warning "Nota: Algunas configuraciones requieren reiniciar la sesión"

