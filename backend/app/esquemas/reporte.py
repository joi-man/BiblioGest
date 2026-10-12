"""Esquema de un reporte paginado: tabla de texto lista para mostrar."""
from typing import List

from pydantic import BaseModel, Field


class ReportePagina(BaseModel):
    """Una pagina de un reporte, con sus encabezados, para dibujarla sin conocer el reporte."""

    titulo: str
    descripcion: str = Field(..., description="Filtros aplicados y total")
    columnas: List[str]
    filas: List[List[str]]
    total: int = Field(..., description="Filas que cumplen el filtro, en todas las paginas")
    pagina: int
    tamano: int
    total_paginas: int
