cat > ~/.config/hypr/scripts/actualizar-quickshell-simple.py << 'EOF'
#!/usr/bin/env python3

import re
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

    # Leer colores del SCSS
    colors = {}
    with open(scss_file, 'r') as f:
        for line in f:
            if line.startswith('$'):
                parts = line.strip().split(': ')
                if len(parts) == 2:
                    key = parts[0][1:]  # Remover $
                    value = parts[1].rstrip(';')
                    colors[key] = value

    print(f"🎨 Colores encontrados: {len(colors)}")

    # Mapeo simplificado - solo los colores más importantes
    color_mapping = {
        'background': 'm3background',
        'onBackground': 'm3onBackground',
        'surface': 'm3surface',
        'primary': 'm3primary',
        'onPrimary': 'm3onPrimary',
        'secondary': 'm3secondary',
        'onSecondary': 'm3onSecondary',
        'tertiary': 'm3tertiary',
        'outline': 'm3outline',
        'surfaceVariant': 'm3surfaceVariant',
        'onSurfaceVariant': 'm3onSurfaceVariant',
    }

    # Leer archivo QML
    with open(appearance_file, 'r') as f:
        content = f.read()

    # Buscar y reemplazar usando un método más directo
    updated_count = 0
    
    for scss_key, qml_key in color_mapping.items():
        if scss_key in colors:
            # Buscar cualquier línea que contenga el nombre de la propiedad
            lines = content.split('\n')
            new_lines = []
            
            for line in lines:
                if f'property color {qml_key}:' in line:
                    # Extraer la parte antes y después del valor
                    if '"' in line:
                        before = line.split('"')[0]
                        after = '"' + '"'.join(line.split('"')[2:]) if len(line.split('"')) > 2 else ''
                        new_line = f'{before}"{colors[scss_key]}"{after}'
                        new_lines.append(new_line)
                        print(f"✅ {qml_key}: {colors[scss_key]}")
                        updated_count += 1
                    else:
                        new_lines.append(line)
                else:
                    new_lines.append(line)
            
            content = '\n'.join(new_lines)

    # Escribir archivo actualizado
    with open(appearance_file, 'w') as f:
        f.write(content)

    print(f"📝 Total actualizadas: {updated_count} propiedades")
    
    if updated_count > 0:
        print("✅ ¡Colores actualizados exitosamente!")
        
        # Reiniciar QuickShell de forma simple
        import subprocess
        try:
            subprocess.run(['pkill', '-f', 'quickshell'], check=False)
            import time
            time.sleep(2)
            subprocess.Popen(['quickshell'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print("🔄 QuickShell reiniciado")
        except Exception as e:
            print(f"⚠️  Error reiniciando QuickShell: {e}")
    else:
        print("⚠️  No se actualizaron colores")

if __name__ == "__main__":
    main()
EOF

chmod +x ~/.config/hypr/scripts/actualizar-quickshell-simple.py
