"""Bloqueo y cambios de estado de las unidades de material durante un prestamo."""
from typing import Iterable, List
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.constantes_inventario import (
    ESTADO_DISPONIBLE,
    ESTADO_FUERA_DE_SERVICIO,
    ESTADO_PRESTADO,
    ESTADO_RESERVADO,
    ESTADO_VENCIDO,
)
from app.core.constantes_prestamo import CONDICIONES_QUE_INHABILITAN, CONDICION_DANO_MENOR
from app.modelos.material import Material


def bloquear_materiales(db: Session, material_ids: Iterable[UUID]) -> List[Material]:
    """Obtiene los materiales bloqueando sus filas hasta el fin de la transaccion.

    El bloqueo evita que dos personas reserven la misma unidad a la vez. Se
    ordenan por ID para que dos transacciones nunca se bloqueen entre si.
    Lanza 404 si alguno no existe.
    """
    ids = list(dict.fromkeys(material_ids))  # sin repetidos, conservando el orden
    consulta = (
        select(Material)
        .where(Material.id.in_(ids), Material.eliminado == False)  # noqa: E712
        .order_by(Material.id)
        .with_for_update()
    )
    materiales = list(db.execute(consulta).scalars().all())

    if len(materiales) != len(ids):
        encontrados = {m.id for m in materiales}
        faltantes = [str(i) for i in ids if i not in encontrados]
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Material no encontrado: {', '.join(faltantes)}",
        )
    return materiales


def _exigir_estado(material: Material, permitidos: tuple[str, ...], accion: str) -> None:
    """Lanza 409 si la unidad no esta en alguno de los estados esperados."""
    if material.estado not in permitidos:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"No se puede {accion} '{material.titulo}' ({material.codigo}): "
                f"su estado es '{material.estado}'"
            ),
        )


def reservar(material: Material) -> None:
    """disponible -> reservado (solicitud aprobada, pendiente de retiro)."""
    _exigir_estado(material, (ESTADO_DISPONIBLE,), "reservar")
    material.estado = ESTADO_RESERVADO


def liberar(material: Material) -> None:
    """reservado -> disponible (la reserva se cancela o expira)."""
    if material.estado == ESTADO_RESERVADO:
        material.estado = ESTADO_DISPONIBLE


def entregar(material: Material) -> None:
    """reservado -> prestado (el usuario retira el material)."""
    _exigir_estado(material, (ESTADO_RESERVADO,), "entregar")
    material.estado = ESTADO_PRESTADO


def entregar_directo(material: Material) -> None:
    """disponible -> prestado (prestamo en mostrador sin reserva previa)."""
    _exigir_estado(material, (ESTADO_DISPONIBLE,), "prestar")
    material.estado = ESTADO_PRESTADO


def marcar_vencido(material: Material) -> None:
    """prestado -> vencido (paso el plazo de devolucion)."""
    if material.estado == ESTADO_PRESTADO:
        material.estado = ESTADO_VENCIDO


def recibir(material: Material, condicion: str) -> None:
    """Deja la unidad lista tras una devolucion segun la condicion en que llega.

    - Danos mayores o perdida: queda fuera de servicio y con condicion 'malo'.
    - Dano menor: vuelve a estar disponible con condicion 'regular'.
    - Buen estado: vuelve a estar disponible sin cambios.
    """
    _exigir_estado(material, (ESTADO_PRESTADO, ESTADO_VENCIDO), "recibir")
    if condicion in CONDICIONES_QUE_INHABILITAN:
        material.estado = ESTADO_FUERA_DE_SERVICIO
        material.condicion = "malo"
        return
    if condicion == CONDICION_DANO_MENOR:
        material.condicion = "regular"
    material.estado = ESTADO_DISPONIBLE
