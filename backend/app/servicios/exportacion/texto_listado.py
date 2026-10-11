"""Funciones para convertir valores de la base en texto legible de un listado."""
from typing import Optional


def etiqueta(valor: Optional[str]) -> str:
    """`fuera_de_servicio` -> `Fuera de servicio`. Vacio si no hay valor."""
    if not valor:
        return ""
    return valor.replace("_", " ").capitalize()


def si_no(valor: Optional[bool]) -> str:
    return "Si" if valor else "No"


def texto(valor: Optional[object]) -> str:
    """Convierte cualquier valor a texto; None queda vacio."""
    return "" if valor is None else str(valor)


def describir_filtros(**filtros: Optional[object]) -> str:
    """Resume los filtros aplicados, por ejemplo `Busqueda: ana | Rol: estudiante`.

    Los filtros sin valor se omiten. Si no hay ninguno, indica que no se filtro.
    """
    partes = [f"{nombre.replace('_', ' ').capitalize()}: {valor}" for nombre, valor in filtros.items() if valor not in (None, "")]
    return " | ".join(partes) if partes else "Sin filtros"
