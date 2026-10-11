"""Utilidades pequeñas para trabajar con modelos SQLAlchemy."""
from typing import Any, Iterable


def aplicar_cambios(
    entidad: Any,
    cambios: dict[str, Any],
    campos_obligatorios: Iterable[str] = (),
) -> None:
    """Copia a `entidad` los campos de `cambios`.

    Un valor `None` solo se aplica a campos opcionales (permite vaciarlos); en
    los `campos_obligatorios` se ignora, porque la columna no admite nulos.
    """
    obligatorios = set(campos_obligatorios)
    for campo, valor in cambios.items():
        if valor is None and campo in obligatorios:
            continue
        setattr(entidad, campo, valor)
