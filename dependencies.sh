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
print_info "Instalando dependencias para dotfiles..."
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
  if [ ! -f /etc/pacman.d/gnupg/trustdb.gpg ]; then
    print_info "Inicializando keyring de pacman..."
    sudo pacman-key --init
  fi
  print_info "Actualizando claves de Arch Linux..."
  sudo pacman-key --populate archlinux
  print_info "Actualizando claves desde servidores..."
  if timeout 60 sudo pacman-key --refresh-keys; then
    print_success "✓ Claves PGP actualizadas"
  else
    print_warning "⚠ Timeout o error actualizando claves PGP, continuando..."
  fi
}
# AUR helper (yay)
install_yay_optional() {
  if ! command -v yay >/dev/null 2>&1; then
    print_info "¿Instalar yay (AUR helper)?"
    print_warning "Requerido para algunas dependencias adicionales"
    read -p "Recomendado para algunos paquetes adicionales (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_info "Instalando yay..."
      
      local yay_deps=("git" "base-devel")
      for dep in "${yay_deps[@]}"; do
        if ! is_package_installed "$dep"; then
          print_info "Instalando dependencia: $dep"
          sudo pacman -S --noconfirm "$dep"
        fi
      done
      
      cd /tmp
      git clone https://aur.archlinux.org/yay.git
      cd yay
      makepkg -si --noconfirm
      cd ~
      rm -rf /tmp/yay
      print_success "✓ yay instalado"
      return 0
    else
      print_warning "Sin yay, se omitirán paquetes AUR"
      return 1
    fi
  else
    print_success "✓ yay ya está instalado"
    return 0
  fi
}
check_home_permissions
fix_pgp_keys
print_info "Actualizando sistema..."
sudo pacman -Syu --noconfirm
# Dependencias principales
MAIN_PACKAGES=(
  "base-devel"         
  "fish"                
  "starship"            
  "hyprland"             
  "kitty"               
  "neovim"              
  "git"                 
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
)

