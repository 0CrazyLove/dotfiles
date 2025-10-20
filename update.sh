#!/bin/bash
# Script para actualizar dotfiles en el repositorio

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="$HOME/dotfiles"

# Verificar que estamos en el directorio correcto
if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Directorio $DOTFILES_DIR no encontrado!"
  exit 1
fi

cd "$DOTFILES_DIR"
print_info "Actualizando dotfiles desde configuraciones actuales..."

# Función para actualizar configuraciones
update_config() {
  local config_name="$1"
  local source_path="$HOME/.config/$config_name"
  local dest_path=".config/$config_name"

  if [ -d "$source_path" ]; then
    print_info "Actualizando $config_name..."
    # Eliminar configuración antigua en dotfiles
    rm -rf "$dest_path"
    # Copiar nueva configuración
    cp -r "$source_path" "$dest_path"
    # Limpiar archivos git si existen
    find "$dest_path" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
    print_success "✓ $config_name actualizado"
  else
    print_warning "⚠ $config_name no encontrado en ~/.config/"
  fi
}

# Función para actualizar archivos individuales
update_file() {
  local config_name="$1"
  local source_path="$HOME/.config/$config_name"
  local dest_path=".config/$config_name"

  if [ -f "$source_path" ]; then
    print_info "Actualizando $config_name..."
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$dest_path")"
    # Copiar archivo
    cp "$source_path" "$dest_path"
    print_success "✓ $config_name actualizado"
  else
    print_warning "⚠ $config_name no encontrado en ~/.config/"
  fi
}

# Actualizar cada configuración (directorios)
update_config "fish"
update_config "fastfetch"
update_config "hypr"
update_config "kitty"
update_config "neofetch"
# update_config "nvim" 
update_config "quickshell"

# Actualizar archivos individuales
update_file "starship.toml"

# Actualizar fondos de pantalla
if [ -d "$HOME/Documents/Wallpapers" ]; then
  print_info "Actualizando fondos de pantalla..."
  rm -rf "Wallpapers"
  cp -r "$HOME/Documents/Wallpapers" "./"
  print_success "✓ Fondos actualizados"
else
  print_warning "⚠ Carpeta de wallpapers no encontrada en ~/Documents/Wallpapers"
fi

# Mostrar estado de git
print_info "Estado del repositorio:"
git status --short

# Preguntar si hacer commit
echo
read -p "¿Hacer commit de los cambios? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Pedir mensaje de commit
  read -p "Mensaje del commit (o Enter para mensaje automático): " commit_msg

  if [ -z "$commit_msg" ]; then
    commit_msg="Update dotfiles - $(date +'%Y-%m-%d %H:%M')"
  fi

  # Hacer commit y push
  git add .
  git commit -m "$commit_msg"

  read -p "¿Subir cambios a GitHub? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push
    print_success "Dotfile actualizado en GitHub!"
  else
    print_info "Cambios guardados localmente. Usa 'git push' para subir."
  fi
else
  print_info "Cambios no commiteados. Revisa con 'git status'"
fi