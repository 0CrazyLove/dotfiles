
## Instalación detallada

### Script de dependencias
```bash
chmod +x dependencies.sh
./dependencies.sh
```
Este script:
- Verifica y corrige permisos del sistema
- Instala yay (AUR helper) si no está presente
- Instala todas las dependencias necesarias
- Ofrece paquetes opcionales

### Script de instalación principal
```bash
chmod +x install.sh
./install.sh
```
Este script:
- Crea backups de configuraciones existentes
- Copia todas las configuraciones a `~/.config/`
- Instala wallpapers en `~/Documents/Wallpapers/`
- Aplica permisos correctos


## Aplicaciones configuradas

### Sistema base
- **Fish Shell** - Shell moderno con autocompletado inteligente
- **Starship** - Prompt cross-shell personalizable
- **Hyprland** - Compositor Wayland dinámico y eficiente
- **Hyprlock** - Pantalla de bloqueo
- **Hypridle** - Daemon de inactividad
- **Hyprpicker** - Selector de colores
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

## Requisitos de Hardware

### Mínimos
- CPU: 4 cores
- RAM: 4GB
- GPU: Soporte Wayland
- Storage: 5GB

### Recomendados
- CPU: 8+ cores  
- RAM: 16GB
- GPU: AMD Vega / NVIDIA GTX 1060+
- Storage: 20GB

### Componentes Core
- Hyprland: ~200MB RAM
- Fish + Kitty: ~70MB RAM
- Neovim: ~150MB RAM
- QuickShell: ~200MB RAM

## Atajos de teclado

Esta configuración incluye una amplia gama de atajos de teclado optimizados para un flujo de trabajo eficiente. Todos los atajos principales usan la tecla **Super** (Windows/Cmd) como modificador principal.

### Gestión de workspaces

| Atajo | Acción |
|-------|---------|
| `Super + 1-9` | Cambiar al workspace especificado |
| `Super + Shift + 1-9` | Mover ventana activa al workspace especificado |

### Gestión de ventanas

| Atajo | Acción |
|-------|---------|
| `Super + Q` | Cerrar ventana activa |
| `Super + L` | Bloquear pantalla |
| `Super + J` | Ocultar/mostrar la barra de QuickShell |
| `Super + F` | Poner ventana en pantalla completa |
| `Super + Alt + F` | Falso fullscreen (simulación) |

### Aplicaciones rápidas

| Atajo | Acción |
|-------|---------|
| `Super + T` | Abrir terminal |
| `Super + Enter` | Abrir terminal (alternativo) |
| `Super + W` | Abrir navegador predeterminado |
| `Super + E` | Abrir explorador de archivos (Dolphin) |
| `Super + C` | Abrir editor de código (VS Code) |
| `Super + N` | Abrir menú del sistema |

### Asistente de IA

| Atajo | Acción |
|-------|---------|
| `Super + O` | Abrir asistente de IA |
| `Super + A` | Abrir asistente de IA (alternativo) |
| `Super + B` | Abrir asistente de IA (alternativo) |

### Capturas y multimedia

| Atajo | Acción |
|-------|---------|
| `Super + Shift + S` | Captura de pantalla interactiva |
| `Super + P` | Cambiar fondo de pantalla automáticamente |

### Control de media

| Atajo | Acción |
|-------|---------|
| `Super + Shift + N` | Siguiente canción |
| `Super + Shift + B` | Canción anterior |
| `Super + Shift + P` | Play/Pause |

### Zoom y navegación

| Atajo | Acción |
|-------|---------|
| `Super + +` | Hacer zoom donde apunta el mouse |
| `Super + -` | Disminuir zoom |

### Portapapeles y herramientas

| Atajo | Acción |
|-------|---------|
| `Super + V` | Abrir historial del portapapeles |
| `Super + ;` | Abrir historial del portapapeles (alternativo) |
| `Super + .` | Selector de emojis |
| `Super + K` | Activar/desactivar teclado en pantalla |

### Sistema y herramientas

| Atajo | Acción |
|-------|---------|
| `Ctrl + Super + V` | Mezclador de volumen |
| `Ctrl + Shift + Esc` | Administrador de tareas |

### Consejos de uso

