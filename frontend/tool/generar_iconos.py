"""Genera los iconos de BiblioGest para todas las plataformas a partir de un solo dibujo.

Uso (desde la carpeta frontend):

    python tool/generar_iconos.py

Entrada:  assets/icono/libro_96.png (el dibujo, con fondo transparente).
          Si algun dia hay una version mas grande (512 px o mas), reemplaza ese
          archivo: los iconos grandes saldran mucho mas nitidos.
Salida:   web/favicon.png y web/icons/*            (navegador e instalacion como PWA)
          windows/runner/resources/app_icon.ico    (ejecutable y accesos directos)
          android/app/src/main/res/mipmap-*        (icono clasico y adaptable de Android)
          assets/icono/icono_app.png               (logo para usar dentro de la app)

Requiere Pillow (pip install pillow). Los resultados se versionan: este script solo
hace falta cuando cambia el dibujo.
"""
from pathlib import Path

from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
ORIGEN = RAIZ / "assets" / "icono" / "libro_96.png"

# Mismo color de papel que el tema claro de la app (core/theme/colores_app.dart).
FONDO = (0xF4, 0xEE, 0xE3, 255)
FONDO_HEX = "#F4EEE3"


def cargar_dibujo() -> Image.Image:
    """El dibujo recortado a su contenido, sin margen transparente."""
    imagen = Image.open(ORIGEN).convert("RGBA")
    return imagen.crop(imagen.getbbox())


def componer(dibujo: Image.Image, lado: int, proporcion: float, fondo=None) -> Image.Image:
    """Lienzo cuadrado con el dibujo centrado, ocupando `proporcion` del lado."""
    lienzo = Image.new("RGBA", (lado, lado), fondo or (0, 0, 0, 0))
    mayor = max(dibujo.size)
    escala = (lado * proporcion) / mayor
    tamano = (max(1, round(dibujo.width * escala)), max(1, round(dibujo.height * escala)))
    ajustado = dibujo.resize(tamano, Image.LANCZOS)
    lienzo.alpha_composite(
        ajustado, ((lado - tamano[0]) // 2, (lado - tamano[1]) // 2)
    )
    return lienzo


def guardar(imagen: Image.Image, ruta: Path) -> None:
    ruta.parent.mkdir(parents=True, exist_ok=True)
    imagen.save(ruta)
    print("  ", ruta.relative_to(RAIZ))


def generar_web(dibujo: Image.Image) -> None:
    print("Web")
    guardar(componer(dibujo, 64, 0.92), RAIZ / "web" / "favicon.png")
    for lado in (192, 512):
        guardar(componer(dibujo, lado, 0.7, FONDO), RAIZ / "web" / "icons" / f"Icon-{lado}.png")
        # Maskable: el sistema recorta hasta un 20 % de cada borde, el dibujo va en el centro.
        guardar(
            componer(dibujo, lado, 0.5, FONDO),
            RAIZ / "web" / "icons" / f"Icon-maskable-{lado}.png",
        )


def generar_windows(dibujo: Image.Image) -> None:
    print("Windows")
    base = componer(dibujo, 256, 0.94)
    ruta = RAIZ / "windows" / "runner" / "resources" / "app_icon.ico"
    base.save(ruta, format="ICO", sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
    print("  ", ruta.relative_to(RAIZ))


def generar_android(dibujo: Image.Image) -> None:
    print("Android")
    res = RAIZ / "android" / "app" / "src" / "main" / "res"
    # Icono clasico (Android 7 y anteriores, y lanzadores que no usan el adaptable).
    for carpeta, lado in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        guardar(componer(dibujo, lado, 0.72, FONDO), res / f"mipmap-{carpeta}" / "ic_launcher.png")
    # Icono adaptable (Android 8+): primer plano de 108 dp con el dibujo dentro de la zona
    # segura (los 66 dp centrales) y el fondo como color.
    for carpeta, lado in (("mdpi", 108), ("hdpi", 162), ("xhdpi", 216), ("xxhdpi", 324), ("xxxhdpi", 432)):
        guardar(
            componer(dibujo, lado, 0.5),
            res / f"mipmap-{carpeta}" / "ic_launcher_foreground.png",
        )
    (res / "mipmap-anydpi-v26").mkdir(parents=True, exist_ok=True)
    (res / "mipmap-anydpi-v26" / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        "</adaptive-icon>\n",
        encoding="utf-8",
    )
    (res / "values" / "colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">{FONDO_HEX}</color>\n'
        "</resources>\n",
        encoding="utf-8",
    )
    print("  ", "mipmap-anydpi-v26/ic_launcher.xml, values/colors.xml")


def generar_logo(dibujo: Image.Image) -> None:
    print("Logo dentro de la app")
    guardar(componer(dibujo, 256, 0.96), RAIZ / "assets" / "icono" / "icono_app.png")


if __name__ == "__main__":
    dibujo = cargar_dibujo()
    generar_web(dibujo)
    generar_windows(dibujo)
    generar_android(dibujo)
    generar_logo(dibujo)
    print("Listo.")
