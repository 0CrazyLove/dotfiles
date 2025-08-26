#!/usr/bin/env python3

# import re
# import os
# import sys
# import time
# import subprocess
# from pathlib import Path

# def wait_for_file(file_path, timeout=10):
#     """Espera a que el archivo exista o se actualice"""
#     start_time = time.time()
#     while time.time() - start_time < timeout:
#         if file_path.exists():
#             return True
#         time.sleep(0.5)
#     return False

# def restart_quickshell():
#     """Reinicia QuickShell de forma más robusta"""
#     try:
#         print("🔄 Reiniciando QuickShell...")
        
#         # Obtener PIDs de QuickShell
#         result = subprocess.run(['pgrep', '-f', 'quickshell'], 
#                                capture_output=True, text=True)
        
#         if result.returncode == 0:
#             pids = result.stdout.strip().split('\n')
#             print(f"📊 Terminando procesos QuickShell: {', '.join(pids)}")
            
#             # Terminar procesos existentes con SIGTERM primero
#             subprocess.run(['pkill', '-TERM', '-f', 'quickshell'], capture_output=True)
#             time.sleep(2)
            
#             # Si aún hay procesos, usar SIGKILL
#             result = subprocess.run(['pgrep', '-f', 'quickshell'], capture_output=True)
#             if result.returncode == 0:
#                 print("⚠️  Algunos procesos siguen activos, usando SIGKILL...")
#                 subprocess.run(['pkill', '-KILL', '-f', 'quickshell'], capture_output=True)
#                 time.sleep(1)
        
#         # Iniciar QuickShell de nuevo
#         print("🚀 Iniciando QuickShell...")
#         process = subprocess.Popen(['quickshell'], 
#                                  stdout=subprocess.DEVNULL, 
#                                  stderr=subprocess.DEVNULL,
#                                  start_new_session=True)
        
#         # Esperar un poco para verificar que se inició correctamente
#         time.sleep(2)
        
#         # Verificar que se inició
#         result = subprocess.run(['pgrep', '-f', 'quickshell'], capture_output=True)
#         if result.returncode == 0:
#             print("✅ QuickShell reiniciado exitosamente")
#             return True
#         else:
#             print("❌ Error: QuickShell no se pudo iniciar")
#             return False
            
#     except Exception as e:
#         print(f"⚠️  Error reiniciando QuickShell: {e}")
#         return False

# def main():
#     # Rutas
#     home = Path.home()
#     scss_file = home / ".cache/wal/colors.scss"
#     appearance_file = home / ".config/quickshell/ii/modules/common/Appearance.qml"

#     print(f"🔍 Buscando archivo SCSS: {scss_file}")
    
#     # Esperar a que pywal genere el archivo SCSS
#     if not wait_for_file(scss_file, timeout=5):
#         print(f"❌ Error: No se encuentra el archivo {scss_file}")
#         print("   Asegúrate de que pywal haya generado los colores correctamente.")
        
#         # Mostrar archivos alternativos que podrían existir
#         pywal_cache = home / ".cache/wal"
#         if pywal_cache.exists():
#             print("📁 Archivos en .cache/wal:")
#             for file in pywal_cache.glob("*"):
#                 print(f"   - {file}")
#         sys.exit(1)

#     # Verificar que el archivo QML existe
#     if not appearance_file.exists():
#         print(f"❌ Error: No se encuentra el archivo {appearance_file}")
#         print("   Verifica la ruta de configuración de QuickShell.")
#         sys.exit(1)

#     # Backup del archivo original (solo la primera vez)
#     backup_file = appearance_file.with_suffix('.qml.backup')
#     if not backup_file.exists():
#         import shutil
#         try:
#             shutil.copy2(appearance_file, backup_file)
#             print(f"📄 Backup creado en: {backup_file}")
#         except Exception as e:
#             print(f"⚠️  Advertencia: No se pudo crear backup: {e}")

#     # Leer colores del archivo SCSS
#     colors = {}
#     try:
#         with open(scss_file, 'r') as f:
#             content = f.read()
#             print(f"📄 Contenido del archivo SCSS ({len(content)} caracteres)")
            
#         # Procesar línea por línea
#         with open(scss_file, 'r') as f:
#             for line_num, line in enumerate(f, 1):
#                 if line.startswith('$'):
#                     parts = line.strip().split(': ')
#                     if len(parts) == 2:
#                         key = parts[0][1:]  # Remover el $
#                         value = parts[1].rstrip(';')
#                         colors[key] = value
#                         print(f"   🎨 {key}: {value}")
#     except Exception as e:
#         print(f"❌ Error leyendo archivo SCSS: {e}")
#         sys.exit(1)

#     if not colors:
#         print("❌ No se encontraron colores en el archivo SCSS")
#         print("📄 Contenido completo del archivo:")
#         with open(scss_file, 'r') as f:
#             print(f.read())
#         sys.exit(1)

#     print(f"✅ Se encontraron {len(colors)} colores")

