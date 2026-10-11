"""Esquemas comunes para listados paginados."""
from typing import Generic, List, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")

# Tope de filas por pagina: evita que un cliente pida toda la tabla de golpe.
TAMANO_MAXIMO_PAGINA = 100
TAMANO_PAGINA_DEFECTO = 10


class Pagina(BaseModel, Generic[T]):
    """Una pagina de resultados junto con los datos para navegar el resto."""

    items: List[T]
    total: int = Field(..., description="Cantidad de filas que cumplen el filtro, en todas las paginas")
    pagina: int = Field(..., description="Numero de pagina actual, desde 1")
    tamano: int = Field(..., description="Filas por pagina")
    total_paginas: int = Field(..., description="Cantidad de paginas (0 si no hay resultados)")
