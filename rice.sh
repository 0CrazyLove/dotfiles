#!/bin/bash
# Master script for complete dotfiles installation
# Executes dependencies.sh followed by install.sh
# Arch Linux + Hyprland Setup

# Colors
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
print_header "║        Complete Dotfiles Installation                    ║"
print_header "║     Arch Linux + Hyprland + Illogical Impulse            ║"
print_header "╚══════════════════════════════════════════════════════════╝"
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify that scripts exist
if [ ! -f "$SCRIPT_DIR/dependencies.sh" ]; then
  print_error "dependencies.sh not found in $SCRIPT_DIR"
  exit 1
fi

if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
  print_error "install.sh not found in $SCRIPT_DIR"
  exit 1
fi

# Make scripts executable if they aren't already
chmod +x "$SCRIPT_DIR/dependencies.sh"
chmod +x "$SCRIPT_DIR/install.sh"

# Function to handle errors
handle_error() {
  local script_name="$1"
  print_error "Error executing $script_name"
  print_warning "Do you want to continue with the next step anyway?"
  read -p "Continue (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installation cancelled by user"
    exit 1
  fi
}

# ============================================================
# STEP 1: Dependencies Installation
# ============================================================
echo
print_header "═══════════════════════════════════════════════════════════"
print_header "  STEP 1/2: Installing Dependencies"
print_header "═══════════════════════════════════════════════════════════"
echo

print_info "Executing dependencies.sh..."
echo

if bash "$SCRIPT_DIR/dependencies.sh"; then
  echo
  print_success "✓ Dependencies phase completed"
else
  echo
  handle_error "dependencies.sh"
fi

# Pause between scripts
echo
print_header "═══════════════════════════════════════════════════════════"  
print_info "Press Enter to continue with dotfiles installation..."
read -r

# ============================================================
# STEP 2: Dotfiles Installation
# ============================================================
echo
print_header "═══════════════════════════════════════════════════════════"
print_header "  STEP 2/2: Installing Dotfiles and Configurations"
print_header "═══════════════════════════════════════════════════════════"
echo

print_info "Executing install.sh..."
echo

if bash "$SCRIPT_DIR/install.sh"; then
  echo
  print_success "✓ Installation phase completed"
else
  echo
  handle_error "install.sh"
fi

# ============================================================
# Completion
# ============================================================
echo
print_header "╔══════════════════════════════════════════════════════════╗"
print_header "║                 Rice Completed!                          ║"
print_header "╚══════════════════════════════════════════════════════════╝"
echo

print_success "All done, my love! (>:<)"
echo

print_info "Next steps:"
echo "  1. Reboot your system"
echo "  2. Log in by typing 'Hyprland' in the TTY"
echo "  3. Enjoy your new rice... ~Nya"
echo

# Ask if user wants to reboot now
print_info "Do you want to reboot now?"
read -p "Reboot system (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  print_info "Rebooting system..."
  systemctl reboot
else
  print_info "⚠ Don't forget to reboot later to apply all changes!"
fi