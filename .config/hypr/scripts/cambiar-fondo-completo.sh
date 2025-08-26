#!/usr/bin/env fish

# Carpeta con tus fondos
set FONDOS $HOME/Documents/FondosPantallas

# Elegir un fondo aleatorio
set FONDO (find $FONDOS -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

echo "🖼️  Cambiando fondo a: "(basename $FONDO)

# Generar colores con pywal
echo "🎨 Generando paleta de colores..."
wal -i $FONDO

# Aplicar fondo con swww con transición más rápida y moderna
echo "🌅 Aplicando fondo de pantalla..."
swww img $FONDO --transition-type fade --transition-duration 0.5

# Esperar un momento para que pywal termine de procesar
sleep 1

# Ejecutar el script de Python para actualizar QuickShell
echo "⚙️  Actualizando colores de QuickShell..."
python3 $HOME/.config/hypr/scripts/actualizar-quickshell-colores.py

# Opcional: Reiniciar QuickShell para aplicar los cambios
echo "🔄 Reiniciando QuickShell..."
killall quickshell 2>/dev/null
sleep 0.5
quickshell &

echo "✅ ¡Cambio completado! Fondo y colores actualizados."