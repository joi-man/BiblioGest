"""Recalculo del estado de un prestamo a partir de sus items pendientes."""
from datetime import datetime
from typing import Optional

from app.core.constantes_prestamo import (
    PRESTAMO_ACTIVO,
    PRESTAMO_DEVUELTO,
    PRESTAMO_VENCIDO,
)
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.servicios.prestamos import maquina_estados


def recalcular(
    prestamo: PrestamoCabecera,
    ahora: datetime,
    fecha_devolucion_real: Optional[datetime] = None,
) -> None:
    """Deja el prestamo en el estado que corresponde a sus items.

    - Sin items pendientes -> `devuelto`.
    - Algun item pendiente pasado de plazo -> `vencido`.
    - En otro caso -> `activo`.

    Tambien actualiza `fecha_devolucion_esperada` con la fecha mas proxima de
    los items que aun no se devolvieron. Solo debe llamarse sobre prestamos ya
    entregados (activos, vencidos o que se acaban de entregar). Si el prestamo
    se completa, `fecha_devolucion_real` (por defecto `ahora`) es la fecha anotada.
    """
    pendientes = [d for d in prestamo.detalles if not d.devuelto]

    if not pendientes:
        nuevo_estado = PRESTAMO_DEVUELTO
        prestamo.fecha_devolucion_real = fecha_devolucion_real or ahora
    else:
        prestamo.fecha_devolucion_esperada = min(
            d.fecha_devolucion_esperada for d in pendientes
        )
        hay_vencidos = any(d.fecha_devolucion_esperada < ahora for d in pendientes)
        nuevo_estado = PRESTAMO_VENCIDO if hay_vencidos else PRESTAMO_ACTIVO

    if nuevo_estado != prestamo.estado:
        maquina_estados.validar_transicion(prestamo.estado, nuevo_estado)
        prestamo.estado = nuevo_estado
