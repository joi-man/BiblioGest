"""Cantidades y estado de un material segun sus prestamos.

Un material puede tener varios ejemplares (`cantidad_total`). Cuantos estan
reservados, prestados o vencidos no se lleva con contadores que suben y bajan:
se **recalcula** contando los items de prestamo vigentes (ver `recalcular`).
Asi el dato no se desajusta aunque falle una operacion o se sincronice un equipo.
"""
from datetime import datetime
from typing import Iterable, List, Sequence
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
from app.core.constantes_prestamo import (
    CONDICIONES_QUE_INHABILITAN,
    CONDICION_DANO_MENOR,
    PRESTAMO_ACTIVO,
    PRESTAMO_APROBADO,
    PRESTAMO_VENCIDO,
)
from app.modelos.devolucion import Devolucion
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle


def bloquear_materiales(db: Session, material_ids: Iterable[UUID]) -> List[Material]:
    """Obtiene los materiales bloqueando sus filas hasta el fin de la transaccion.

    El bloqueo evita que dos personas reserven el ultimo ejemplar a la vez. Se
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


def exigir_disponible(material: Material) -> None:
    """Lanza 409 si no queda ningun ejemplar disponible."""
    if not material.es_prestable:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"'{material.titulo}' ({material.codigo}) es solo para consulta en sala",
        )
    if material.cantidad_disponible < 1:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"'{material.titulo}' ({material.codigo}) no tiene ejemplares disponibles "
                f"(estado: {material.estado})"
            ),
        )


def derivar_estado(material: Material) -> str:
    """Estado a mostrar: disponible mientras quede un ejemplar; si no, el mas urgente."""
    if material.cantidad_disponible > 0:
        return ESTADO_DISPONIBLE
    if material.cantidad_vencida > 0:
        return ESTADO_VENCIDO
    if material.cantidad_prestada > 0:
        return ESTADO_PRESTADO
    if material.cantidad_reservada > 0:
        return ESTADO_RESERVADO
    return ESTADO_FUERA_DE_SERVICIO


def recalcular(db: Session, materiales: Sequence[Material], ahora: datetime) -> None:
    """Cuenta los ejemplares reservados, prestados y vencidos de cada material.

    Mira los items de prestamo que todavia no se devolvieron: en una reserva
    aprobada cuentan como reservados; en un prestamo entregado, como prestados
    o vencidos si ya pasaron de plazo. Despues deja el estado al dia. No
    confirma la transaccion.
    """
    if not materiales:
        return
    db.flush()  # los cambios de prestamos de esta operacion aun no estan en la base

    consulta = (
        select(
            PrestamoDetalle.material_id,
            PrestamoCabecera.estado,
            PrestamoDetalle.fecha_devolucion_esperada,
        )
        .join(PrestamoCabecera, PrestamoCabecera.id == PrestamoDetalle.prestamo_cabecera_id)
        .where(
            PrestamoDetalle.material_id.in_([m.id for m in materiales]),
            PrestamoDetalle.eliminado == False,  # noqa: E712
            PrestamoCabecera.eliminado == False,  # noqa: E712
            PrestamoCabecera.estado.in_((PRESTAMO_APROBADO, PRESTAMO_ACTIVO, PRESTAMO_VENCIDO)),
            ~PrestamoDetalle.devolucion.has(Devolucion.eliminado == False),  # noqa: E712
        )
    )
    cuentas = {m.id: [0, 0, 0] for m in materiales}  # reservada, prestada, vencida
    for material_id, estado, fecha_limite in db.execute(consulta).all():
        if estado == PRESTAMO_APROBADO:
            cuentas[material_id][0] += 1
        elif fecha_limite is not None and fecha_limite < ahora:
            cuentas[material_id][2] += 1
        else:
            cuentas[material_id][1] += 1

    for material in materiales:
        reservada, prestada, vencida = cuentas[material.id]
        material.cantidad_reservada = reservada
        material.cantidad_prestada = prestada
        material.cantidad_vencida = vencida
        material.estado = derivar_estado(material)


def recibir(material: Material, condicion: str) -> None:
    """Anota la condicion en que vuelve un ejemplar. Luego hay que llamar a `recalcular`.

    - Danos mayores o perdida: ese ejemplar queda fuera de servicio.
    - Dano menor: vuelve a estar disponible.
    Si el material tiene un solo ejemplar, su condicion fisica tambien se actualiza.
    """
    un_solo_ejemplar = material.cantidad_total == 1
    if condicion in CONDICIONES_QUE_INHABILITAN:
        material.cantidad_fuera_servicio = min(
            material.cantidad_total, material.cantidad_fuera_servicio + 1
        )
        if un_solo_ejemplar:
            material.condicion = "malo"
    elif condicion == CONDICION_DANO_MENOR and un_solo_ejemplar:
        material.condicion = "regular"
