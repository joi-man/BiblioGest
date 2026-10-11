"""Valores permitidos del inventario, definidos en un solo lugar.

Los esquemas Pydantic, los servicios y las pruebas leen estas constantes para
no repetir listas de texto en varios archivos.
"""

# Tipos de material que administra la biblioteca (libros y equipos).
TIPOS_MATERIAL = (
    "libro",
    "revista",
    "dvd",
    "cd",
    "proyector",
    "alargador",
    "laptop",
    "tablet",
    "parlante",
    "microfono",
    "camara",
    "adaptador",
    "otro",
)

# Tipos de material que son bibliograficos (usan autor, ISBN, editorial...).
TIPOS_BIBLIOGRAFICOS = ("libro", "revista")

# Estados posibles de una unidad de material.
ESTADO_DISPONIBLE = "disponible"
ESTADO_RESERVADO = "reservado"
ESTADO_PRESTADO = "prestado"
ESTADO_VENCIDO = "vencido"
ESTADO_FUERA_DE_SERVICIO = "fuera_de_servicio"

ESTADOS_MATERIAL = (
    ESTADO_DISPONIBLE,
    ESTADO_RESERVADO,
    ESTADO_PRESTADO,
    ESTADO_VENCIDO,
    ESTADO_FUERA_DE_SERVICIO,
)

# Condicion fisica de una unidad.
CONDICIONES_MATERIAL = ("nuevo", "bueno", "regular", "malo")


def patron_opciones(opciones: tuple[str, ...]) -> str:
    """Construye la expresion regular `^(a|b|c)$` para validar un campo de opciones."""
    return "^(" + "|".join(opciones) + ")$"
