"""Paginacion de consultas SQLAlchemy."""
from math import ceil
from typing import Any, List, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session
from sqlalchemy.sql import Select


def paginar(
    db: Session,
    consulta: Select,
    pagina: int,
    tamano: int,
) -> Tuple[List[Any], int]:
    """Devuelve las filas de una pagina y el total de filas de la consulta.

    `consulta` ya debe incluir filtros y orden. `pagina` empieza en 1.
    """
    total = db.execute(
        select(func.count()).select_from(consulta.order_by(None).subquery())
    ).scalar_one()

    desplazamiento = (pagina - 1) * tamano
    filas = db.execute(consulta.offset(desplazamiento).limit(tamano)).scalars().all()
    return list(filas), total


def total_de_paginas(total: int, tamano: int) -> int:
    """Cantidad de paginas necesarias para mostrar `total` filas."""
    return ceil(total / tamano) if total else 0
