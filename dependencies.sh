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
)

# Dependencias de Hyprland
HYPRLAND_PACKAGES=( # Notification daemon
  "swww"  # Wallpaper daemon
  "grim"  # Screenshot utility
  "slurp" # Screen selection
)

# Instalar paquetes principales
print_info "Instalando paquetes principales..."
for package in "${MAIN_PACKAGES[@]}"; do
  print_info "Instalando $package..."
  sudo pacman -S --noconfirm "$package"
done

# Instalar paquetes de Hyprland
print_info "Instalando paquetes de Hyprland..."
for package in "${HYPRLAND_PACKAGES[@]}"; do
  print_info "Instalando $package..."
  sudo pacman -S --noconfirm "$package" || print_warning "⚠ No se pudo instalar $package"
done

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
    print_info "Instalando $package..."
    sudo pacman -S --noconfirm "$package" || print_warning "⚠ No se pudo instalar $package"
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
print_info "Ahora puedes ejecutar:"
echo "  ./install.sh"
echo
print_warning "Nota: Algunas configuraciones requieren reiniciar la sesión"
