#!/bin/bash

echo "🔄 RECARGANDO QUICKSHELL"
echo "========================"

# Método directo: Reinicio completo
echo "🔄 Reiniciando QuickShell completamente..."

# Obtener todos los PIDs
PIDS=$(pgrep -f quickshell)
if [ ! -z "$PIDS" ]; then
    echo "📊 PIDs encontrados: $PIDS"
    
    # Terminar amablemente
    echo "🛑 Terminando procesos..."
    for PID in $PIDS; do
        kill -TERM $PID 2>/dev/null
        echo "   → Terminando PID $PID"
    done
    
    # Esperar
    sleep 3
    
    # Verificar si quedan procesos
    REMAINING=$(pgrep -f quickshell)
    if [ ! -z "$REMAINING" ]; then
        echo "⚡ Forzando terminación de procesos restantes..."
        for PID in $REMAINING; do
            kill -KILL $PID 2>/dev/null
            echo "   → Forzando terminación de PID $PID"
        done
        sleep 1
    fi
else
    echo "ℹ️  No se encontraron procesos QuickShell activos"
fi

# Limpiar archivos de sesión si existen
echo "🧹 Limpiando archivos temporales..."
rm -f /tmp/quickshell-* 2>/dev/null
rm -f ~/.cache/quickshell/* 2>/dev/null

# Iniciar QuickShell
echo "🚀 Iniciando QuickShell..."
nohup quickshell >/dev/null 2>&1 &
NEW_PID=$!

# Esperar y verificar
sleep 3

if ps -p $NEW_PID > /dev/null; then
    echo "✅ QuickShell iniciado exitosamente (PID: $NEW_PID)"
    
    # Verificar que esté mostrando la interfaz
    sleep 2
    ALL_PIDS=$(pgrep -f quickshell)
    echo "📊 PIDs actuales de QuickShell: $ALL_PIDS"
    
    echo "🎯 ¡Recarga completa exitosa!"
else
    echo "❌ Error: QuickShell no se pudo iniciar correctamente"
    echo "🔍 Intentando iniciar manualmente..."
    quickshell &
    sleep 2
    
    # Verificar otra vez
    if pgrep -f quickshell > /dev/null; then
        echo "✅ QuickShell iniciado en segunda tentativa"
    else
        echo "❌ QuickShell no se pudo iniciar"
    fi
fi

echo "========================"