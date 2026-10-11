"""Reglas de negocio que debe cumplir un usuario o material para prestarse."""
from typing import Sequence

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import configuracion
from app.core.constantes_inventario import ESTADO_DISPONIBLE
from app.core.constantes_prestamo import (
    ESTADOS_QUE_OCUPAN_UNIDADES,
    PRESTAMO_PENDIENTE,
    PRESTAMO_VENCIDO,
)
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle
from app.modelos.usuario import Usuario

# Estados cuyos items cuentan contra el limite del usuario: lo que ya tiene
# reservado o en su poder, mas lo que tiene pendiente de revision.
_ESTADOS_PARA_LIMITE = (PRESTAMO_PENDIENTE, *ESTADOS_QUE_OCUPAN_UNIDADES)


def _conflicto(detalle: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detalle)


def validar_usuario_activo(usuario: Usuario) -> None:
    """El usuario debe existir, estar activo y no estar eliminado."""
    if usuario.eliminado or not usuario.activo:
        raise _conflicto("El usuario esta desactivado y no puede solicitar prestamos")


def contar_items_del_usuario(db: Session, usuario_id) -> int:
    """Cuenta los items sin devolver que el usuario tiene reservados, prestados o pendientes."""
    consulta = (
        select(func.count(PrestamoDetalle.id))
        .join(PrestamoCabecera, PrestamoCabecera.id == PrestamoDetalle.prestamo_cabecera_id)
        .where(
            PrestamoCabecera.usuario_id == usuario_id,
            PrestamoCabecera.estado.in_(_ESTADOS_PARA_LIMITE),
            PrestamoCabecera.eliminado == False,  # noqa: E712
            PrestamoDetalle.devolucion == None,  # noqa: E711
        )
    )
    return db.execute(consulta).scalar_one()


def tiene_prestamos_vencidos(db: Session, usuario_id) -> bool:
    """Indica si el usuario tiene algun prestamo vencido sin resolver."""
    consulta = select(func.count(PrestamoCabecera.id)).where(
        PrestamoCabecera.usuario_id == usuario_id,
        PrestamoCabecera.estado == PRESTAMO_VENCIDO,
        PrestamoCabecera.eliminado == False,  # noqa: E712
    )
    return db.execute(consulta).scalar_one() > 0


def validar_usuario_puede_pedir(db: Session, usuario: Usuario, cantidad_nueva: int) -> None:
    """Verifica que el usuario pueda pedir `cantidad_nueva` items mas.

    Aplica: usuario activo, sin prestamos vencidos (si esta configurado) y sin
    superar el maximo de items simultaneos.
    """
    validar_usuario_activo(usuario)

    if configuracion.BLOQUEAR_SI_HAY_VENCIDOS and tiene_prestamos_vencidos(db, usuario.id):
        raise _conflicto("El usuario tiene prestamos vencidos y debe devolverlos primero")

    actuales = contar_items_del_usuario(db, usuario.id)
    maximo = configuracion.MAX_PRESTAMOS_ACTIVOS
    if actuales + cantidad_nueva > maximo:
        raise _conflicto(
            f"Se supera el maximo de {maximo} items simultaneos "
            f"(el usuario ya tiene {actuales})"
        )


def validar_materiales_disponibles(materiales: Sequence[Material]) -> None:
    """Cada material debe ser prestable y estar disponible en este momento."""
    for material in materiales:
        if not material.es_prestable:
            raise _conflicto(
                f"'{material.titulo}' ({material.codigo}) es solo para consulta en sala"
            )
        if material.estado != ESTADO_DISPONIBLE:
            raise _conflicto(
                f"'{material.titulo}' ({material.codigo}) no esta disponible "
                f"(estado: {material.estado})"
            )
