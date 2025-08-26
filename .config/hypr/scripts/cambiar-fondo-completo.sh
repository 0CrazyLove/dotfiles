#!/usr/bin/env fish

# Configuración
set FONDOS $HOME/Documents/FondosPantallas
set HISTORIAL_FILE $HOME/.cache/fondos_historial
set MAX_HISTORIAL 50  # Máximo de fondos a recordar

# Crear directorio cache si no existe
mkdir -p (dirname $HISTORIAL_FILE)

# Función para obtener todos los fondos disponibles
function obtener_fondos
    find $FONDOS -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null
end

# Función para leer historial
function leer_historial
    if test -f $HISTORIAL_FILE
        cat $HISTORIAL_FILE
    end
end

# Función para agregar al historial
function agregar_historial
    set nuevo_fondo $argv[1]
    
    # Agregar nuevo fondo al inicio
    echo $nuevo_fondo > $HISTORIAL_FILE.tmp
    
    # Agregar historial anterior (excluyendo el nuevo si ya existía)
    if test -f $HISTORIAL_FILE
        grep -v "^$nuevo_fondo\$" $HISTORIAL_FILE | head -n (math $MAX_HISTORIAL - 1) >> $HISTORIAL_FILE.tmp
    end
    
    mv $HISTORIAL_FILE.tmp $HISTORIAL_FILE
end

echo "🔍 Buscando fondos disponibles..."

# Obtener todos los fondos
set todos_fondos (obtener_fondos)
set total_fondos (count $todos_fondos)

if test $total_fondos -eq 0
    echo "❌ No se encontraron fondos en $FONDOS"
    exit 1
end

echo "📁 Encontrados $total_fondos fondos"

# Leer historial de fondos usados
set historial (leer_historial)

# Filtrar fondos no usados recientemente
set fondos_disponibles
for fondo in $todos_fondos
    if not contains $fondo $historial
        set fondos_disponibles $fondos_disponibles $fondo
    end
end

# Si todos los fondos han sido usados, resetear y usar todos
if test (count $fondos_disponibles) -eq 0
    echo "🔄 Todos los fondos han sido usados, reiniciando historial..."
    rm -f $HISTORIAL_FILE
    set fondos_disponibles $todos_fondos
end

# Elegir fondo aleatorio de los disponibles
set FONDO $fondos_disponibles[(random 1 (count $fondos_disponibles))]

echo "🖼️  Cambiando fondo a: "(basename $FONDO)

# Agregar al historial
agregar_historial $FONDO

# Aplicar fondo primero (más rápido visualmente)
echo "🌅 Aplicando fondo de pantalla..."
swww img $FONDO --transition-type fade --transition-duration 0.3 &
set swww_pid $last_pid

# Generar colores en paralelo
echo "🎨 Generando paleta de colores..."
wal -i $FONDO -q &  # -q para modo silencioso
set wal_pid $last_pid

# Esperar a que ambos procesos terminen
wait $swww_pid $wal_pid

# Actualizar QuickShell en background
echo "⚙️  Actualizando colores de QuickShell..."
python3 $HOME/.config/hypr/scripts/actualizar-quickshell-colores.py &
set python_pid $last_pid

# Reiniciar QuickShell de forma más eficiente
echo "🔄 Reiniciando QuickShell..."
pkill -f quickshell
sleep 0.2

# Esperar a que el script de Python termine antes de iniciar QuickShell
wait $python_pid
quickshell &

echo "✅ ¡Cambio completado! Fondo: "(basename $FONDO)" (Quedan "(count $fondos_disponibles)" sin usar)"