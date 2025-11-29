#!/bin/bash
# Script maestro para instalación completa de dotfiles
# Ejecuta dependencies.sh seguido de install.sh
# Arch Linux + Hyprland Setup

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${MAGENTA}${1}${NC}"; }

# Banner
clear
print_header "╔══════════════════════════════════════════════════════════╗"
print_header "║        Instalación Completa de Dotfiles                  ║"
print_header "║     Arch Linux + Hyprland + Illogical Impulse            ║"
print_header "╚══════════════════════════════════════════════════════════╝"
echo

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verificar que los scripts existen
if [ ! -f "$SCRIPT_DIR/dependencies.sh" ]; then
  print_error "No se encontró dependencies.sh en $SCRIPT_DIR"
  exit 1
fi

if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
  print_error "No se encontró install.sh en $SCRIPT_DIR"
  exit 1
fi

# Hacer los scripts ejecutables si no lo son
chmod +x "$SCRIPT_DIR/dependencies.sh"
chmod +x "$SCRIPT_DIR/install.sh"

# Función para manejar errores
handle_error() {
  local script_name="$1"
  print_error "Error ejecutando $script_name"
  print_warning "¿Deseas continuar con el siguiente paso de todos modos?"
  read -p "Continuar (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Instalación cancelada por el usuario"
    exit 1
  fi
}

# ============================================================
# PASO 1: Instalación de Dependencias
# ============================================================
echo
print_header "═══════════════════════════════════════════════════════════"
print_header "  PASO 1/2: Instalando Dependencias"
print_header "═══════════════════════════════════════════════════════════"
echo
print_info "Ejecutando dependencies.sh..."
echo

if bash "$SCRIPT_DIR/dependencies.sh"; then
  echo
  print_success "✓ Fase de dependencias completada"
else
  echo
  handle_error "dependencies.sh"
fi

# Pausa entre scripts
echo
print_header "═══════════════════════════════════════════════════════════"  
print_info "Presiona Enter para continuar con la instalación de dotfiles..."
read -r

# ============================================================
# PASO 2: Instalación de Dotfiles
# ============================================================
echo
print_header "═══════════════════════════════════════════════════════════"
print_header "  PASO 2/2: Instalando Dotfiles y Configuraciones"
print_header "═══════════════════════════════════════════════════════════"
echo
print_info "Ejecutando install.sh..."
echo

if bash "$SCRIPT_DIR/install.sh"; then
  echo
  print_success "✓ Fase de instalación completada"
else
  echo
  handle_error "install.sh"
fi

# ============================================================
# Finalización
# ============================================================
echo
print_header "╔══════════════════════════════════════════════════════════╗"
print_header "║                 Rice Completado!                         ║"
print_header "╚══════════════════════════════════════════════════════════╝"

echo
print_success "Todo listo, mi amor! (>:<)"
echo
print_info "Próximos pasos:"
echo "  1. reinicia tu sistema"
echo "  2. Inicia sesión escribiendo 'Hyprland' en el TTY"
echo "  3. Disfruta de tu nuevo rice... ~Nya"
echo

# Preguntar si desea reiniciar ahora
print_info "¿Deseas reiniciar ahora?"
read -p "Reiniciar sistema (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  print_info "Reiniciando sistema..."
  systemctl reboot
else
  print_info "⚠ No olvides reiniciar más tarde para aplicar todos los cambios!"
fi