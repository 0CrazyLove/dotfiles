# Dotfiles - Arch Linux + Hyprland

Mi configuración personal para Arch Linux con Hyprland, basada en el excelente trabajo de [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland). Esta versión incluye configuraciones pre-configuradas y scripts automatizados para una instalación sin complicaciones.

## Características principales

- **Configuración lista para usar** - Sin necesidad de configurar manualmente cada aplicación
- **Scripts automatizados** - Instalación de dependencias y configuración en un solo comando
- **Backups automáticos** - Tus configuraciones actuales se respaldan antes de la instalación
- **Temas y wallpapers incluidos** - Wallpapers personalizados y configuraciones visuales
- **Sincronización bidireccional** - Scripts para actualizar tanto desde el repo como hacia el repo

## Aplicaciones configuradas

### Sistema base
- **Fish Shell** - Shell moderno con autocompletado inteligente
- **Starship** - Prompt cross-shell personalizable
- **Hyprland** - Compositor Wayland dinámico y eficiente
  - Hyprlock - Pantalla de bloqueo
  - Hypridle - Daemon de inactividad
  - Hyprpicker - Selector de colores
- **Kitty** - Terminal acelerado por GPU
- **Neovim** - Editor con configuración LazyVim

### Herramientas y utilidades
- **SWWW** - Daemon de wallpapers para Wayland
- **Grim + Slurp** - Capturas de pantalla
- **Cliphist** - Gestor de portapapeles
- **Fuzzel** - Lanzador de aplicaciones
- **Neofetch** - Información del sistema
- **Pywal** - Generador de esquemas de color
- **QuickShell** - Shell personalizado para Qt Quick

### Configuraciones adicionales
- **Illogical Impulse** - Configuraciones de tema adicionales
- **Material You Colors** - Paletas de colores dinámicas
- **Fonts** - JetBrains Mono Nerd, Space Grotesk, y más

## Dependencias

### Automáticamente instaladas
El script `dependencies.sh` instala automáticamente:
- **Paquetes oficiales**: +40 paquetes esenciales
- **Paquetes AUR**: +25 paquetes adicionales (requiere yay)
- **Opcional**: VS Code, Discord, Spotify, Brave Browser

### Requisitos previos
- **Arch Linux** o distribución basada en Arch
- **Conexión a internet** para descargar dependencias
- **Usuario con privilegios sudo**

## Instalación rápida

### 1. Clonar el repositorio
```bash
git clone https://github.com/0CrazyLove/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Instalar dependencias (recomendado)
```bash
chmod +x dependencies.sh
./dependencies.sh
```
Este script:
- Verifica y corrige permisos del sistema
- Instala yay (AUR helper) si no está presente
- Instala todas las dependencias necesarias
- Ofrece paquetes opcionales

### 3. Aplicar configuraciones
```bash
chmod +x install.sh
./install.sh
```
Este script:
- Crea backups de configuraciones existentes
- Copia todas las configuraciones a `~/.config/`
- Instala wallpapers en `~/Documents/Wallpapers/`
- Aplica permisos correctos

## Gestión de configuraciones

### Actualizar desde el repositorio
```bash
cd ~/dotfiles
git pull
./install.sh
```

### Sincronizar cambios locales al repositorio
```bash
cd ~/dotfiles
./update.sh
```
Este script:
- Copia configuraciones actuales del sistema al repo
- Muestra estado de git
- Permite hacer commit automático
- Opción de push a GitHub

## Estructura del proyecto

```
dotfiles/
├── .config/                    # Configuraciones principales
│   ├── fish/                   # Fish shell
│   ├── hypr/                   # Hyprland ecosystem
│   │   ├── custom/             # Configuraciones personalizadas
│   │   ├── hyprland/           # Scripts y configs de Hyprland
│   │   ├── hyprlock/           # Pantalla de bloqueo
│   │   ├── scripts/            # Scripts utilitarios
│   │   └── shaders/            # Shaders personalizados
│   ├── illogical-impulse/      # Configuraciones de tema adicionales
│   ├── kitty/                  # Terminal Kitty
│   ├── neofetch/               # System info display
│   ├── nvim/                   # Neovim (LazyVim setup)
│   ├── quickshell/             # Shell Qt Quick personalizado
│   └── starship.toml           # Configuración del prompt
├── Wallpapers/                 # Wallpapers personalizados
├── dependencies.sh            # Script de instalación de dependencias
├── install.sh                 # Script de instalación principal
└── update.sh                  # Script de sincronización
```

## Diferencias con el dotfile original

Este dotfile está basado en [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) pero incluye:

- **Configuraciones pre-establecidas** - No necesitas configurar manualmente
- **Scripts automatizados** - Instalación y actualización automática
- **Wallpapers incluidos** - Colección de fondos personalizados
- **Dependencias completas** - Script que instala todo lo necesario
- **Manejo robusto de errores** - Verificación de permisos y reintentos
- **Sistema de backups** - Protege tus configuraciones existentes

## Solución de problemas

### Problemas comunes

**Error de permisos:**
```bash
# Los scripts verifican y corrigen automáticamente
sudo chown -R $USER:$USER $HOME
chmod 755 $HOME
```

**Dependencias faltantes:**
```bash
# Reejecutar el script de dependencias
./dependencies.sh
```

**Hyprland no inicia:**
```bash
# Verificar instalación de Hyprland
pacman -Qi hyprland
# Verificar logs
journalctl -u hyprland --no-pager
```

**Fish no es el shell por defecto:**
```bash
chsh -s /usr/bin/fish
# Reiniciar sesión
```

### Reinstalación limpia
```bash
# Restaurar backup si algo sale mal
cp -r ~/.config_backup_FECHA/* ~/.config/
```

## Personalización

### Cambiar wallpapers
```bash
# Los wallpapers están en:
~/Documents/Wallpapers/
# Usa el script personalizado:
~/.config/hypr/scripts/cambiar-fondo-completo.sh
```

### Modificar configuraciones
1. Edita archivos en `~/.config/`
2. Sincroniza cambios: `./update.sh`
3. Haz commit de cambios al repositorio

## Créditos

Este proyecto está basado en el increíble trabajo de:
- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)** - Dotfile base y configuraciones principales
- **Comunidad Hyprland** - Por el excelente compositor y documentación
- **Arch Linux** - Por la flexibilidad y control del sistema

## Licencia

Este proyecto sigue la misma filosofía open-source del proyecto original. Siéntete libre de usar, modificar y compartir.

## Contribuciones

¿Encontraste algún bug o tienes una mejora? ¡Las contribuciones son bienvenidas!

1. Fork del proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit de cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

**Tip:** Para mejores resultados, ejecuta `dependencies.sh` antes de `install.sh` en una instalación limpia de Arch Linux.
