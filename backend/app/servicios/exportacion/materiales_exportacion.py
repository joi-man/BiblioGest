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
    "Ejemplares",
    "Estado",
    "Condicion",
    "Prestable",
]


def _titulo(material: Material) -> str:
    """El titulo, con el tomo si la obra tiene varios."""
    if not material.tomo:
        return material.titulo
    total = f" de {material.total_tomos}" if material.total_tomos else ""
    return f"{material.titulo} (Tomo {material.tomo}{total})"


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
    """Una fila por material, con sus ejemplares disponibles y totales."""
    filas = [
        [
            m.codigo,
            _titulo(m),
            etiqueta(m.tipo_material),
            m.categoria.nombre if m.categoria else "",
            _autor_o_marca(m),
            texto(m.modelo),
            texto(m.numero_serie),
            texto(m.ubicacion),
            f"{m.cantidad_disponible} de {m.cantidad_total}",
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
