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

# Verificar y reparar claves PGP (MEJORADO)
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

  # Actualizar claves desde servidores CON TIMEOUT
  print_info "Actualizando claves desde servidores..."
  # Usar timeout para evitar cuelgues y mostrar salida
  if timeout 60 sudo pacman-key --refresh-keys; then
    print_success "✓ Claves PGP actualizadas"
  else
    print_warning "⚠ Timeout o error actualizando claves PGP, continuando..."
  fi
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
  "python-pywal"         # Color scheme generator (IMPORTANTE para wal)
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
  "python-opencv" # Para procesamiento de imágenes (útil con wal)
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
  "imagemagick"       # NUEVO: Para manipulación de imágenes (importante para wal)
  "python-colorthief" # NUEVO: Para extracción de colores
  "base-devel"        # NUEVO: Necesario para compilar paquetes AUR
)

# Dependencias AUR (yay) - wlogout incluido, kde-material-you-colors REMOVIDO
AUR_PACKAGES=(
  "neofetch"                # System info
  "translate-shell"         # Command-line translator
  "python-materialyoucolor" # Material You color library (útil para wal)
  "quickshell-git"          # Shell for Qt Quick
  "wlogout"                 # Logout menu for Wayland
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
  "wtype"
  "ydotool"
  "wallust"         
  "python-haishoku" 
)

# Paquetes opcionales 
OPTIONAL_PACKAGES=(
  "visual-studio-code-bin"   # VS Code
  "discord" # Communication
  "spotify" # Music
  "brave-bin"   # Brave browser
  "mako"    # Notification daemon
  "dunst"   # Alternativa a mako
)

# Función para instalar paquetes con retry (MEJORADA)
install_package() {
  local package="$1"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package... (intento $((retry + 1)))"
    
    # Usar timeout para evitar cuelgues indefinidos - MOSTRAR OUTPUT
    if timeout 180 sudo pacman -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error instalando $package (intento $((retry + 1)))"
      
      # Solo incrementar retry si no fue por timeout
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout instalando $package"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        
        # Sleep con progreso visual para evitar sensación de cuelgue
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Reintentando en $i segundos..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Reintentando ahora...                    "
        
        # Limpiar cache de pacman si falla
        sudo pacman -Sc --noconfirm
      fi
    fi
  done

  print_error "✗ No se pudo instalar $package después de $max_retries intentos"
  return 1
}

# Función para instalar paquetes AUR con yay (MEJORADA)
install_aur_package() {
  local package="$1"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package desde AUR... (intento $((retry + 1)))"
    
    # Usar timeout también para AUR - MOSTRAR OUTPUT
    if timeout 300 yay -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente desde AUR"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error instalando $package desde AUR (intento $((retry + 1)))"
      
      # Solo incrementar retry si no fue por timeout
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout instalando $package desde AUR"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        
        # Sleep con progreso visual
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Reintentando en $i segundos..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Reintentando ahora...                    "
        
        # Limpiar cache de yay si falla
        yay -Sc --noconfirm
      fi
    fi
  done

  print_error "✗ No se pudo instalar $package desde AUR después de $max_retries intentos"
  return 1
}

