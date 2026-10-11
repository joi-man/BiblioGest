"""Aprobacion y rechazo de solicitudes por parte del personal."""
from datetime import datetime, timedelta
from uuid import UUID

from sqlalchemy.orm import Session

from app.core import reloj
from app.core.config import configuracion
from app.core.constantes_prestamo import PRESTAMO_APROBADO, PRESTAMO_RECHAZADO
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.usuario import Usuario
from app.servicios.prestamos import (
    auditoria_prestamo,
    consulta_prestamo_servicio,
    maquina_estados,
    material_estado_servicio,
    reglas_prestamo,
)


def aplicar_aprobacion(
    db: Session,
    prestamo: PrestamoCabecera,
    personal: Usuario,
    ahora: datetime,
) -> None:
    """Reserva las unidades y marca la solicitud como `aprobado`. No confirma la transaccion.

    Se separa de `aprobar` para que la entrega pueda aprobar y entregar en un
    solo paso (ver entrega_servicio).
    """
    maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_APROBADO)

    materiales = material_estado_servicio.bloquear_materiales(
        db, [d.material_id for d in prestamo.detalles]
    )
    reglas_prestamo.validar_materiales_disponibles(materiales)
    for material in materiales:
        material_estado_servicio.reservar(material)

    prestamo.estado = PRESTAMO_APROBADO
    prestamo.aprobado_por_id = personal.id
    prestamo.fecha_retiro_limite = ahora + timedelta(hours=configuracion.HORAS_RETIRO_RESERVA)


def aprobar(db: Session, prestamo_id: UUID, personal: Usuario) -> PrestamoCabecera:
    """Aprueba una solicitud pendiente: reserva las unidades y fija el plazo de retiro."""
    ahora = reloj.ahora_utc()
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    aplicar_aprobacion(db, prestamo, personal, ahora)
    auditoria_prestamo.registrar(
        db, personal, "SOLICITUD_APROBADA", prestamo,
        {"retiro_hasta": prestamo.fecha_retiro_limite.isoformat()},
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)


def rechazar(db: Session, prestamo_id: UUID, personal: Usuario, motivo: str) -> PrestamoCabecera:
    """Rechaza una solicitud pendiente indicando el motivo."""
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_RECHAZADO)
    prestamo.estado = PRESTAMO_RECHAZADO
    prestamo.motivo_rechazo = motivo

    auditoria_prestamo.registrar(
        db, personal, "SOLICITUD_RECHAZADA", prestamo, {"motivo": motivo}
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)
