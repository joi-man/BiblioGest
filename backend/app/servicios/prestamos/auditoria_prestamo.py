"""Registro en la bitacora de las acciones sobre prestamos."""
from typing import Any, Optional

from sqlalchemy.orm import Session

from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio


def registrar(
    db: Session,
    actor: Usuario,
    accion: str,
    prestamo: PrestamoCabecera,
    detalles: Optional[dict[str, Any]] = None,
) -> None:
    """Agrega la accion a la bitacora SIN confirmar la transaccion.

    El llamador hace un unico commit al terminar, de modo que el cambio de
    datos y su auditoria se guardan juntos o no se guardan.
    """
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=actor.id,
        accion=accion,
        tabla_afectada="prestamos_cabecera",
        registro_id=prestamo.id,
        detalles={"estado": prestamo.estado, **(detalles or {})},
        confirmar=False,
    )