- **Historial de portapapeles**: Al usar `Super + V`, se despliega un menú con todo lo que has copiado. Selecciona el elemento deseado y úsalo con `Ctrl + V`
- **Selector de emojis**: Con `Super + .` aparece un menú de emojis. Selecciona uno y pégalo con `Ctrl + V`
- **Teclado en pantalla**: `Super + K` activa/desactiva el teclado virtual, útil para dispositivos táctiles o cuando necesitas un teclado en pantalla
- **Control de media**: Los atajos `Super + Shift + N/B/P` están optimizados para Spotify y funcionan específicamente con esta aplicación
- **Pantalla completa vs Falso fullscreen**: `Super + F` activa fullscreen real, mientras que `Super + Alt + F` simula el comportamiento para apps que lo requieren
- **Workspaces dinámicos**: Los workspaces se crean automáticamente cuando los necesitas
- **Zoom inteligente**: El zoom sigue la posición del mouse para mayor precisión

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
├── bin/                        # Scripts personalizados
│   └── rm                      # Script rm protector
├── Wallpapers/                 # Wallpapers personalizados
├── dependencies.sh            # Script de instalación de dependencias
├── install.sh                 # Script de instalación principal
└── update.sh                  # Script de sincronización
```

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

## Solución de problemas

### Problemas comunes

**Error de permisos:**
```bash
# Los scripts verifican y corrigen automáticamente
sudo chown -R $USER:$USER $HOME
chmod 755 $HOME
```

**Pacman bloqueado (Database lock):**
```bash
# Error: "failed to init transaction (unable to lock database)"
# Verificar que no hay procesos pacman activos:
ps aux | grep pacman

# Si no hay procesos activos, eliminar el archivo de bloqueo:
sudo rm /var/lib/pacman/db.lck

# Luego reintentar la instalación de las dependencias:
./dependencies.sh
```
Este error es muy común cuando pacman se interrumpe con Ctrl+C o el sistema se apaga durante una instalación

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

## Scripts incluidos

### dependencies.sh
Script que maneja la instalación automática de todas las dependencias:
- Verifica permisos del sistema
- Instala yay si no está presente
- Maneja paquetes oficiales y AUR
- Ofrece paquetes opcionales
- Incluye manejo robusto de errores

### install.sh
Script principal de instalación de configuraciones:
- Crea backups automáticos con timestamp
- Copia configuraciones preservando estructura
- Maneja permisos correctamente
- Instala wallpapers y recursos

### update.sh
Script de sincronización bidireccional:
- Copia cambios del sistema al repositorio
- Muestra estado actual de git
- Facilita commits y push automáticos
- Mantiene sincronización con repositorio remoto

### Scripts personalizados en bin/
- **rm**: Script protector que previene borrado accidental de archivos importantes

## Configuraciones específicas

### Fish Shell
- Configuración moderna con autocompletado
- Integración con Starship prompt
- Alias personalizados
- Funciones utilitarias

### Hyprland
- Configuración optimizada para rendimiento
- Atajos de teclado personalizados
- Reglas de ventanas específicas
- Integración con SWWW para wallpapers

### Kitty Terminal
- Configuración acelerada por GPU
- Tema personalizado
- Integración con esquema de colores del sistema

### Neovim
- Setup LazyVim preconfigurado
- Plugins esenciales incluidos
- Configuración LSP lista para usar

## Configuración post-instalación

### Establecer Fish como shell predeterminado
```bash
chsh -s /usr/bin/fish
```

### Configurar Hyprland en el gestor de sesiones
```bash
# Para SDDM o GDM, Hyprland debería aparecer automáticamente
# Para startx, agregar a ~/.xinitrc:
exec Hyprland
```

### Verificar configuración
```bash
# Verificar que todas las aplicaciones están instaladas
which fish kitty hyprland neovim
# Verificar servicios de audio
systemctl --user status pipewire
```

## Notas de desarrollo

### Mantenimiento del proyecto
- Los scripts incluyen verificaciones de errores robustas
- Sistema de backups automáticos protege configuraciones existentes
- Estructura modular facilita actualizaciones

### Futuras mejoras
- Detección automática de distribuciones
- Soporte para más gestores de ventanas
- Configuraciones adicionales opcionales

### Testing
- Probado en Arch Linux limpio
- Verificado en sistemas con configuraciones existentes
- Scripts probados con diferentes niveles de permisos

## Troubleshooting avanzado

### Logs del sistema
```bash
# Logs de Hyprland
journalctl -u hyprland --no-pager
# Logs del sistema
journalctl -xe
# Logs de audio
journalctl --user -u pipewire
```

### Verificación de servicios
```bash
# Estado de servicios críticos
systemctl --user status pipewire
systemctl --user status hyprland
```

### Restauración manual
```bash
# En caso de problemas graves, restaurar configuraciones
cd ~/dotfiles
rm -rf ~/.config
cp -r ~/.config_backup_[FECHA] ~/.config
```