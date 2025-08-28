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

# Lista de dependencias requeridas
DEPENDENCIES=(
  "fish"
  "hyprland"
  "kitty"
  "neofetch"
  "nvim"
)

# Lista de dependencias opcionales
OPTIONAL_DEPS=(
  "waybar"
  "rofi"
  "wofi"
)

# Función para verificar si un comando existe
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verificar dependencias
print_info "Verificando dependencias..."
missing_deps=()
missing_optional=()

for dep in "${DEPENDENCIES[@]}"; do
  if ! command_exists "$dep"; then
    missing_deps+=("$dep")
    print_error "✗ $dep no encontrado"
  else
    print_success "✓ $dep encontrado"
  fi
done

for dep in "${OPTIONAL_DEPS[@]}"; do
  if ! command_exists "$dep"; then
    missing_optional+=("$dep")
    print_warning "⚠ $dep no encontrado (opcional)"
  else
    print_success "✓ $dep encontrado"
  fi
done

# Mostrar comandos de instalación si faltan dependencias
if [ ${#missing_deps[@]} -ne 0 ]; then
  print_error "Faltan dependencias requeridas!"
  echo
  print_info "Instala las dependencias faltantes con:"
  echo "sudo pacman -S ${missing_deps[*]}"
  echo
  read -p "¿Continuar sin las dependencias faltantes? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Instalación cancelada. Instala las dependencias primero."
    exit 1
  fi
fi

if [ ${#missing_optional[@]} -ne 0 ]; then
  echo
  print_info "Dependencias opcionales faltantes (recomendadas):"
  echo "sudo pacman -S ${missing_optional[*]}"
  echo
fi

# Crear directorio de backup
print_info "Creando backup en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Función para configurar carga automática del módulo WiFi
configure_wifi_module() {
  print_info "Configurando carga automática del módulo WiFi..."

  if [ -f "/etc/modules-load.d/wifi.conf" ]; then
    print_warning "Archivo /etc/modules-load.d/wifi.conf ya existe"
    if grep -q "rtl8xxxu" /etc/modules-load.d/wifi.conf; then
      print_success "✓ Módulo rtl8xxxu ya está configurado"
      return
    fi
  fi

  # Configurar el módulo para carga automática
  if echo "rtl8xxxu" | sudo tee /etc/modules-load.d/wifi.conf >/dev/null 2>&1; then
    print_success "✓ Módulo WiFi configurado para carga automática"

    # Cargar el módulo inmediatamente
    if sudo modprobe rtl8xxxu >/dev/null 2>&1; then
      print_success "✓ Módulo WiFi cargado correctamente"
    else
      print_warning "⚠ No se pudo cargar el módulo inmediatamente (se cargará en el próximo reinicio)"
    fi
  else
    print_error "✗ Error al configurar el módulo WiFi"
    print_warning "Puedes ejecutar manualmente: echo 'rtl8xxxu' | sudo tee /etc/modules-load.d/wifi.conf"
  fi
}

# Función para crear backup y copiar archivos
install_config() {
  local source="$1"
  local target="$2"
  local name="$3"

  print_info "Instalando configuración de $name..."

  # Verificar que el origen existe
  if [ ! -d "$source" ]; then
    print_warning "⚠ $source no encontrado, saltando $name"
    return
  fi

  # Crear directorio padre si no existe
  mkdir -p "$(dirname "$target")"

  # Hacer backup si el archivo/directorio existe
  if [ -e "$target" ]; then
    print_warning "Backup de $target existente"
    mv "$target" "$BACKUP_DIR/"
  fi

  # Copiar archivos
  cp -r "$source" "$target"
  print_success "✓ $name configurado"
}

# Crear directorio .config si no existe
mkdir -p "$HOME/.config"

print_info "Instalando configuraciones..."

# Instalar configuraciones de .config
install_config "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish" "Fish shell"
install_config "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr" "Hyprland"
install_config "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty" "Kitty terminal"
install_config "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch" "Neofetch"
install_config "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim"
install_config "$DOTFILES_DIR/.config/quickshell" "$HOME/.config/quickshell" "Quickshell"

# Configurar módulo WiFi automático
configure_wifi_module

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
echo "  • El módulo WiFi se cargará automáticamente en futuros reinicios"
echo
print_info "Configuraciones instaladas como archivos independientes."
print_info "Puedes eliminar el directorio ~/dotfiles si quieres."
echo
print_warning "Para actualizar en el futuro, usa: ./update.sh desde ~/dotfiles"