# Función para verificar si un proceso está colgado
is_process_hung() {
  local pid=$1
  local check_time=10  # Verificar cada 10 segundos
  local hung_threshold=30  # Considerar colgado después de 30 segundos sin output
  
  # Esta función podría expandirse para detectar procesos colgados
  # Por ahora, confiaremos en timeout
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

# AUR helper (yay) - VERSIÓN ARREGLADA
install_yay_safe() {
  print_info "Instalando yay (AUR helper)..."
  print_info "yay es necesario para instalar dependencias adicionales desde AUR"

  # Crear directorio temporal único
  local temp_dir="/tmp/yay-install-$$"
  mkdir -p "$temp_dir"
  
  cd "$temp_dir" || {
    print_error "No se pudo crear directorio temporal"
    return 1
  }

  # Clonar yay con timeout y mejor manejo de errores
  print_info "Descargando yay desde AUR..."
  if ! timeout 120 git clone https://aur.archlinux.org/yay.git; then
    print_error "Error o timeout descargando yay desde AUR"
    cd ~ && rm -rf "$temp_dir"
    return 1
  fi

  cd yay || {
    print_error "No se pudo acceder al directorio yay"
    cd ~ && rm -rf "$temp_dir"
    return 1
  }

  print_info "Compilando yay (esto puede tomar varios minutos)..."
  print_warning "NOTA: makepkg no debe ejecutarse como root"
  
  # Verificar que no estamos como root
  if [ "$EUID" -eq 0 ]; then
    print_error "Este script no debe ejecutarse como root para instalar yay"
    print_info "Ejecuta el script como usuario normal (sin sudo)"
    cd ~ && rm -rf "$temp_dir"
    return 1
  fi

  # Compilar yay sin --noconfirm para manejar input correctamente
  # y con timeout más largo para compilación
  print_info "Iniciando compilación de yay..."
  if timeout 600 makepkg -si --needed; then
    print_success "✓ yay instalado correctamente"
    cd ~ && rm -rf "$temp_dir"
    return 0
  else
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
      print_error "✗ Timeout compilando yay (>10 minutos)"
    else
      print_error "✗ Error compilando yay"
    fi
    cd ~ && rm -rf "$temp_dir"
    return 1
  fi
}

# Instalar yay si no existe - LLAMADA MEJORADA
if ! command -v yay >/dev/null 2>&1; then
  if ! install_yay_safe; then
    print_error "No se pudo instalar yay"
    print_warning "Sin yay, se omitirán paquetes AUR"
    print_info "Puedes instalar yay manualmente más tarde:"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay && makepkg -si"
  fi
else
  print_success "✓ yay ya está instalado"
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

# Timeout también para input del usuario
read -t 30 -p "¿Instalar paquetes opcionales? (y/N) [timeout 30s]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  for package in "${OPTIONAL_PACKAGES[@]}"; do
    install_package "$package"
  done
else
  if [ -z "$REPLY" ]; then
    print_info "Timeout alcanzado, saltando paquetes opcionales"
  fi
fi

# Configurar Fish como shell por defecto
if command -v fish >/dev/null 2>&1; then
  current_shell=$(echo $SHELL)
  if [[ "$current_shell" != *"fish"* ]]; then
    print_info "¿Configurar Fish como shell por defecto?"
    read -t 15 -p "(y/N) [timeout 15s]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      chsh -s /usr/bin/fish
      print_success "✓ Fish configurado como shell por defecto"
      print_warning "⚠ Reinicia la sesión para aplicar cambios"
    elif [ -z "$REPLY" ]; then
      print_info "Timeout alcanzado, manteniendo shell actual"
    fi
  fi
fi

# Configuraciones adicionales para wal
print_info "Configurando herramientas de color para wal..."

# Verificar que python-pywal esté instalado y funcionando
if command -v wal >/dev/null 2>&1; then
  print_success "✓ pywal (wal) está disponible"

  # Crear directorio de cache para wal si no existe
  mkdir -p "$HOME/.cache/wal"
  print_success "✓ Directorio cache de wal creado"

  # Verificar si imagemagick está disponible (importante para wal)
  if command -v convert >/dev/null 2>&1; then
    print_success "✓ ImageMagick disponible para wal"
  else
    print_warning "⚠ ImageMagick no encontrado (recomendado para wal)"
  fi

  # Instalar python-colorthief con pip como respaldo si AUR falló
  print_info "Verificando colorthief para extracción de colores..."
  if ! python3 -c "import colorthief" >/dev/null 2>&1; then
    print_warning "colorthief no encontrado, instalando con pip..."
    if command -v pip >/dev/null 2>&1; then
      if pip install --user colorthief; then
        print_success "✓ colorthief instalado con pip"
      else
        print_warning "⚠ Error instalando colorthief con pip"
      fi
    else
      # Instalar pip si no está disponible
      if install_package "python-pip"; then
        if pip install --user colorthief; then
          print_success "✓ colorthief instalado con pip"
        else
          print_warning "⚠ Error instalando colorthief con pip"
        fi
      else
        print_warning "⚠ No se pudo instalar pip ni colorthief"
      fi
    fi
  else
    print_success "✓ colorthief está disponible"
  fi
else
  print_error "✗ pywal no está disponible"
  print_info "Instala con: sudo pacman -S python-pywal"
fi

# Verificar matugen (generador de colores Material You)
if command -v matugen >/dev/null 2>&1; then
  print_success "✓ matugen disponible para esquemas Material You"
else
  print_warning "⚠ matugen no encontrado (se instalará desde AUR si yay está disponible)"
fi

print_success "🎉 ¡Dependencias instaladas!"
echo

# Verificar estado final
print_info "Verificación final de dependencias principales..."
all_good=true
all_packages=("${MAIN_PACKAGES[@]}" "${HYPRLAND_PACKAGES[@]}" "${NEW_PACMAN_PACKAGES[@]}")

# Verificar paquetes críticos para wal
WAL_CRITICAL_PACKAGES=("python-pywal" "imagemagick" "python-pillow")
print_info "Verificando dependencias críticas para wal..."

for package in "${WAL_CRITICAL_PACKAGES[@]}"; do
  if command -v "$package" >/dev/null 2>&1 || pacman -Qi "$package" >/dev/null 2>&1; then
    print_success "✓ $package (crítico para wal)"
  else
    print_error "✗ $package (crítico para wal)"
    all_good=false
  fi
done

# Verificar el resto de paquetes
for package in "${all_packages[@]}"; do
  # Saltar los ya verificados arriba
  if [[ ! " ${WAL_CRITICAL_PACKAGES[@]} " =~ " ${package} " ]]; then
    if command -v "$package" >/dev/null 2>&1 || pacman -Qi "$package" >/dev/null 2>&1; then
      print_success "✓ $package"
    else
      print_error "✗ $package"
      all_good=false
    fi
  fi
done

echo
if $all_good; then
  print_success "✅ Todas las dependencias principales están listas"
  print_success "✅ Dependencias de wal verificadas y listas"
  print_info "Ahora puedes ejecutar:"
  echo "  ./install.sh"
else
  print_warning "⚠ Algunas dependencias fallaron, pero puedes continuar"
  print_info "Para reintentar solo los paquetes faltantes, consulta la lista anterior"
fi

echo
print_info "Información adicional sobre wal:"
echo "  • pywal generará esquemas de color desde tus wallpapers"
echo "  • Los archivos de configuración de wal se instalarán en ~/.config/wal"
echo "  • matugen proporcionará esquemas Material You adicionales"
echo "  • ImageMagick mejora el procesamiento de imágenes para wal"
echo
print_warning "Nota: Algunas configuraciones requieren reiniciar la sesión"