#     # Mapeo de colores SCSS a propiedades QML
#     color_mapping = {
#         'primary_paletteKeyColor': 'm3primary_paletteKeyColor',
#         'secondary_paletteKeyColor': 'm3secondary_paletteKeyColor', 
#         'tertiary_paletteKeyColor': 'm3tertiary_paletteKeyColor',
#         'neutral_paletteKeyColor': 'm3neutral_paletteKeyColor',
#         'neutral_variant_paletteKeyColor': 'm3neutral_variant_paletteKeyColor',
#         'background': 'm3background',
#         'onBackground': 'm3onBackground',
#         'surface': 'm3surface',
#         'surfaceDim': 'm3surfaceDim',
#         'surfaceBright': 'm3surfaceBright',
#         'surfaceContainerLowest': 'm3surfaceContainerLowest',
#         'surfaceContainerLow': 'm3surfaceContainerLow',
#         'surfaceContainer': 'm3surfaceContainer',
#         'surfaceContainerHigh': 'm3surfaceContainerHigh',
#         'surfaceContainerHighest': 'm3surfaceContainerHighest',
#         'onSurface': 'm3onSurface',
#         'surfaceVariant': 'm3surfaceVariant',
#         'onSurfaceVariant': 'm3onSurfaceVariant',
#         'inverseSurface': 'm3inverseSurface',
#         'inverseOnSurface': 'm3inverseOnSurface',
#         'outline': 'm3outline',
#         'outlineVariant': 'm3outlineVariant',
#         'shadow': 'm3shadow',
#         'scrim': 'm3scrim',
#         'surfaceTint': 'm3surfaceTint',
#         'primary': 'm3primary',
#         'onPrimary': 'm3onPrimary',
#         'primaryContainer': 'm3primaryContainer',
#         'onPrimaryContainer': 'm3onPrimaryContainer',
#         'inversePrimary': 'm3inversePrimary',
#         'secondary': 'm3secondary',
#         'onSecondary': 'm3onSecondary',
#         'secondaryContainer': 'm3secondaryContainer',
#         'onSecondaryContainer': 'm3onSecondaryContainer',
#         'tertiary': 'm3tertiary',
#         'onTertiary': 'm3onTertiary',
#         'tertiaryContainer': 'm3tertiaryContainer',
#         'onTertiaryContainer': 'm3onTertiaryContainer',
#         'error': 'm3error',
#         'onError': 'm3onError',
#         'errorContainer': 'm3errorContainer',
#         'onErrorContainer': 'm3onErrorContainer',
#     }

#     # Leer el archivo Appearance.qml
#     try:
#         with open(appearance_file, 'r') as f:
#             content = f.read()
#     except Exception as e:
#         print(f"❌ Error leyendo archivo QML: {e}")
#         sys.exit(1)

#     # Contador de colores actualizados
#     updated_count = 0

#     # Actualizar colores - Patrón mejorado
#     original_content = content
    
#     # Primero, vamos a ver exactamente cómo se ve una línea del archivo
#     sample_lines = []
#     for line in content.split('\n'):
#         if 'm3primary_paletteKeyColor' in line:
#             sample_lines.append(line.strip())
    
#     if sample_lines:
#         print(f"📋 Ejemplo de línea encontrada: '{sample_lines[0]}'")
    
#     for scss_key, qml_key in color_mapping.items():
#         if scss_key in colors:
#             # Patrón más flexible que maneja diferentes formatos
#             patterns = [
#                 rf'(property color {qml_key}:\s*)"[^"]*"',  # Formato original
#                 rf'(property color {qml_key}:\s*)"[^"]*"',  # Con espacios extra
#                 rf'(\s*property\s+color\s+{qml_key}:\s*)"[^"]*"',  # Con espacios variables
#                 rf'(property\s+color\s+{qml_key}\s*:\s*)"[^"]*"',  # Espacios alrededor de :
#             ]
            
#             updated_this_color = False
#             for pattern in patterns:
#                 new_content = re.sub(pattern, rf'\1"{colors[scss_key]}"', content, flags=re.MULTILINE)
#                 if new_content != content:
#                     content = new_content
#                     updated_count += 1
#                     updated_this_color = True
#                     print(f"   ✅ Actualizado {qml_key}: {colors[scss_key]}")
#                     break
            
#             if not updated_this_color:
#                 # Buscar la línea exacta para debugging
#                 for line_num, line in enumerate(content.split('\n'), 1):
#                     if qml_key in line and 'property color' in line:
#                         print(f"   🔍 Línea {line_num} encontrada: '{line.strip()}'")
#                         break
#                 print(f"   ⚠️  No se pudo actualizar {qml_key}")

#     # Verificar si hubo cambios
#     if content == original_content:
#         print("⚠️  ADVERTENCIA: No se realizaron cambios en el archivo QML")
#         print("📋 Verificando patrones en el archivo...")
        
#         # Mostrar todas las propiedades color encontradas
#         color_properties = re.findall(r'property color [^:]+:', content)
#         print(f"🎨 Propiedades de color encontradas ({len(color_properties)}):")
#         for prop in color_properties[:10]:  # Mostrar solo las primeras 10
#             print(f"   - {prop}")
        
#         if len(color_properties) > 10:
#             print(f"   ... y {len(color_properties) - 10} más")
    
#     print(f"📝 Total de propiedades actualizadas: {updated_count}")

#     # Escribir el archivo actualizado
#     try:
#         with open(appearance_file, 'w') as f:
#             f.write(content)
#     except Exception as e:
#         print(f"❌ Error escribiendo archivo QML: {e}")
#         sys.exit(1)

#     print(f"✅ Colores actualizados en QuickShell ({updated_count} propiedades)")
#     print("🎨 Colores principales aplicados:")
#     print(f"   • Background: {colors.get('background', 'N/A')}")
#     print(f"   • Primary: {colors.get('primary', 'N/A')}")
#     print(f"   • Secondary: {colors.get('secondary', 'N/A')}")
#     print(f"   • On Background: {colors.get('onBackground', 'N/A')}")
    
#     # Reiniciar QuickShell para aplicar los cambios
#     print("🔄 Reiniciando QuickShell...")
#     restart_quickshell()

# if __name__ == "__main__":
#     main()