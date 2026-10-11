"""Lecturas y filtros de prestamos. Este modulo no modifica datos."""
from typing import List, Optional, Sequence
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import exists, or_, select
from sqlalchemy.orm import Session, selectinload

from app.core.constantes_prestamo import ESTADOS_EN_CURSO
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle
from app.modelos.usuario import Usuario

# Maximo de filas que devuelve un listado.
LIMITE_LISTADO = 200


def _consulta_base():
    """Consulta de prestamos no eliminados con todas sus relaciones precargadas."""
    return (
        select(PrestamoCabecera)
        .where(PrestamoCabecera.eliminado == False)  # noqa: E712
        .options(
            selectinload(PrestamoCabecera.usuario),
            selectinload(PrestamoCabecera.aprobado_por),
            selectinload(PrestamoCabecera.entregado_por),
            selectinload(PrestamoCabecera.detalles).selectinload(PrestamoDetalle.material),
            selectinload(PrestamoCabecera.detalles).selectinload(PrestamoDetalle.devolucion),
        )
    )


def _filtro_texto(texto: str):
    """Condicion que busca el texto en el usuario o en los materiales del prestamo."""
    patron = f"%{texto.strip()}%"
    del_usuario = exists().where(
        Usuario.id == PrestamoCabecera.usuario_id,
        or_(
            Usuario.nombre.ilike(patron),
            Usuario.apellido.ilike(patron),
            Usuario.username.ilike(patron),
            Usuario.numero_documento.ilike(patron),
        ),
    )
    de_un_material = exists().where(
        PrestamoDetalle.prestamo_cabecera_id == PrestamoCabecera.id,
        Material.id == PrestamoDetalle.material_id,
        or_(Material.titulo.ilike(patron), Material.codigo.ilike(patron)),
    )
    return or_(del_usuario, de_un_material)


def listar_prestamos(
    db: Session,
    estados: Optional[Sequence[str]] = None,
    usuario_id: Optional[UUID] = None,
    texto: Optional[str] = None,
    mas_antiguos_primero: bool = False,
) -> List[PrestamoCabecera]:
    """Lista prestamos con filtros opcionales por estado, usuario y texto libre."""
    consulta = _consulta_base()

    if estados:
        consulta = consulta.where(PrestamoCabecera.estado.in_(estados))
    if usuario_id:
        consulta = consulta.where(PrestamoCabecera.usuario_id == usuario_id)
    if texto and texto.strip():
        consulta = consulta.where(_filtro_texto(texto))

    orden = PrestamoCabecera.fecha_solicitud
    consulta = consulta.order_by(orden.asc() if mas_antiguos_primero else orden.desc())
    return list(db.execute(consulta.limit(LIMITE_LISTADO)).scalars().all())


def listar_pendientes_de_devolucion(db: Session, texto: Optional[str] = None) -> List[PrestamoCabecera]:
    """Prestamos con material en manos del usuario (activos y vencidos), los mas urgentes primero."""
    consulta = _consulta_base().where(PrestamoCabecera.estado.in_(ESTADOS_EN_CURSO))
    if texto and texto.strip():
        consulta = consulta.where(_filtro_texto(texto))
    consulta = consulta.order_by(PrestamoCabecera.fecha_devolucion_esperada.asc())
    return list(db.execute(consulta.limit(LIMITE_LISTADO)).scalars().all())


def obtener_prestamo(db: Session, prestamo_id: UUID) -> PrestamoCabecera:
    """Obtiene un prestamo con sus relaciones. Lanza 404 si no existe."""
    consulta = _consulta_base().where(PrestamoCabecera.id == prestamo_id)
    prestamo = db.execute(consulta).scalar_one_or_none()
    if prestamo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prestamo no encontrado",
        )
    return prestamo


def obtener_prestamo_bloqueado(db: Session, prestamo_id: UUID) -> PrestamoCabecera:
    """Obtiene un prestamo bloqueando su fila para modificarlo sin carreras.

    Lanza 404 si no existe. Las relaciones se cargan despues, al accederlas.
    """
    consulta = (
        select(PrestamoCabecera)
        .where(PrestamoCabecera.id == prestamo_id, PrestamoCabecera.eliminado == False)  # noqa: E712
        .with_for_update()
    )
    prestamo = db.execute(consulta).scalar_one_or_none()
    if prestamo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prestamo no encontrado",
        )
    return prestamo
