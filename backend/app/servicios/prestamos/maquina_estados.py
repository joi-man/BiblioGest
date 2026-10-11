"""Maquina de estados de un prestamo.

    pendiente --aprobar--> aprobado --entregar--> activo <--> vencido --> devuelto
        |                     |                      \\--------------------^
    rechazar/cancelar     cancelar
"""
from fastapi import HTTPException, status

from app.core.constantes_prestamo import (
    PRESTAMO_ACTIVO,
    PRESTAMO_APROBADO,
    PRESTAMO_CANCELADO,
    PRESTAMO_DEVUELTO,
    PRESTAMO_PENDIENTE,
    PRESTAMO_RECHAZADO,
    PRESTAMO_VENCIDO,
)

# Para cada estado, los estados a los que se puede pasar.
TRANSICIONES: dict[str, frozenset[str]] = {
    PRESTAMO_PENDIENTE: frozenset({PRESTAMO_APROBADO, PRESTAMO_RECHAZADO, PRESTAMO_CANCELADO}),
    PRESTAMO_APROBADO: frozenset({PRESTAMO_ACTIVO, PRESTAMO_CANCELADO}),
    PRESTAMO_ACTIVO: frozenset({PRESTAMO_VENCIDO, PRESTAMO_DEVUELTO}),
    PRESTAMO_VENCIDO: frozenset({PRESTAMO_ACTIVO, PRESTAMO_DEVUELTO}),
    PRESTAMO_RECHAZADO: frozenset(),
    PRESTAMO_CANCELADO: frozenset(),
    PRESTAMO_DEVUELTO: frozenset(),
}


def puede_pasar(origen: str, destino: str) -> bool:
    """Indica si un prestamo en `origen` puede pasar al estado `destino`."""
    return destino in TRANSICIONES.get(origen, frozenset())


def validar_transicion(origen: str, destino: str) -> None:
    """Lanza 409 si el cambio de estado no esta permitido."""
    if not puede_pasar(origen, destino):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"No se puede pasar un prestamo de '{origen}' a '{destino}'",
        )
