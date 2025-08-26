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
echo "⏳ Esperando a que pywal genere los archivos..."
sleep 2

# Verificar que pywal generó los archivos correctamente
if test -f "$HOME/.cache/wal/colors"
    echo "✅ Pywal generó los colores correctamente"
else
    echo "❌ Error: Pywal no generó los archivos de colores"
    exit 1
end

# Ejecutar el script de Python para actualizar QuickShell
echo "⚙️  Actualizando colores de QuickShell..."
python3 $HOME/.config/hypr/scripts/actualizar-quickshell-exacto.py

# Verificar el resultado
if test $status -eq 0
    echo "✅ ¡Cambio completado! Fondo y colores actualizados."
    
    # Asegurar que QuickShell esté corriendo
    sleep 1
    if not pgrep -f quickshell > /dev/null
        echo "🚀 Iniciando QuickShell..."
        quickshell &
        sleep 2
    end
    
    echo "🎯 ¡Todo listo! Los colores deberían haberse aplicado."
else
    echo "❌ Hubo un error actualizando los colores de QuickShell"
    echo "🔍 Ejecuta el script de diagnóstico: debug-quickshell.sh"
end