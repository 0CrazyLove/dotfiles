#!/bin/bash

echo "🔍 DIAGNÓSTICO DE QUICKSHELL - COLORES PYWAL"
echo "=============================================="

# Variables
HOME_DIR="$HOME"
SCSS_FILE="$HOME/.local/state/quickshell/user/generated/material_colors.scss"
QML_FILE="$HOME/.config/quickshell/ii/modules/common/Appearance.qml"

echo "📁 Verificando archivos..."
echo "----------------------------"

# Verificar archivo SCSS
if [ -f "$SCSS_FILE" ]; then
    echo "✅ Archivo SCSS encontrado: $SCSS_FILE"
    echo "📊 Tamaño: $(du -h "$SCSS_FILE" | cut -f1)"
    echo "⏰ Última modificación: $(stat -c %y "$SCSS_FILE")"
    echo ""
    echo "📄 Primeras 10 líneas del archivo SCSS:"
    head -10 "$SCSS_FILE"
else
    echo "❌ Archivo SCSS NO encontrado: $SCSS_FILE"
fi

echo ""
echo "----------------------------"

# Verificar archivo QML
if [ -f "$QML_FILE" ]; then
    echo "✅ Archivo QML encontrado: $QML_FILE"
    echo "📊 Tamaño: $(du -h "$QML_FILE" | cut -f1)"
    echo "⏰ Última modificación: $(stat -c %y "$QML_FILE")"
    echo ""
    echo "🎨 Colores actuales en Appearance.qml (primeras 5 propiedades):"
    grep -n "property color m3" "$QML_FILE" | head -5
else
    echo "❌ Archivo QML NO encontrado: $QML_FILE"
fi

echo ""
echo "----------------------------"
echo "🔧 Verificando procesos QuickShell..."

if pgrep -f quickshell > /dev/null; then
    echo "✅ QuickShell está ejecutándose"
    echo "📊 PIDs: $(pgrep -f quickshell | tr '\n' ' ')"
else
    echo "❌ QuickShell NO está ejecutándose"
fi

echo ""
echo "----------------------------"
echo "🎯 Verificando archivos de pywal..."

PYWAL_COLORS="$HOME/.cache/wal/colors"
if [ -f "$PYWAL_COLORS" ]; then
    echo "✅ Archivo de colores pywal encontrado"
    echo "📄 Colores actuales:"
    cat "$PYWAL_COLORS"
else
    echo "❌ Archivo de colores pywal NO encontrado"
fi

echo ""
echo "=============================================="
echo "💡 POSIBLES SOLUCIONES:"
echo "1. Si el archivo SCSS no existe o está vacío, pywal no está configurado correctamente"
echo "2. Si los colores en QML no cambian, hay un problema con el regex del script Python"
echo "3. Si QuickShell no reinicia, los cambios no se aplicarán visualmente"
echo "=============================================="
