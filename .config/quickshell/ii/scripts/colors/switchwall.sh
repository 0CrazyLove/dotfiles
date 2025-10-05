#!/usr/bin/env bash

# Script simple para cambiar wallpaper con SWWW + pywal
# Selecciona imagen, la aplica y genera colores con pywal

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Función para verificar si swww está corriendo
check_swww() {
    if ! pgrep -x swww-daemon > /dev/null; then
        echo "swww-daemon no está corriendo. Iniciando..."
        swww-daemon &
        sleep 1
    fi
}

# Función para aplicar colores
apply_kde_colors() {
    if [[ -f ~/.cache/wal/colors-kde.conf ]]; then
        cp ~/.cache/wal/colors-kde.conf ~/.config/kdeglobals
        
        # Aplicar cambios sin reiniciar aplicaciones
        if command -v qdbus &>/dev/null; then
            # Recargar configuración de KDE
            qdbus org.kde.KWin /KWin reconfigure 2>/dev/null
            # Notificar cambio de colores a las aplicaciones Qt
            qdbus org.kde.klauncher5 /KLauncher reparseConfiguration 2>/dev/null
        fi
    fi
}

# Función principal
set_wallpaper() {
    local imgpath="$1"
    
    if [[ -z "$imgpath" ]]; then
        # Abrir diálogo para seleccionar imagen
        cd "$HOME/Documents/Wallpapers" 2>/dev/null || \
           cd "$HOME/Documents" 2>/dev/null || \
           cd "$HOME"
        
        imgpath="$(kdialog --getopenfilename . --title 'Seleccionar wallpaper')"
    fi
    
    # Verificar que se seleccionó un archivo
    if [[ -z "$imgpath" || ! -f "$imgpath" ]]; then
        echo "No se seleccionó ninguna imagen"
        exit 1
    fi
    
    # Verificar que swww esté corriendo
    check_swww
    
    # Aplicar wallpaper con swww en background 
    swww img "$imgpath" \
        --transition-type fade \
        --transition-duration 0.3 &
    swww_pid=$!
    
    # Generar colores con pywal en paralelo
    if command -v wal &>/dev/null; then
        wal -i "$imgpath" -q &  # -q
        wal_pid=$!
        
        wait $swww_pid $wal_pid
        
        apply_kde_colors
       
    fi
    
    echo "Wallpaper aplicado: $imgpath"
}

# Ejecutar
set_wallpaper "$@"