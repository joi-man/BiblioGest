# Iconos de BiblioGest

Todos los iconos (web, Windows y Android) se generan a partir de **un solo dibujo**: el libro azul en `frontend/assets/icono/libro_96.png` (fondo transparente).

## Dónde queda cada uno

| Plataforma | Archivos | Detalle |
|---|---|---|
| Web | `frontend/web/favicon.png`, `frontend/web/icons/Icon-192.png`, `Icon-512.png`, `Icon-maskable-192.png`, `Icon-maskable-512.png` | Pestaña del navegador e instalación como PWA. Los *maskable* llevan el dibujo más pequeño para que el sistema pueda recortarlos |
| Windows | `frontend/windows/runner/resources/app_icon.ico` | Ejecutable, ventana y accesos directos. El instalador usa el mismo (`SetupIconFile` en `instalador/bibliogest.iss`). Tamaños 16 a 256 px |
| Android | `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png` (clásico) y `ic_launcher_foreground.png` + `mipmap-anydpi-v26/ic_launcher.xml` (adaptable, Android 8+) | El adaptable usa el color de papel `#F4EEE3` como fondo (`values/colors.xml`) |
| Dentro de la app | `frontend/assets/icono/icono_app.png` | Versión de 256 px con fondo transparente, para usar como logo |

Los fondos y el color son los del tema claro de la app ([diseno-sistema.md](diseno-sistema.md)). El nombre visible en todas las plataformas es **BiblioGest**.

## Regenerarlos

Solo hace falta si cambia el dibujo. Desde `frontend`:

```powershell
python tool/generar_iconos.py     # requiere: pip install pillow
```

El script recorta el dibujo a su contenido, lo centra en cada tamaño y escribe todos los archivos anteriores. Los resultados se versionan en git.

## Calidad

El dibujo original mide **96 × 96 px**, así que los iconos grandes (512 px de la web, 432 px del adaptable de Android) salen **ampliados y algo suaves**. Se ven correctos en pantalla y en el escritorio, pero no tienen la nitidez de un icono hecho a medida. Para mejorarlos, reemplaza `libro_96.png` por una versión de **512 px o más** (idealmente 1024 × 1024, PNG con fondo transparente, o el SVG original) y vuelve a ejecutar el script.

`libro_32.png` y `libro_70.png` se conservan como copias del material original; el script solo usa `libro_96.png`.
