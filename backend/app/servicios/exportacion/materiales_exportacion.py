"""Arma la tabla exportable del inventario de materiales."""
from typing import Optional, Sequence

from app.modelos.material import Material
from app.servicios.exportacion.tabla_exportable import TablaExportable
from app.servicios.exportacion.texto_listado import describir_filtros, etiqueta, si_no, texto

COLUMNAS = [
    "Codigo",
    "Titulo",
    "Tipo",
    "Categoria",
    "Autor / Marca",
    "Modelo",
    "Serie",
    "Ubicacion",
    "Estado",
    "Condicion",
    "Prestable",
]


def _autor_o_marca(material: Material) -> str:
    """Libros muestran autor; los equipos, la marca."""
    return texto(material.autor or material.marca)


def tabla_de_materiales(
    materiales: Sequence[Material],
    busqueda: Optional[str] = None,
    tipo: Optional[str] = None,
    estado: Optional[str] = None,
    categoria: Optional[str] = None,
) -> TablaExportable:
    """Una fila por unidad fisica del inventario."""
    filas = [
        [
            m.codigo,
            m.titulo,
            etiqueta(m.tipo_material),
            m.categoria.nombre if m.categoria else "",
            _autor_o_marca(m),
            texto(m.modelo),
            texto(m.numero_serie),
            texto(m.ubicacion),
            etiqueta(m.estado),
            etiqueta(m.condicion),
            si_no(m.es_prestable),
        ]
        for m in materiales
    ]
    return TablaExportable(
        titulo="Inventario de BiblioGest",
        columnas=COLUMNAS,
        filas=filas,
        descripcion=describir_filtros(busqueda=busqueda, tipo=tipo, estado=estado, categoria=categoria)
        + f" | Total: {len(filas)}",
    )
