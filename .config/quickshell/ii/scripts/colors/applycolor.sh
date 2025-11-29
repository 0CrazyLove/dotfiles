#!/usr/bin/env bash
QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=100 # Set this to < 100 make all your terminals transparent

if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi

cd "$CONFIG_DIR" || exit

apply_term() {
  # Check if pywal colors exist
  if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
    echo "Pywal colors not found. Skipping terminal theming."
    return
  fi
  
  # Source pywal colors
  source "$HOME/.cache/wal/colors.sh"
  
  # Create directory for terminal sequences
  mkdir -p "$STATE_DIR"/user/generated/terminal
  
  # Generate terminal escape sequences from pywal colors
  # Use printf to properly generate escape sequences with \033 (ESC character)
  {
    printf '\033]4;0;%s\033\\' "${color0}"
    printf '\033]4;1;%s\033\\' "${color1}"
    printf '\033]4;2;%s\033\\' "${color2}"
    printf '\033]4;3;%s\033\\' "${color3}"
    printf '\033]4;4;%s\033\\' "${color4}"
    printf '\033]4;5;%s\033\\' "${color5}"
    printf '\033]4;6;%s\033\\' "${color6}"
    printf '\033]4;7;%s\033\\' "${color7}"
    printf '\033]4;8;%s\033\\' "${color8}"
    printf '\033]4;9;%s\033\\' "${color9}"
    printf '\033]4;10;%s\033\\' "${color10}"
    printf '\033]4;11;%s\033\\' "${color11}"
    printf '\033]4;12;%s\033\\' "${color12}"
    printf '\033]4;13;%s\033\\' "${color13}"
    printf '\033]4;14;%s\033\\' "${color14}"
    printf '\033]4;15;%s\033\\' "${color15}"
    printf '\033]10;%s\033\\' "${foreground}"
    printf '\033]11;%s\033\\' "${background}"
    printf '\033]12;%s\033\\' "${cursor}"
    printf '\033]708;%s\033\\' "${background}"
  } > "$STATE_DIR"/user/generated/terminal/sequences.txt

  # Apply alpha transparency if needed
  if [ "$term_alpha" -lt 100 ]; then
    # Convert alpha percentage to hex (00-FF)
    alpha_hex=$(printf '%02x' $((term_alpha * 255 / 100)))
    # Add alpha to background color
    bg_with_alpha="${background}${alpha_hex}"
    printf '\033]11;%s\033\\' "${bg_with_alpha}" >> "$STATE_DIR"/user/generated/terminal/sequences.txt
  fi
  
  # Apply colors to all active terminal sessions
  for file in /dev/pts/*; do
    if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
      {
        cat "$STATE_DIR"/user/generated/terminal/sequences.txt > "$file"
      } & disown || true
    fi
  done
}

apply_qt() {
  # Qt theming is handled by pywal and kde-material-you-colors
  # If you still want to use custom Qt theming, uncomment these:
  # sh "$CONFIG_DIR/scripts/kvantum/materialQT.sh"
  # python "$CONFIG_DIR/scripts/kvantum/changeAdwColors.py"
  :
}

# Check if terminal theming is enabled in config
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
if [ -f "$CONFIG_FILE" ]; then
  enable_terminal=$(jq -r '.appearance.wallpaperTheming.enableTerminal' "$CONFIG_FILE")
  if [ "$enable_terminal" = "true" ]; then
    apply_term &
  fi
else
  echo "Config file not found at $CONFIG_FILE. Applying terminal theming by default."
  apply_term &
fi

# apply_qt & # Qt theming is already handled by kde-material-you-colors