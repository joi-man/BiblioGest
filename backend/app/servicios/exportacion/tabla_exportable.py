"""Estructura neutra de una tabla lista para exportar."""
from dataclasses import dataclass
from typing import List

# Tope de filas por archivo: un PDF o Excel gigante bloquearia el servidor.
MAX_FILAS_EXPORTACION = 5000


@dataclass(frozen=True)
class TablaExportable:
    """Titulo, encabezados y filas de texto de un listado.

    No sabe nada de Excel ni de PDF: cada exportador la convierte a su formato.
    """

    titulo: str
    columnas: List[str]
    filas: List[List[str]]
    # Texto bajo el titulo, por ejemplo los filtros aplicados.
    descripcion: str = ""
