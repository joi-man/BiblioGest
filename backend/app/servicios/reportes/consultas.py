"""Consultas de los reportes: filtran por fechas, estado y texto, sin modificar datos.

Las fechas llegan como dias (`date`) y se comparan en UTC, que es como se guardan:
`desde` incluye el dia completo desde las 00:00 y `hasta` incluye todo ese dia.
"""
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta
from typing import List, Optional, Sequence, Tuple

from sqlalchemy import or_, select
from sqlalchemy.orm import Session, selectinload
from sqlalchemy.sql import Select

from app.core.constantes_prestamo import PRESTAMO_VENCIDO
from app.core.hora_paraguay import inicio_de_dia_utc
from app.core.paginacion import paginar
from app.modelos.devolucion import Devolucion
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle
from app.modelos.usuario import Usuario
from app.servicios.prestamos import consulta_prestamo_servicio


@dataclass(frozen=True)
class FiltrosReporte:
    """Criterios que el personal puede aplicar a un reporte."""

    desde: Optional[date] = None
    hasta: Optional[date] = None
    estados: Sequence[str] = field(default_factory=tuple)
    condicion: Optional[str] = None
    texto: Optional[str] = None


def _inicio(dia: date) -> datetime:
    """Las fechas del filtro son dias de Paraguay: el dia empieza a las 03:00 UTC."""
    return inicio_de_dia_utc(dia)


def _fin_exclusivo(dia: date) -> datetime:
    """Primer instante despues del dia indicado (asi `hasta` incluye todo ese dia)."""
    return inicio_de_dia_utc(dia + timedelta(days=1))


def _en_rango(consulta: Select, columna, filtros: FiltrosReporte) -> Select:
    if filtros.desde:
        consulta = consulta.where(columna >= _inicio(filtros.desde))
    if filtros.hasta:
        consulta = consulta.where(columna < _fin_exclusivo(filtros.hasta))
    return consulta


def _texto(consulta: Select, filtros: FiltrosReporte) -> Select:
    if filtros.texto and filtros.texto.strip():
        consulta = consulta.where(consulta_prestamo_servicio.filtro_texto(filtros.texto))
    return consulta


# ---------------------------------------------------------------------------
# Prestamos
# ---------------------------------------------------------------------------
def consulta_prestamos(filtros: FiltrosReporte) -> Select:
    """Solicitudes y prestamos con fecha de solicitud en el rango, del mas reciente al mas antiguo."""
    consulta = consulta_prestamo_servicio.consulta_con_relaciones()
    if filtros.estados:
        consulta = consulta.where(PrestamoCabecera.estado.in_(filtros.estados))
    consulta = _en_rango(consulta, PrestamoCabecera.fecha_solicitud, filtros)
    consulta = _texto(consulta, filtros)
    return consulta.order_by(PrestamoCabecera.fecha_solicitud.desc(), PrestamoCabecera.id)


# ---------------------------------------------------------------------------
# Prestamos vencidos (RFC-G1)
# ---------------------------------------------------------------------------
def consulta_vencidos(filtros: FiltrosReporte) -> Select:
    """Prestamos vencidos cuya fecha limite cae en el rango, del mas atrasado al menos atrasado.

    La fecha limite de un prestamo es la mas proxima entre los items que aun no se devolvieron.
    """
    consulta = consulta_prestamo_servicio.consulta_con_relaciones().where(
        PrestamoCabecera.estado == PRESTAMO_VENCIDO
    )
    consulta = _en_rango(consulta, PrestamoCabecera.fecha_devolucion_esperada, filtros)
    consulta = _texto(consulta, filtros)
    return consulta.order_by(PrestamoCabecera.fecha_devolucion_esperada.asc(), PrestamoCabecera.id)


# ---------------------------------------------------------------------------
# Devoluciones
# ---------------------------------------------------------------------------
def consulta_devoluciones(filtros: FiltrosReporte) -> Select:
    """Devoluciones registradas en el rango, de la mas reciente a la mas antigua."""
    consulta = (
        select(Devolucion)
        .join(PrestamoDetalle, Devolucion.prestamo_detalle_id == PrestamoDetalle.id)
        .join(PrestamoCabecera, PrestamoDetalle.prestamo_cabecera_id == PrestamoCabecera.id)
        .join(Usuario, PrestamoCabecera.usuario_id == Usuario.id)
        .join(Material, PrestamoDetalle.material_id == Material.id)
        .where(Devolucion.eliminado == False)  # noqa: E712
        .options(
            selectinload(Devolucion.recibido_por),
            selectinload(Devolucion.prestamo_detalle).selectinload(PrestamoDetalle.material),
            selectinload(Devolucion.prestamo_detalle)
            .selectinload(PrestamoDetalle.prestamo_cabecera)
            .selectinload(PrestamoCabecera.usuario),
        )
    )
    if filtros.condicion:
        consulta = consulta.where(Devolucion.condicion == filtros.condicion)
    consulta = _en_rango(consulta, Devolucion.fecha_devolucion, filtros)
    if filtros.texto and filtros.texto.strip():
        patron = f"%{filtros.texto.strip()}%"
        consulta = consulta.where(
            or_(
                Usuario.nombre.ilike(patron),
                Usuario.apellido.ilike(patron),
                Usuario.username.ilike(patron),
                Usuario.numero_documento.ilike(patron),
                Material.titulo.ilike(patron),
                Material.codigo.ilike(patron),
            )
        )
    return consulta.order_by(Devolucion.fecha_devolucion.desc(), Devolucion.id)


def una_pagina(db: Session, consulta: Select, pagina: int, tamano: int) -> Tuple[List, int]:
    return paginar(db, consulta, pagina, tamano)


def todas(db: Session, consulta: Select, limite: int) -> List:
    """Hasta `limite` filas, para exportar."""
    return list(db.execute(consulta.limit(limite)).scalars().all())
