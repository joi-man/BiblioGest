"""Convierte las filas de cada reporte en texto legible (pantalla y archivos exportados)."""
from datetime import datetime
from typing import Optional, Sequence

from app.core import reloj
from app.core.config import configuracion
from app.modelos.devolucion import Devolucion
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.servicios.exportacion.tabla_exportable import TablaExportable
from app.servicios.exportacion.texto_listado import describir_filtros, etiqueta, texto
from app.servicios.reportes.consultas import FiltrosReporte

# Las fechas se guardan y se muestran en UTC (hora del servidor).
_FORMATO_FECHA = "%d/%m/%Y %H:%M"


def _fecha(valor: Optional[datetime]) -> str:
    return valor.strftime(_FORMATO_FECHA) if valor else ""


def _persona(prestamo: PrestamoCabecera) -> str:
    return f"{prestamo.usuario.nombre} {prestamo.usuario.apellido}"


def _materiales(prestamo: PrestamoCabecera, solo_pendientes: bool = False) -> str:
    detalles = [d for d in prestamo.detalles if not (solo_pendientes and d.devuelto)]
    return "; ".join(f"{d.material.titulo} ({d.material.codigo})" for d in detalles)


def _describir(filtros: FiltrosReporte, total: int, **extra: Optional[object]) -> str:
    rango = None
    if filtros.desde or filtros.hasta:
        rango = f"{filtros.desde.strftime('%d/%m/%Y') if filtros.desde else 'inicio'}" \
                f" a {filtros.hasta.strftime('%d/%m/%Y') if filtros.hasta else 'hoy'}"
    resumen = describir_filtros(rango=rango, busqueda=filtros.texto, **extra)
    return f"{resumen} | Total: {total} | Horas en UTC"


# ---------------------------------------------------------------------------
COLUMNAS_PRESTAMOS = [
    "Solicitud", "Persona", "Documento", "Materiales", "Estado",
    "Entrega", "Limite de devolucion", "Devolucion",
]


def tabla_de_prestamos(prestamos: Sequence[PrestamoCabecera], filtros: FiltrosReporte, total: int) -> TablaExportable:
    filas = [
        [
            _fecha(p.fecha_solicitud),
            _persona(p),
            p.usuario.numero_documento,
            _materiales(p),
            etiqueta(p.estado),
            _fecha(p.fecha_prestamo),
            _fecha(p.fecha_devolucion_esperada),
            _fecha(p.fecha_devolucion_real),
        ]
        for p in prestamos
    ]
    estados = ", ".join(etiqueta(e) for e in filtros.estados) or None
    return TablaExportable(
        titulo="Reporte de prestamos - BiblioGest",
        columnas=COLUMNAS_PRESTAMOS,
        filas=filas,
        descripcion=_describir(filtros, total, estado=estados),
    )


# ---------------------------------------------------------------------------
COLUMNAS_VENCIDOS = [
    "Persona", "Documento", "Correo", "Telefono", "Materiales pendientes",
    "Fecha limite", "Dias de atraso",
]


def _dias_de_atraso(limite: Optional[datetime]) -> str:
    """Dias completos de atraso; cualquier fraccion cuenta como un dia (igual que las multas)."""
    if limite is None:
        return ""
    segundos = (reloj.ahora_utc() - limite).total_seconds()
    return str(max(1, int(-(-segundos // 86400))))


def tabla_de_vencidos(prestamos: Sequence[PrestamoCabecera], filtros: FiltrosReporte, total: int) -> TablaExportable:
    filas = [
        [
            _persona(p),
            p.usuario.numero_documento,
            p.usuario.correo_electronico,
            texto(p.usuario.telefono),
            _materiales(p, solo_pendientes=True),
            _fecha(p.fecha_devolucion_esperada),
            _dias_de_atraso(p.fecha_devolucion_esperada),
        ]
        for p in prestamos
    ]
    return TablaExportable(
        titulo="Prestamos vencidos - BiblioGest",
        columnas=COLUMNAS_VENCIDOS,
        filas=filas,
        descripcion=_describir(filtros, total),
    )


# ---------------------------------------------------------------------------
def tabla_de_devoluciones(devoluciones: Sequence[Devolucion], filtros: FiltrosReporte, total: int) -> TablaExportable:
    # La multa solo existe cuando el sistema de multas esta activado.
    con_multa = configuracion.MULTAS_HABILITADAS
    columnas = ["Fecha", "Persona", "Documento", "Material", "Codigo", "Condicion", "Dias de retraso"]
    if con_multa:
        columnas.append("Multa")
    columnas.append("Recibio")

    filas = []
    for d in devoluciones:
        detalle = d.prestamo_detalle
        persona = detalle.prestamo_cabecera.usuario
        fila = [
            _fecha(d.fecha_devolucion),
            f"{persona.nombre} {persona.apellido}",
            persona.numero_documento,
            detalle.material.titulo,
            detalle.material.codigo,
            etiqueta(d.condicion),
            str(d.dias_retraso),
        ]
        if con_multa:
            fila.append(texto(d.multa_monto))
        fila.append(f"{d.recibido_por.nombre} {d.recibido_por.apellido}" if d.recibido_por else "")
        filas.append(fila)

    return TablaExportable(
        titulo="Reporte de devoluciones - BiblioGest",
        columnas=columnas,
        filas=filas,
        descripcion=_describir(filtros, total, condicion=etiqueta(filtros.condicion) or None),
    )
