# Dotfiles - Arch Linux + Hyprland

Mi configuración personal para Arch Linux con Hyprland, basada en el excelente trabajo de [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland). Esta versión incluye configuraciones pre-configuradas y scripts automatizados para una instalación sin complicaciones.

## Características principales

- **Configuración lista para usar** - Sin necesidad de configurar manualmente cada aplicación
- **Scripts automatizados** - Instalación de dependencias y configuración en un solo comando
- **Backups automáticos** - Tus configuraciones actuales se respaldan antes de la instalación
- **Temas y wallpapers incluidos** - Wallpapers personalizados y configuraciones visuales
- **Sincronización bidireccional** - Scripts para actualizar tanto desde el repo como hacia el repo

## Diferencias con el dotfile original

Este dotfile está basado en [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) pero incluye:

- **Configuraciones pre-establecidas** - No necesitas configurar manualmente
- **Scripts automatizados** - Instalación y actualización automática
- **Wallpapers incluidos** - Colección de fondos personalizados
- **Dependencias completas** - Script que instala todo lo necesario
- **Manejo robusto de errores** - Verificación de permisos y reintentos
- **Sistema de backups** - Protege tus configuraciones existentes

## Documentación técnica

Para información detallada sobre **instalación completa**, **dependencias específicas**, **configuraciones avanzadas** y **solución de problemas**, consulta la [**Documentación Técnica**](SECURITY.md).

La documentación técnica incluye:
- **Instalación paso a paso** - Guía completa con `dependencies.sh` e `install.sh`
- **Atajos de teclado completos** - Más de 25 combinaciones para Hyprland
- **Estructura del proyecto** - Arquitectura completa de carpetas y archivos
- **Aplicaciones configuradas** - Fish, Hyprland, Kitty, Neovim y más
- **Scripts automatizados** - Funcionamiento de install.sh, update.sh y dependencies.sh
- **Troubleshooting avanzado** - Soluciones a problemas comunes como pacman bloqueado
- **Personalización** - Cómo modificar wallpapers, temas y configuraciones

## Créditos

Este proyecto está basado en el increíble trabajo de:
- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)** - Dotfile base y configuraciones principales
- **Comunidad Hyprland** - Por el excelente compositor y documentación
- **Arch Linux** - Por la flexibilidad y control del sistema

## Licencia

Este proyecto sigue la misma filosofía open-source del proyecto original. Siéntete libre de usar, modificar y compartir.

## Contribuciones

¿Encontraste algún bug o tienes una mejora? ¡Las contribuciones son bienvenidas!

1. Fork del proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit de cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

**Tip:** Para mejores resultados, ejecuta `dependencies.sh` antes de `install.sh` en una instalación limpia de Arch Linux.