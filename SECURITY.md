## Detailed Installation

### 1. Clone the repository
```bash
git clone https://github.com/0CrazyLove/dotfiles.git
cd ~/dotfiles
```

### 2. Master installation script (Recommended)
```bash
./rice.sh
```
This script:
- Executes the complete installation process
- Runs dependencies.sh followed by install.sh
- Handles errors and allows continuation
- Provides a unified installation experience

### 3. Dependencies installation script (Manual)
```bash
./dependencies.sh
```
This script:
- Verifies and fixes system permissions
- Installs yay (AUR helper) if not present
- Installs all necessary dependencies
- Offers optional packages

### 4. Main installation script (Manual)
```bash
./install.sh
```
This script:
- Creates backups of existing configurations
- Copies all configurations to `~/.config/`
- Installs wallpapers in `~/Documents/walls/`
- Applies correct permissions

## Configured Applications

### Base System
- **Fish Shell** - Modern shell with intelligent autocompletion
- **Starship** - Customizable cross-shell prompt
- **Hyprland** - Dynamic and efficient Wayland compositor
- **Kitty** - GPU-accelerated terminal
- **Matugen** - Color selector for Qt Quick

### Tools and Utilities
- **Grim + Slurp** - Screenshots
- **Cliphist** - Clipboard manager
- **Fuzzel** - Application launcher
- **Fastfetch** - System information
- **Pywal** - Color scheme generator
- **QuickShell** - Custom shell for Qt Quick

### Additional Configurations
- **Illogical Impulse** - Additional theme configurations
- **Fonts** - JetBrains Mono Nerd, Space Grotesk, and more

## Hardware Requirements

### Minimum
- CPU: 4 cores
- RAM: 4GB
- GPU: Wayland support
- Storage: 5GB

### Recommended
- CPU: 8+ cores  
- RAM: 16GB
- GPU: AMD Vega / NVIDIA GTX 1060+
- Storage: 20GB

### Core Components
- Hyprland: ~200MB RAM
- Fish + Kitty: ~70MB RAM
- QuickShell: ~200MB RAM

## Keyboard Shortcuts
This configuration includes a wide range of keyboard shortcuts optimized for an efficient workflow. All main shortcuts use the **Super** (Windows/Cmd) key as the primary modifier.

### Workspace Management
| Shortcut | Action |
|----------|--------|
| `Super + 1-9` | Switch to specified workspace |
| `Super + Shift + 1-9` | Move active window to specified workspace |

### Window Management
| Shortcut | Action |
|----------|--------|
| `Super + Q` | Close active window |
| `Super + L` | Lock screen |
| `Super + J` | Hide/show QuickShell bar |
| `Super + F` | Put window in fullscreen |
| `Super + Alt + F` | Fake fullscreen (simulation) |

### Quick Applications
| Shortcut | Action |
|----------|--------|
| `Super + T` | Open terminal |
| `Super + Enter` | Open terminal (alternative) |
| `Super + W` | Open default browser |
| `Super + E` | Open file explorer (Dolphin) |
| `Super + C` | Open code editor (VS Code) |
| `Super + N` | Open system menu |

### AI Assistant
| Shortcut | Action |
|----------|--------|
| `Super + O` | Open AI assistant |
| `Super + A` | Open AI assistant (alternative) |
| `Super + B` | Open AI assistant (alternative) |

### Screenshots and Multimedia
| Shortcut | Action |
|----------|--------|
| `Super + Shift + S` | Interactive screenshot |
| `Super + Shift + T` | OCR: Screen text recognition |
| `Super + Shift + A` | Visual search with Google Lens |
| `Super + Alt + R` | Record MP4 video in selected region (no audio) |
| `Ctrl + Alt + R` | Record MP4 video fullscreen (no audio) |
| `Super + Shift + Alt + R` | Record MP4 video fullscreen (with audio) |
| `Ctrl + Super + T` | Manually select wallpaper |

### Audio and Media Control
| Shortcut | Action |
|----------|--------|
| `Super + Shift + M`| Mute/unmute system audio and microphone |
| `Super + Space` | Switch keyboard layout (US ⇄ Latin America) |
| `Super + Shift + N` | Next song |
| `Super + Shift + B` | Previous song |
| `Super + Shift + P` | Play/Pause |
| `Ctrl + Super + V` | Volume mixer |

### Zoom and Navigation
| Shortcut | Action |
|----------|--------|
| `Super + +` | Zoom in where mouse points |
| `Super + -` | Zoom out |

### Clipboard and Tools
| Shortcut | Action |
|----------|--------|
| `Super + V` | Open clipboard history |
| `Super + ;` | Open clipboard history (alternative) |
| `Super + .` | Emoji selector |
| `Super + K` | Show active keyboard layout |

### System and Tools
| Shortcut | Action |
|----------|--------|
| `Super + I` | Open QuickShell configuration interface |
| `Ctrl + Super + R` | Restart QuickShell |
| `Ctrl + Shift + Esc` | Task manager |

