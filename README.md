# Dotfiles - Arch Linux + Hyprland

Mi configuración personal para Arch Linux con Hyprland.

## Configuraciones incluidas

- **fish** - Shell
- **hypr** - Hyprland window manager  
- **kitty** - Terminal
- **neofetch** - System info
- **nvim** - Neovim (LazyVim)
- **quickshell** - Shell personalizado
- **FondosPantallas** - Wallpapers

## Instalación

```bash
git clone https://github.com/0CrazyLove/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

El script crea backups automáticos de configuraciones existentes.

## Actualizar

Para sincronizar cambios del sistema al repo:

```bash
cd ~/dotfiles
./update.sh
```

Para obtener actualizaciones del repo:

```bash
cd ~/dotfiles
git pull
./install.sh
```

## Estructura

```
.config/
├── fish/
├── hypr/
├── kitty/
├── neofetch/
├── nvim/
└── quickshell/
FondosPantallas/
install.sh
update.sh
```

## Notas

- Las configuraciones usan symlinks para mantenerse sincronizadas
- Los wallpapers se copian a `~/Documents/FondosPantallas/`
- Los backups se guardan en `~/.config_backup_FECHA/`