AUR_PACKAGES=(
  "neofetch"               
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
  "mako"
  "dunst"
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
    print_success "✓ $package ya está instalado"
    return 0
  fi
  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package... (intento $((retry + 1)))"
    
    if timeout 180 sudo pacman -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error instalando $package (intento $((retry + 1)))"
      
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout instalando $package"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Reintentando en $i segundos..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Reintentando ahora...                    "
        
        sudo pacman -Sc --noconfirm
      fi
    fi
  done
  print_error "✗ No se pudo instalar $package después de $max_retries intentos"
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
    print_success "✓ $package ya está instalado"
    return 0
  fi
  while [ $retry -lt $max_retries ]; do
    print_info "Instalando $package desde AUR... (intento $((retry + 1)))"
    
    if timeout 300 yay -S --noconfirm "$package"; then
      print_success "✓ $package instalado correctamente desde AUR"
      return 0
    else
      local exit_code=$?
      print_warning "⚠ Error instalando $package desde AUR (intento $((retry + 1)))"
      
      if [ $exit_code -eq 124 ]; then
        print_error "✗ Timeout instalando $package desde AUR"
        return 1
      fi
      
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        print_info "Esperando 5 segundos antes del siguiente intento..."
        
        for i in {5..1}; do
          echo -ne "\r${BLUE}[INFO]${NC} Reintentando en $i segundos..."
          sleep 1
        done
        echo -e "\r${BLUE}[INFO]${NC} Reintentando ahora...                    "
        
        yay -Sc --noconfirm
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
print_info "Instalando paquetes de Hyprland..."
for package in "${HYPRLAND_PACKAGES[@]}"; do
  if ! install_package "$package"; then
    failed_packages+=("$package")
  fi
done
print_info "Instalando nuevas dependencias con pacman..."
for package in "${NEW_PACMAN_PACKAGES[@]}"; do
  if [[ ! " ${MAIN_PACKAGES[@]} " =~ " ${package} " ]] && [[ ! " ${HYPRLAND_PACKAGES[@]} " =~ " ${package} " ]]; then
    if ! install_package "$package"; then
      failed_packages+=("$package")
    fi
  else
    if is_package_installed "$package"; then
      print_success "✓ $package ya está instalado (saltando duplicado)"
    else
      print_info "Saltando $package (ya incluido en otra lista)"
    fi
  fi
done
yay_installed=false
if install_yay_optional; then
  yay_installed=true
fi
if $yay_installed || command -v yay >/dev/null 2>&1; then
  print_info "Instalando dependencias desde AUR..."
  failed_aur_packages=()
  for package in "${AUR_PACKAGES[@]}"; do
    if ! install_aur_package "$package"; then
      failed_aur_packages+=("$package")
    fi
  done
  failed_packages+=("${failed_aur_packages[@]}")
else
  print_warning "⚠ yay no está disponible, saltando paquetes AUR"
  print_info "Paquetes AUR que se omitieron:"
  for package in "${AUR_PACKAGES[@]}"; do
    echo "  • $package"
  done
  echo
fi
if [ ${#failed_packages[@]} -ne 0 ]; then
  print_warning "Paquetes que no se pudieron instalar:"
  for package in "${failed_packages[@]}"; do
    echo "  • $package"
  done
  echo
  print_info "Puedes intentar instalarlos manualmente más tarde:"
  echo "Pacman: sudo pacman -S [paquete]"
  if command -v yay >/dev/null 2>&1; then
    echo "AUR: yay -S [paquete]"
  fi
  echo
fi
if command -v yay >/dev/null 2>&1; then
  echo
  print_info "Paquetes opcionales disponibles:"
  for package in "${OPTIONAL_PACKAGES[@]}"; do
    echo "  • $package"
  done
  read -t 30 -p "¿Instalar paquetes opcionales? (y/N) [timeout 30s]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for package in "${OPTIONAL_PACKAGES[@]}"; do
      install_aur_package "$package"
    done
  else
    if [ -z "$REPLY" ]; then
      print_info "Timeout alcanzado, saltando paquetes opcionales"
    fi
  fi
else
  print_info "Paquetes opcionales omitidos (requieren yay)"
fi
print_info "Configurando herramientas de color para wal..."
if command -v wal >/dev/null 2>&1; then
  print_success "✓ pywal (wal) está disponible"
  mkdir -p "$HOME/.cache/wal"
  print_success "✓ Directorio cache de wal creado"
  if command -v convert >/dev/null 2>&1; then
    print_success "✓ ImageMagick disponible para wal"
  else
    print_warning "⚠ ImageMagick no encontrado (recomendado para wal)"
  fi
  print_info "Verificando colorthief para extracción de colores..."
  if ! python3 -c "import colorthief" >/dev/null 2>&1; then
    print_warning "colorthief no encontrado, instalando con pip..."
    if command -v pip3 >/dev/null 2>&1; then
      if pip3 install --user colorthief; then
        print_success "✓ colorthief instalado con pip3"
      else
        print_warning "⚠ Error instalando colorthief con pip3"
      fi
    else
      print_warning "⚠ pip3 no está disponible"
    fi
  else
    print_success "✓ colorthief está disponible"
  fi
else
  print_error "✗ pywal no está disponible"
  print_info "Instala con: sudo pacman -S python-pywal"
fi
if command -v matugen >/dev/null 2>&1; then
  print_success "✓ matugen disponible para esquemas Material You"
else
  print_warning "⚠ matugen no encontrado (se instalará desde AUR si yay está disponible)"
fi
if command -v fastfetch >/dev/null 2>&1; then
  print_success "✓ fastfetch disponible"
else
  print_warning "⚠ fastfetch no encontrado (se instalará desde AUR si yay está disponible)"
fi
print_success "¡Dependencias instaladas!"
print_warning "NOTA: Quickshell se instalará con Illogical Impulse durante install.sh"
echo
print_info "Verificación final de dependencias principales..."
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
print_info "Verificando dependencias críticas para wal..."
WAL_CRITICAL=("python-pywal" "imagemagick" "python-pillow")
for package in "${WAL_CRITICAL[@]}"; do
  if [[ -n "${PACKAGE_TO_COMMAND[$package]}" ]]; then
    if eval "${PACKAGE_TO_COMMAND[$package]}" --version >/dev/null 2>&1 || eval "${PACKAGE_TO_COMMAND[$package]}" >/dev/null 2>&1; then
      print_success "✓ $package (crítico para wal)"
    elif is_package_installed "$package"; then
      print_success "✓ $package instalado (crítico para wal)"
    else
      print_error "✗ $package (crítico para wal)"
      all_good=false
    fi
  else
    if is_package_installed "$package"; then
      print_success "✓ $package (crítico para wal)"
    else
      print_error "✗ $package (crítico para wal)"
      all_good=false
    fi
  fi
done
print_info "Verificando otras dependencias..."
for package in "${all_packages[@]}"; do
  if [[ ! " ${WAL_CRITICAL[@]} " =~ " ${package} " ]]; then
    if [[ -n "${PACKAGE_TO_COMMAND[$package]}" ]]; then
      if eval "${PACKAGE_TO_COMMAND[$package]}" --version >/dev/null 2>&1 || eval "${PACKAGE_TO_COMMAND[$package]}" >/dev/null 2>&1; then
        print_success "✓ $package"
      elif is_package_installed "$package"; then
        print_success "✓ $package instalado"
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
  print_success "Todas las dependencias principales están listas UwU"
  print_info "Ahora puedes ejecutar:"
  echo "  ./install.sh"
else
  print_warning "⚠ Algunas dependencias fallaron, pero puedes continuar"
  print_info "Para reintentar solo los paquetes faltantes, consulta la lista anterior"
fi

echo
if command -v yay >/dev/null 2>&1; then
  echo "  • matugen proporcionará esquemas Material You adicionales"
else
  echo "  • matugen NO disponible (requiere yay para instalación desde AUR)"
fi

echo "  • ImageMagick mejora el procesamiento de imágenes para wal"
echo

print_warning "Nota: Algunas configuraciones requieren reiniciar la sesión"
