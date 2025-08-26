#!/usr/bin/env python3

import sys
from pathlib import Path

def main():
    # Rutas
    home = Path.home()
    scss_file = home / ".local/state/quickshell/user/generated/material_colors.scss"
    appearance_file = home / ".config/quickshell/ii/modules/common/Appearance.qml"

    # Verificar archivos
    if not scss_file.exists():
        print(f"❌ Error: No se encuentra {scss_file}")
        sys.exit(1)
        
    if not appearance_file.exists():
        print(f"❌ Error: No se encuentra {appearance_file}")
        sys.exit(1)

    print("🔍 Leyendo colores del archivo SCSS...")
    
    # Leer colores del SCSS
    colors = {}
    with open(scss_file, "r") as f:
        for line in f:
            if line.startswith("$"):
                parts = line.strip().split(": ")
                if len(parts) == 2:
                    key = parts[0][1:]  # Remover $
                    value = parts[1].rstrip(";")
                    colors[key] = value

    print(f"🎨 Colores encontrados: {len(colors)}")

    # Mapeo basado en el formato exacto que vimos
    color_mapping = {
        "primary_paletteKeyColor": "m3primary_paletteKeyColor",
        "secondary_paletteKeyColor": "m3secondary_paletteKeyColor",
        "tertiary_paletteKeyColor": "m3tertiary_paletteKeyColor",
        "neutral_paletteKeyColor": "m3neutral_paletteKeyColor",
        "neutral_variant_paletteKeyColor": "m3neutral_variant_paletteKeyColor",
        "background": "m3background",
        "onBackground": "m3onBackground",
        "surface": "m3surface",
        "primary": "m3primary",
        "onPrimary": "m3onPrimary",
        "secondary": "m3secondary",
        "onSecondary": "m3onSecondary",
        "tertiary": "m3tertiary",
        "onTertiary": "m3onTertiary",
        "outline": "m3outline",
    }

    # Leer archivo QML
    with open(appearance_file, "r") as f:
        lines = f.readlines()

    print("🔧 Actualizando colores en el archivo QML...")
    
    updated_count = 0
    new_lines = []
    
    for line in lines:
        line_updated = False
        
        # Verificar si esta línea contiene alguna propiedad que queremos actualizar
        for scss_key, qml_key in color_mapping.items():
            if scss_key in colors and f"property color {qml_key}:" in line:
                # El formato exacto es: "        property color m3background: \"#color\""
                # Vamos a reemplazar solo el valor del color
                if "\"#" in line:
                    # Encontrar las posiciones de las comillas
                    start_quote = line.find("\"#")
                    end_quote = line.find("\"", start_quote + 1)
                    
                    if start_quote != -1 and end_quote != -1:
                        # Construir la nueva línea manteniendo todo igual excepto el color
                        new_line = line[:start_quote + 1] + colors[scss_key] + line[end_quote:]
                        new_lines.append(new_line)
                        print(f"✅ {qml_key}: {colors[scss_key]}")
                        updated_count += 1
                        line_updated = True
                        break
        
        # Si no se actualizó la línea, mantenerla igual
        if not line_updated:
            new_lines.append(line)

    # Escribir archivo actualizado
    with open(appearance_file, "w") as f:
        f.writelines(new_lines)

    print(f"📝 Total actualizadas: {updated_count} propiedades")
    
    if updated_count > 0:
        print("✅ ¡Colores actualizados exitosamente!")
        
        # Reiniciar QuickShell de forma simple
        import subprocess
        import time
        
        print("🔄 Reiniciando QuickShell...")
        try:
            # Terminar QuickShell
            result = subprocess.run(["pkill", "-f", "quickshell"], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print("🛑 QuickShell terminado")
            
            # Esperar un poco
            time.sleep(2)
            
            # Iniciar QuickShell
            subprocess.Popen(["quickshell"], 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL,
                           start_new_session=True)
            
            time.sleep(1)
            
            # Verificar que se inició
            check_result = subprocess.run(["pgrep", "-f", "quickshell"], 
                                        capture_output=True, text=True)
            if check_result.returncode == 0:
                print("🚀 QuickShell reiniciado exitosamente")
            else:
                print("⚠️  QuickShell puede no haberse iniciado correctamente")
                
        except Exception as e:
            print(f"⚠️  Error reiniciando QuickShell: {e}")
            print("💡 Intenta reiniciarlo manualmente: killall quickshell && quickshell &")
    else:
        print("⚠️  No se actualizaron colores - Verificar mapeo de colores")

if __name__ == "__main__":
    main()
