"""Solicitudes de prestamo hechas por los usuarios y su cancelacion."""
from datetime import datetime, timedelta
from typing import Optional, Sequence
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.constantes_prestamo import (
    MAX_DIAS_RETIRO_ANTICIPADO,
    PRESTAMO_APROBADO,
    PRESTAMO_CANCELADO,
    PRESTAMO_PENDIENTE,
    TOLERANCIA_RELOJ_SEGUNDOS,
)
from app.core.constantes_roles import ROLES_PERSONAL
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.usuario import Usuario
from app.servicios.prestamos import (
    auditoria_prestamo,
    consulta_prestamo_servicio,
    maquina_estados,
    material_estado_servicio,
    prestamo_factory,
    reglas_prestamo,
)


def validar_fecha_retiro(fecha: datetime, ahora: datetime) -> None:
    """La fecha de retiro propuesta debe ser futura y no pasar de MAX_DIAS_RETIRO_ANTICIPADO dias."""
    if fecha < ahora - timedelta(seconds=TOLERANCIA_RELOJ_SEGUNDOS):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha y hora de retiro deben ser posteriores a este momento",
        )
    if fecha > ahora + timedelta(days=MAX_DIAS_RETIRO_ANTICIPADO):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Solo se puede reservar con hasta {MAX_DIAS_RETIRO_ANTICIPADO} dias de anticipacion",
        )


def crear_solicitud(
    db: Session,
    usuario: Usuario,
    material_ids: Sequence[UUID],
    observaciones: Optional[str] = None,
    fecha_retiro_solicitada: Optional[datetime] = None,
) -> PrestamoCabecera:
    """Registra una solicitud `pendiente` del usuario para los materiales indicados.

    Valida que el usuario pueda pedir (activo, sin vencidos, dentro del limite)
    y que los materiales sean prestables y esten disponibles. La solicitud aun
    no reserva las unidades: eso ocurre cuando el personal la aprueba.

    `fecha_retiro_solicitada` es cuando la persona dice que pasara a retirar; el
    personal la ve al revisar y la reserva se sostiene hasta esa hora mas un margen.
    """
    ahora = reloj.ahora_utc()
    if fecha_retiro_solicitada is not None:
        validar_fecha_retiro(fecha_retiro_solicitada, ahora)

    materiales = material_estado_servicio.bloquear_materiales(db, material_ids)
    reglas_prestamo.validar_materiales_para_solicitante(usuario, materiales)
    reglas_prestamo.validar_usuario_puede_pedir(db, usuario, len(materiales))
    reglas_prestamo.validar_materiales_disponibles(materiales)

    prestamo = prestamo_factory.nuevo_prestamo(
        usuario.id, materiales, PRESTAMO_PENDIENTE, ahora, observaciones
    )
    prestamo.fecha_retiro_solicitada = fecha_retiro_solicitada
    db.add(prestamo)
    db.flush()

    auditoria_prestamo.registrar(
        db, usuario, "SOLICITUD_CREADA", prestamo,
        {
            "materiales": [m.codigo for m in materiales],
            **(
                {"retiro_solicitado": fecha_retiro_solicitada.isoformat()}
                if fecha_retiro_solicitada
                else {}
            ),
        },
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo.id)


def cancelar(db: Session, prestamo_id: UUID, actor: Usuario) -> PrestamoCabecera:
    """Cancela una solicitud pendiente o una reserva aprobada.

    Puede hacerlo el propio usuario o el personal. Si la solicitud ya estaba
    aprobada, las unidades reservadas vuelven a quedar disponibles.
    """
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    es_personal = actor.rol in ROLES_PERSONAL
    if prestamo.usuario_id != actor.id and not es_personal:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No puedes cancelar la solicitud de otro usuario",
        )

    maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_CANCELADO)
    estaba_aprobado = prestamo.estado == PRESTAMO_APROBADO

    materiales = []
    if estaba_aprobado:
        materiales = material_estado_servicio.bloquear_materiales(
            db, [d.material_id for d in prestamo.detalles]
        )

    prestamo.estado = PRESTAMO_CANCELADO
    if estaba_aprobado:
        material_estado_servicio.recalcular(db, materiales, reloj.ahora_utc())  # libera la reserva
    auditoria_prestamo.registrar(db, actor, "PRESTAMO_CANCELADO", prestamo)
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)
