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

# Dependencias principales
MAIN_PACKAGES=(
  "fish"      # Shell
  "hyprland"  # Window manager
  "kitty"     # Terminal
  "neofetch"  # System info
  "neovim"    # Editor
  "git"       # Version control
  "qt5-tools" # Qt5 tools
  "starship"  # Cross-shell prompt
  "dolphin"   # File manager
)

# Dependencias de Hyprland
HYPRLAND_PACKAGES=(
  "swww"   # Wallpaper daemon
  "grim"   # Screenshot utility
  "slurp"  # Screen selection
  "waybar" # Status bar
)

# Paquetes opcionales
OPTIONAL_PACKAGES=(
  "code"    # iVS Code
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

# Mostrar paquetes que fallaron
if [ ${#failed_packages[@]} -ne 0 ]; then
  print_warning "Paquetes que no se pudieron instalar:"
  for package in "${failed_packages[@]}"; do
    echo "  • $package"
  done
  echo
  print_info "Puedes intentar instalarlos manualmente más tarde:"
  echo "sudo pacman -S ${failed_packages[*]}"
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

# AUR helper (yay)
if ! command -v yay >/dev/null 2>&1; then
  print_info "¿Instalar yay (AUR helper)?"
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
  fi
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
for package in "${MAIN_PACKAGES[@]}"; do
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
  print_info "Para reintentar solo los paquetes faltantes:"
  echo "  sudo pacman -S ${failed_packages[*]}"
fi

echo
print_warning "Nota: Algunas configuraciones requieren reiniciar la sesión"
