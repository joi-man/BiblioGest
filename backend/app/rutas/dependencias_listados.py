"""Dependencias y utilidades comunes de las rutas de listados."""
from dataclasses import dataclass

from fastapi import Query, Response

from app.esquemas.paginacion import (
    TAMANO_MAXIMO_PAGINA,
    TAMANO_PAGINA_DEFECTO,
    Pagina,
)
from app.core.paginacion import total_de_paginas
from app.servicios.exportacion.exportador import ArchivoExportado


@dataclass(frozen=True)
class ParametrosPagina:
    """Pagina pedida por el cliente (la primera pagina es la 1)."""

    pagina: int
    tamano: int


def parametros_pagina(
    pagina: int = Query(1, ge=1, description="Numero de pagina, desde 1"),
    tamano: int = Query(
        TAMANO_PAGINA_DEFECTO,
        ge=1,
        le=TAMANO_MAXIMO_PAGINA,
        description=f"Filas por pagina (maximo {TAMANO_MAXIMO_PAGINA})",
    ),
) -> ParametrosPagina:
    return ParametrosPagina(pagina=pagina, tamano=tamano)


def armar_pagina(items: list, total: int, parametros: ParametrosPagina) -> Pagina:
    """Combina las filas de una pagina con los datos de navegacion."""
    return Pagina(
        items=items,
        total=total,
        pagina=parametros.pagina,
        tamano=parametros.tamano,
        total_paginas=total_de_paginas(total, parametros.tamano),
    )


def respuesta_de_descarga(archivo: ArchivoExportado) -> Response:
    """Respuesta HTTP que el navegador descarga como archivo."""
    return Response(
        content=archivo.contenido,
        media_type=archivo.tipo_contenido,
        headers={"Content-Disposition": f'attachment; filename="{archivo.nombre}"'},
    )
