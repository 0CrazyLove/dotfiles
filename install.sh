#!/bin/bash

# Script de instalación de dotfiles
# Arch Linux + Hyprland Setup

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.configbackup$(date +%Y%m%d_%H%M%S)"
WALLPAPERS_DIR="$HOME/Documents"

print_info "Iniciando instalación de dotfiles..."

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

check_home_permissions

if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Directorio $DOTFILES_DIR no encontrado!"
  print_info "Clona primero el repositorio:"
  echo "git clone https://github.com/0CrazyLove/dotfiles.git $DOTFILES_DIR"
  exit 1
fi

# Función para inicializar submódulo shapes en quickshell config
init_shapes_submodule() {
  local quickshell_dir="$HOME/.config/quickshell"
  
  # Verificar que quickshell config exista y sea un repo git
  if [ ! -d "$quickshell_dir/.git" ]; then
    return 0
  fi

  print_info "Inicializando submódulos en quickshell..."
  cd "$quickshell_dir"
  
  if git submodule update --init --recursive; then
    print_success "✓ Submódulos de quickshell inicializados"
  fi
  
  cd ~
}

# Lista de dependencias requeridas 
DEPENDENCIES=(
  "nano"
  "fish"               
  "hyprland"             
  "kitty"               
  "neovim"             
  "git"                
  "qt5-tools"         
  "starship"             
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
  "fastfetch"
  "songrec"
)

HYPRLAND_DEPS=(
  "swww"  
  "grim"  
  "slurp"  
)

# NOTA: quickshell ya NO está aquí - se instalará con Illogical Impulse
AUR_DEPENDENCIES=(
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
)

OPTIONAL_DEPS=(
  "visual-studio-code-bin"
  "discord"
  "brave-bin"
  "mako"
  "dunst"
)

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

print_info "Verificando dependencias principales..."
missing_deps=()
missing_hyprland=()
missing_aur=()
missing_optional=()

for dep in "${DEPENDENCIES[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_deps+=("$dep")
    print_error "✗ $dep no encontrado"
  else
    print_success "✓ $dep encontrado"
  fi
done

print_info "Verificando dependencias de Hyprland..."
for dep in "${HYPRLAND_DEPS[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_hyprland+=("$dep")
    print_error "✗ $dep no encontrado"
  else
    print_success "✓ $dep encontrado"
  fi
done

print_info "Verificando dependencias AUR..."
for dep in "${AUR_DEPENDENCIES[@]}"; do
  if ! command_exists "$dep" && ! pacman -Qi "$dep" >/dev/null 2>&1; then
    missing_aur+=("$dep")
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