### Usage Tips
- **OCR (Text Recognition)**: When pressing `Super + Shift + T`, you can select any screen area and extract the text it contains. The recognized text is automatically copied to the clipboard. Ideal for copying text from images, PDFs, videos, or any content that cannot be selected normally.
- **Visual Search**: With `Super + Shift + A`, select a screen region and it will open Google Lens to search for the selected image content.
- **Mute Control**: When using `Super + Shift + M`, both system audio and microphone are muted simultaneously. The status is visually reflected in the QuickShell bar.
- **Clipboard History**: When using `Super + V`, a menu displays everything you've copied. Select the desired item and use it with `Ctrl + V`.
- **Emoji Selector**: With `Super + .` an emoji menu appears. Select one and paste it with `Ctrl + V`.
- **Media Control**: The shortcuts `Super + Shift + N/B/P` are optimized for Spotify and work specifically with this application.
- **Fullscreen vs Fake Fullscreen**: `Super + F` activates real fullscreen, while `Super + Alt + F` simulates the behavior for apps that require it.
- **Dynamic Workspaces**: Workspaces are created automatically when you need them.
- **Smart Zoom**: Zoom follows mouse position for greater precision.
- **Video Recording**: Videos are saved in `~/Videos/`. To stop recording, execute the same command a second time.

## AI Assistant Configuration

### Activate the assistant
You can access the AI assistant in two ways:
- Using shortcuts: `Super + O`, `Super + A`, or `Super + B`
- Right-click on the top left of the bar

### Configure API key
1. Get your Google API key: https://aistudio.google.com/app/apikey
2. In the "Intelligence" section of the assistant, type:
   ```
   /key YOUR_GOOGLE_API_KEY
   ```

## Customization

### Change Wallpapers
```bash
# Wallpapers are located in:
~/Documents/walls/
```

### Modify Configurations
1. Edit files in `~/.config/`
2. Sync changes: `./update.sh`
3. Commit changes to your remote repo

## Dependencies

### Automatically Installed
The `dependencies.sh` script automatically installs:
- **Official packages**: 40+ essential packages
- **AUR packages**: 25+ additional packages (requires yay)

### Prerequisites
- **Arch Linux** or Arch-based distribution
- **Internet connection** to download dependencies
- **User with sudo privileges**

## Project Structure

```
dotfiles/
├── .config/                    # Main configurations
│   ├── fish/                   # Fish shell
│   ├── hypr/                   # Hyprland ecosystem
│   │   ├── custom/             # Custom configurations
│   │   ├── hyprland/           # Hyprland scripts and configs
│   │   ├── hyprlock/           # Lock screen
│   │   ├── scripts/            # Utility scripts
│   │   └── shaders/            # Custom shaders
│   ├── illogical-impulse/      # Additional theme configurations
│   ├── kitty/                  # Kitty terminal
│   ├── matugen/                # Color scheme generator
│   ├── quickshell/             # Custom Qt Quick shell
│   └── starship.toml           # Prompt configuration
├── .local/                     # Local user data
├── bin/                        # Custom scripts
│   └── rm                      # Protective rm script
├── wal/                        # Pywal color schemes
├── walls/                      # Custom wallpapers
├── dependencies.sh             # Dependencies installation script
├── install.sh                  # Main installation script
├── rice.sh                     # Master installation script
└── update.sh                   # Synchronization script
```

## Configuration Management

### Update from Repository
```bash
cd ~/dotfiles
git pull
./install.sh
```

### Sync Local Changes to Repository
```bash
cd ~/dotfiles
./update.sh
```
This script:
- Copies current system configurations to repo
- Shows git status
- Allows automatic commit
- Option to push to your remote repo

## Troubleshooting

### Common Issues

**Permission errors:**
```bash
# Scripts automatically verify and fix
sudo chown -R $USER:$USER $HOME
chmod 755 $HOME
```

**Locked Pacman (Database lock):**
```bash
# Error: "failed to init transaction (unable to lock database)"
# Verify there are no active pacman processes:
ps aux | grep pacman

# If no active processes, remove lock file:
sudo rm /var/lib/pacman/db.lck

# Then retry dependencies installation:
./dependencies.sh
```
This error is very common when pacman is interrupted with Ctrl+C or the system shuts down during installation.

**Missing dependencies:**
```bash
# Re-run dependencies script
./dependencies.sh
```

**Hyprland won't start:**
```bash
# Verify Hyprland installation
pacman -Qi hyprland
# Check logs
journalctl -u hyprland --no-pager
```

**Fish is not the default shell:**
```bash
chsh -s /usr/bin/fish
# Restart session
```

### Clean Reinstallation
```bash
# Restore backup if something goes wrong
cp -r ~/.config_backup_DATE/* ~/.config/
```