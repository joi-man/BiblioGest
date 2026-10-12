"""Cesion de una reserva aprobada a otra persona, por una razon importante."""
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.constantes_prestamo import PRESTAMO_APROBADO, PRESTAMO_CANCELADO
from app.esquemas.prestamo_cabecera import CesionPeticion, PrestamoDirectoCrear
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.usuario import Usuario
from app.servicios.prestamos import (
    auditoria_prestamo,
    consulta_prestamo_servicio,
    entrega_servicio,
    maquina_estados,
    material_estado_servicio,
)


def ceder_reserva(
    db: Session,
    prestamo_id: UUID,
    personal: Usuario,
    datos: CesionPeticion,
) -> tuple[PrestamoCabecera, PrestamoCabecera]:
    """Cancela una reserva aprobada y presta sus materiales a otra persona.

    Devuelve `(reserva_cancelada, prestamo_nuevo)`. Todo ocurre en una sola
    transaccion: si el nuevo prestamo no es posible (usuario con vencidos, tope
    de items...), la reserva original queda intacta. El motivo queda en la
    reserva cancelada (`motivo_rechazo`), que es lo que ve quien reservo.
    """
    reserva = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    if reserva.estado != PRESTAMO_APROBADO:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Solo se puede ceder una reserva aprobada que aun no se retiro",
        )
    if reserva.usuario_id == datos.usuario_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La reserva ya es de esa persona",
        )

    maquina_estados.validar_transicion(reserva.estado, PRESTAMO_CANCELADO)
    material_ids = [d.material_id for d in reserva.detalles]
    for material in material_estado_servicio.bloquear_materiales(db, material_ids):
        material_estado_servicio.liberar(material)

    reserva.estado = PRESTAMO_CANCELADO
    reserva.motivo_rechazo = datos.motivo
    auditoria_prestamo.registrar(
        db, personal, "RESERVA_CEDIDA", reserva,
        {"motivo": datos.motivo, "cedida_a": str(datos.usuario_id)},
    )
    db.flush()

    try:
        nuevo = entrega_servicio.registrar_directo(
            db,
            personal,
            PrestamoDirectoCrear(
                usuario_id=datos.usuario_id,
                material_ids=material_ids,
                observaciones=f"Reserva cedida: {datos.motivo}"[:500],
                fecha_devolucion_esperada=datos.fecha_devolucion_esperada,
                omitir_validaciones_usuario=datos.omitir_validaciones_usuario,
            ),
            accion="PRESTAMO_POR_CESION",
            detalles_extra={"reserva_origen": str(reserva.id)},
        )
    except HTTPException:
        # El nuevo prestamo no es posible: la reserva original debe quedar como estaba.
        db.rollback()
        raise
    db.commit()
    return (
        consulta_prestamo_servicio.obtener_prestamo(db, reserva.id),
        consulta_prestamo_servicio.obtener_prestamo(db, nuevo.id),
    )