total_missing=$((${#missing_deps[@]} + ${#missing_hyprland[@]} + ${#missing_aur[@]}))

if [ $total_missing -ne 0 ]; then
  print_error "Faltan dependencias requeridas!"
  echo

  if [ ${#missing_deps[@]} -ne 0 ]; then
    print_info "Dependencias principales faltantes:"
    echo "sudo pacman -S ${missing_deps[*]}"
    echo
  fi

  if [ ${#missing_hyprland[@]} -ne 0 ]; then
    print_info "Dependencias de Hyprland faltantes:"
    echo "sudo pacman -S ${missing_hyprland[*]}"
    echo
  fi

  if [ ${#missing_aur[@]} -ne 0 ]; then
    print_info "Dependencias AUR faltantes:"
    echo "yay -S ${missing_aur[*]}"
    echo
  fi

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

print_info "Creando backup en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

configure_wifi_module() {
  print_info "Configurando carga automática del módulo WiFi..."

  if [ -f "/etc/modules-load.d/wifi.conf" ]; then
    print_warning "Archivo /etc/modules-load.d/wifi.conf ya existe"
    if grep -q "rtl8xxxu" /etc/modules-load.d/wifi.conf; then
      print_success "✓ Módulo rtl8xxxu ya está configurado"
      return
    fi
  fi

  if echo "rtl8xxxu" | sudo tee /etc/modules-load.d/wifi.conf >/dev/null 2>&1; then
    print_success "✓ Módulo WiFi configurado para carga automática"

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

install_rm_script() {
  print_info "Instalando script rm protector..."

  if [ ! -f "$DOTFILES_DIR/bin/rm" ]; then
    print_warning "⚠ Script rm no encontrado en $DOTFILES_DIR/bin/rm, saltando"
    return
  fi

  if [ -f "/usr/local/bin/rm" ]; then
    print_warning "Backup del rm existente"
    sudo cp /usr/local/bin/rm "$BACKUP_DIR/rm.backup"
  fi

  if sudo cp "$DOTFILES_DIR/bin/rm" "/usr/local/bin/rm"; then
    sudo chmod +x "/usr/local/bin/rm"
    print_success "✓ Script rm protector instalado en /usr/local/bin/rm"
  else
    print_error "✗ Error instalando script rm protector"
    return 1
  fi
}

install_config() {
  local source="$1"
  local target="$2"
  local name="$3"

  print_info "Instalando configuración de $name..."

  if [ ! -d "$source" ]; then
    print_warning "⚠ $source no encontrado, saltando $name"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ]; then
    print_warning "Backup de $target existente"
    mv "$target" "$BACKUP_DIR/"
  fi

  if cp -r "$source" "$target"; then
    print_success "✓ $name configurado"
  else
    print_error "✗ Error copiando $name"
    return 1
  fi
}

install_file() {
  local source="$1"
  local target="$2"
  local name="$3"

  print_info "Instalando $name..."

  if [ ! -f "$source" ]; then
    print_warning "⚠ $source no encontrado, saltando $name"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [ -f "$target" ]; then
    print_warning "Backup de $target existente"
    mv "$target" "$BACKUP_DIR/"
  fi

  if cp "$source" "$target"; then
    print_success "✓ $name configurado"
  else
    print_error "✗ Error copiando $name"
    return 1
  fi
}

mkdir -p "$HOME/.config"

print_info "Instalando configuraciones..."

install_rm_script

install_config "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish" "Fish shell"
install_config "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
install_config "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr" "Hyprland"
install_config "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty" "Kitty terminal"
install_config "$DOTFILES_DIR/.config/neofetch" "$HOME/.config/neofetch" "Neofetch"
install_config "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim"
install_config "$DOTFILES_DIR/.config/quickshell" "$HOME/.config/quickshell" "Quickshell"
install_config "$DOTFILES_DIR/.config/illogical-impulse" "$HOME/.config/illogical-impulse" "Illogical Impulse (Quickshell design)"
install_config "$DOTFILES_DIR/wal" "$HOME/.config/wal" "Wal (Color schemes)"
install_config "$DOTFILES_DIR/.config/xdg-desktop-portal" "$HOME/.config/xdg-desktop-portal" "XDG Desktop Portal (KDE)"

install_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship"

# Inicializar submódulo shapes después de copiar quickshell config
if [ -d "$HOME/.config/quickshell" ]; then
  init_shapes_submodule
fi

configure_wifi_module

if [ -d "$DOTFILES_DIR/Wallpapers" ]; then
  print_info "Instalando fondos de pantalla..."

  mkdir -p "$WALLPAPERS_DIR"

  if [ -d "$WALLPAPERS_DIR/Wallpapers" ]; then
    print_warning "Backup de fondos existentes"
    mv "$WALLPAPERS_DIR/Wallpapers" "$BACKUP_DIR/"
  fi

  if cp -r "$DOTFILES_DIR/Wallpapers" "$WALLPAPERS_DIR/"; then
    print_success "✓ Fondos de pantalla instalados en $WALLPAPERS_DIR/Wallpapers"
  else
    print_warning "⚠ Error copiando fondos de pantalla"
  fi
else
  print_warning "Carpeta Wallpapers no encontrada en $DOTFILES_DIR"
fi

if command_exists fish; then
  print_info "Configurando Fish shell..."

  if command_exists starship && [ -f "$HOME/.config/fish/config.fish" ]; then
    if ! grep -q "starship init fish" "$HOME/.config/fish/config.fish"; then
      echo "starship init fish | source" >>"$HOME/.config/fish/config.fish"
      print_success "✓ Starship añadido a Fish config"
    fi
  fi
fi

print_success "Instalación completada!"
print_info "Backup guardado en: $BACKUP_DIR"
echo

print_info "Verificando instalación..."
configs_ok=true

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
check_config "$HOME/.config/fastfetch" "Fastfetch"
check_config "$HOME/.config/hypr" "Hyprland"
check_config "$HOME/.config/kitty" "Kitty"
check_config "$HOME/.config/neofetch" "Neofetch"
check_config "$HOME/.config/nvim" "Neovim"
check_config "$HOME/.config/quickshell" "Quickshell"
check_config "$HOME/.config/illogical-impulse" "Illogical Impulse"
check_config "$HOME/.config/starship.toml" "Starship"
check_config "$HOME/.config/wal" "Wal"
check_config "$HOME/.config/xdg-desktop-portal" "XDG Desktop Portal"
check_config "/usr/local/bin/rm" "Script rm protector"

# Verificar instalación de illogical-impulse-quickshell-git
if pacman -Qi illogical-impulse-quickshell-git >/dev/null 2>&1; then
  print_success "✓ illogical-impulse-quickshell-git instalado"
else
  print_error "✗ illogical-impulse-quickshell-git no instalado"
  print_warning "Ejecuta primero: ./dependencies.sh"
  configs_ok=false
fi

echo
if $configs_ok; then
  print_success "Todas las configuraciones están en su lugar"
else
  print_warning "⚠ Algunas configuraciones pueden tener problemas"
fi

echo
print_info "Para aplicar los cambios:"
echo "  • Reinicia tu sesión o recarga Hyprland: Super+Shift+R"
echo "  • Para Fish: exec fish"
echo "  • Para Neovim: Los plugins se instalarán automáticamente"
echo "  • Para Starship: Reinicia tu terminal"
echo "  • Para Wal: Los esquemas de color están listos para usar"
echo "  • El módulo WiFi se cargará automáticamente en futuros reinicios"
echo "  • El script rm protector ya está activo en /usr/local/bin/rm"
echo
print_info "Configuraciones instaladas como archivos independientes."
print_info "Puedes eliminar el directorio ~/dotfiles si quieres."
echo
print_warning "Para actualizar en el futuro, usa: ./update.sh desde ~/dotfiles"