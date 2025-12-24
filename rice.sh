#!/bin/bash
# Master script for complete dotfiles installation
# Executes dependencies.sh followed by install.sh

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Printing Functions ---
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${MAGENTA}${1}${NC}"; }

# --- Clean Exit on Interrupt ---
# If you press Ctrl+C, it will exit gracefully
trap 'echo -e "\n${RED}[ERROR]${NC} Installation interrupted by user"; exit 1' INT

# Banner
clear
print_header "╔══════════════════════════════════════════════════════════╗"
print_header "║        Complete Dotfiles Installation                    ║"
print_header "║     Arch Linux + Hyprland + Illogical Impulse            ║"
print_header "╚══════════════════════════════════════════════════════════╝"
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify and define scripts
DEPS_SCRIPT="$SCRIPT_DIR/dependencies.sh"
INST_SCRIPT="$SCRIPT_DIR/install.sh"

# Basic verification
for script in "$DEPS_SCRIPT" "$INST_SCRIPT"; do
    if [ ! -f "$script" ]; then
        print_error "Critical file missing: $(basename "$script")"
        exit 1
    fi
    # Make sure they are executable
    chmod +x "$script"
done

# --- Error Handling Function ---
handle_error() {
    local script_name="$1"
    echo
    print_error "Something went wrong in: $script_name"
    read -p "Do you want to continue with the next step anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation aborted."
        exit 1
    fi
}

# --- Execution Engine ---
run_step() {
    local step_num="$1"
    local step_title="$2"
    local script_path="$3"

    print_header "═══════════════════════════════════════════════════════════"
    print_header "  STEP $step_num: $step_title"
    print_header "═══════════════════════════════════════════════════════════"
    echo
    
    print_info "Running $(basename "$script_path")..."
    
    # Execute the script and capture exit code
    "$script_path"
    local status=$?

    if [ $status -eq 0 ]; then
        print_success "Step $step_num completed successfully."
    else
        handle_error "$(basename "$script_path")"
    fi
    echo
}

# MAIN

# Step 1: Dependencies
run_step "1/2" "Installing Dependencies" "$DEPS_SCRIPT"

# User Pause
print_warning "Step 1 finished. Ready for Step 2 (Configurations)?"
read -p "Press [Enter] to continue or [Ctrl+C] to stop..."

# Step 2: Dotfiles
run_step "2/2" "Installing Dotfiles" "$INST_SCRIPT"

# COMPLETION

print_header "╔══════════════════════════════════════════════════════════╗"
print_header "║                 Rice Completed!                          ║"
print_header "╚══════════════════════════════════════════════════════════╝"
echo
print_success "All done, my love! (>:<) ~Nya"
echo

print_info "Next steps:"
echo "  1. Reboot your system."
echo "  2. Select Hyprland in your display manager (or type it in TTY)."
echo

read -p "Reboot system now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Rebooting..."
    systemctl reboot
else
    print_warning "Reboot later to ensure all services (like Waybar/Quickshell) start correctly."
fi