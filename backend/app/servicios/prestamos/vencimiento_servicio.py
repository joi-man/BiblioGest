"""Vencimientos: reservas que expiran y prestamos que pasan de plazo.

No hay tareas programadas: este modulo se ejecuta antes de cada consulta de
prestamos (ver la dependencia de las rutas), asi el estado siempre esta al dia.
"""
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.constantes_prestamo import PRESTAMO_ACTIVO, PRESTAMO_APROBADO, PRESTAMO_CANCELADO
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.servicios.prestamos import (
    estado_prestamo_servicio,
    maquina_estados,
    material_estado_servicio,
)

MOTIVO_RESERVA_EXPIRADA = "La reserva no se retiro a tiempo"


def _expirar_reservas(db: Session, ahora: datetime) -> int:
    """Cancela las reservas aprobadas cuyo plazo de retiro ya paso y libera sus unidades."""
    consulta = (
        select(PrestamoCabecera)
        .where(
            PrestamoCabecera.estado == PRESTAMO_APROBADO,
            PrestamoCabecera.fecha_retiro_limite < ahora,
            PrestamoCabecera.eliminado == False,  # noqa: E712
        )
        .with_for_update(skip_locked=True)
    )
    reservas = list(db.execute(consulta).scalars().all())

    for prestamo in reservas:
        maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_CANCELADO)
        for detalle in prestamo.detalles:
            material_estado_servicio.liberar(detalle.material)
        prestamo.estado = PRESTAMO_CANCELADO
        prestamo.motivo_rechazo = MOTIVO_RESERVA_EXPIRADA
    return len(reservas)


def _marcar_vencidos(db: Session, ahora: datetime) -> int:
    """Marca como vencidos los prestamos activos con algun item pasado de plazo."""
    consulta = (
        select(PrestamoCabecera)
        .where(
            PrestamoCabecera.estado == PRESTAMO_ACTIVO,
            PrestamoCabecera.fecha_devolucion_esperada < ahora,
            PrestamoCabecera.eliminado == False,  # noqa: E712
        )
        .with_for_update(skip_locked=True)
    )
    prestamos = list(db.execute(consulta).scalars().all())

    for prestamo in prestamos:
        for detalle in prestamo.detalles:
            if not detalle.devuelto and detalle.fecha_devolucion_esperada < ahora:
                material_estado_servicio.marcar_vencido(detalle.material)
        estado_prestamo_servicio.recalcular(prestamo, ahora)
    return len(prestamos)


def actualizar_vencimientos(db: Session) -> int:
    """Expira reservas y marca vencidos. Devuelve cuantos prestamos cambiaron."""
    ahora = reloj.ahora_utc()
    cambios = _expirar_reservas(db, ahora) + _marcar_vencidos(db, ahora)
    if cambios:
        db.commit()
    return cambios
