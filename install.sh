#!/bin/bash

# Script de instalación de dotfiles
# Arch Linux + Hyprland Setup

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
WALLPAPERS_DIR="$HOME/Documents"

print_info "Iniciando instalación de dotfiles..."

# Verificar si existe el directorio de dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Directorio $DOTFILES_DIR no encontrado!"
    print_info "Clona primero el repositorio:"
    echo "git clone https://github.com/0CrazyLove/dotfiles.git $DOTFILES_DIR"
    exit 1
fi

# Crear directorio de backup
print_info "Creando backup en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Función para crear backup y symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    print_info "Instalando configuración de $name..."
    
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"
    
    # Hacer backup si el archivo/directorio existe
    if [ -e "$target" ]; then
        print_warning "Backup de $target existente"
        mv "$target" "$BACKUP_DIR/"
    fi
    
    # Crear symlink
    ln -sf "$source" "$target"
    print_success "✓ $name configurado"
}

# Crear directorio .config si no existe
mkdir -p "$HOME/.config"

print_info "Instalando configuraciones..."

# Instalar configuraciones de .config
create_symlink "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish" "Fish shell"
create_symlink "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr" "Hyprland"
create_symlink "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty" "Kitty terminal"
create_symlink "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch" "Neofetch"
create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim"
create_symlink "$DOTFILES_DIR/.config/quickshell" "$HOME/.config/quickshell" "Quickshell"

# Instalar fondos de pantalla
if [ -d "$DOTFILES_DIR/FondosPantallas" ]; then
    print_info "Instalando fondos de pantalla..."
    
    # Crear directorio Documents si no existe
    mkdir -p "$WALLPAPERS_DIR"
    
    # Hacer backup si existe
    if [ -d "$WALLPAPERS_DIR/FondosPantallas" ]; then
        print_warning "Backup de fondos existentes"
        mv "$WALLPAPERS_DIR/FondosPantallas" "$BACKUP_DIR/"
    fi
    
    # Copiar fondos (no symlink para evitar problemas con aplicaciones)
    cp -r "$DOTFILES_DIR/FondosPantallas" "$WALLPAPERS_DIR/"
    print_success "✓ Fondos de pantalla instalados"
else
    print_warning "Carpeta FondosPantallas no encontrada"
fi

print_success "🎉 Instalación completada!"
print_info "Backup guardado en: $BACKUP_DIR"
echo
print_info "Para aplicar los cambios:"
echo "  • Reinicia tu sesión o recarga Hyprland: Super+Shift+R"
echo "  • Para Fish: exec fish"
echo "  • Para Neovim: Los plugins se instalarán automáticamente"
echo
print_warning "Si algo no funciona, puedes restaurar desde: $BACKUP_DIR"
