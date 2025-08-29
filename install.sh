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

# Verificar permisos del directorio HOME
check_home_permissions() {
  local home_owner=$(stat -c %U "$HOME")
  local current_user=$(whoami)

  if [ "$home_owner" != "$current_user" ]; then
    print_error "Directorio HOME tiene permisos incorrectos"
    print_info "Arreglando permisos del directorio HOME..."
    sudo chown -R "$current_user:$current_user" "$HOME"
    chmod 755 "$HOME"
    chmod -R u+w "$HOME"
    print_success "✓ Permisos del directorio HOME corregidos"
  fi
}

# Verificar permisos antes de continuar
check_home_permissions

# Verificar si existe el directorio de dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Directorio $DOTFILES_DIR no encontrado!"
  print_info "Clona primero el repositorio:"
  echo "git clone https://github.com/0CrazyLove/dotfiles.git $DOTFILES_DIR"
  exit 1
fi

# Lista de dependencias requeridas (actualizada)
DEPENDENCIES=(
  "fish"
  "hyprland"
  "kitty"
  "neofetch"
  "nvim"
  "starship"
  "git"
)

# Lista de dependencias opcionales (actualizada)
OPTIONAL_DEPS=(
  "waybar"
  "rofi"
  "wofi"
  "dolphin"
  "mako"
  "swww"
  "grim"
  "slurp"
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
  # Verificar tanto el comando como el paquete instalado
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_deps+=("$dep")
    print_error "✗ $dep no encontrado"
  else
    print_success "✓ $dep encontrado"
  fi
done

for dep in "${OPTIONAL_DEPS[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
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
  print_info "O ejecuta primero el script de dependencias:"
  echo "./dependencies.sh"
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
  if cp -r "$source" "$target"; then
    print_success "✓ $name configurado"
  else
    print_error "✗ Error copiando $name"
    return 1
  fi
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

# Configurar starship si está instalado
if command_exists starship; then
  print_info "Configurando Starship..."
  if [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
    install_config "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship"
  fi
fi

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
  if cp -r "$DOTFILES_DIR/FondosPantallas" "$WALLPAPERS_DIR/"; then
    print_success "✓ Fondos de pantalla instalados"
  else
    print_warning "⚠ Error copiando fondos de pantalla"
  fi
else
  print_warning "Carpeta FondosPantallas no encontrada"
fi

# Configurar Fish si está instalado
if command_exists fish; then
  print_info "Configurando Fish shell..."

  # Añadir starship al config de fish si está disponible
  if command_exists starship && [ -f "$HOME/.config/fish/config.fish" ]; then
    if ! grep -q "starship init fish" "$HOME/.config/fish/config.fish"; then
      echo "starship init fish | source" >>"$HOME/.config/fish/config.fish"
      print_success "✓ Starship añadido a Fish config"
    fi
  fi
fi

print_success "🎉 Instalación completada!"
print_info "Backup guardado en: $BACKUP_DIR"
echo

# Verificación final
print_info "Verificando instalación..."
configs_ok=true

# Verificar configuraciones principales
check_config() {
  local config_path="$1"
  local name="$2"

  if [ -e "$config_path" ]; then
    print_success "✓ $name configurado"
  else
    print_error "✗ $name no encontrado"
    configs_ok=false
  fi
}

check_config "$HOME/.config/fish" "Fish"
check_config "$HOME/.config/hypr" "Hyprland"
check_config "$HOME/.config/kitty" "Kitty"
check_config "$HOME/.config/neofetch" "Neofetch"
check_config "$HOME/.config/nvim" "Neovim"

echo
if $configs_ok; then
  print_success "✅ Todas las configuraciones están en su lugar"
else
  print_warning "⚠ Algunas configuraciones pueden tener problemas"
fi

echo
print_info "Para aplicar los cambios:"
echo "  • Reinicia tu sesión o recarga Hyprland: Super+Shift+R"
echo "  • Para Fish: exec fish"
echo "  • Para Neovim: Los plugins se instalarán automáticamente"
echo "  • Para Starship: Reinicia tu terminal"
echo "  • El módulo WiFi se cargará automáticamente en futuros reinicios"
echo
print_info "Configuraciones instaladas como archivos independientes."
print_info "Puedes eliminar el directorio ~/dotfiles si quieres."
echo
print_warning "Para actualizar en el futuro, usa: ./update.sh desde ~/dotfiles"
