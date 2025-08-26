#!/bin/bash

echo "🔍 ANALIZANDO FORMATO DEL ARCHIVO QML"
echo "====================================="

QML_FILE="$HOME/.config/quickshell/ii/modules/common/Appearance.qml"

if [ -f "$QML_FILE" ]; then
    echo "📄 Archivo encontrado: $QML_FILE"
    echo ""
    
    echo "📋 Líneas con m3primary_paletteKeyColor:"
    echo "---------------------------------------"
    grep -n "m3primary_paletteKeyColor" "$QML_FILE"
    
    echo ""
    echo "📋 Líneas con m3background:"
    echo "----------------------------"
    grep -n "m3background" "$QML_FILE"
    
    echo ""
    echo "📋 Primeras 5 líneas con 'property color':"
    echo "------------------------------------------"
    grep -n "property color" "$QML_FILE" | head -5
    
    echo ""
    echo "📋 Formato exacto (con caracteres especiales visibles):"
    echo "--------------------------------------------------------"
    grep "m3primary_paletteKeyColor" "$QML_FILE" | cat -A
    
else
    echo "❌ Archivo QML no encontrado: $QML_FILE"
fi

echo "====================================="
