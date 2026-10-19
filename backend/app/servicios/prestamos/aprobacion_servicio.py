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


def _limite_de_retiro(prestamo: PrestamoCabecera, ahora: datetime) -> datetime:
    """Hasta cuando se sostiene la reserva.

    Si la persona indico cuando va a retirar, es esa hora (o ahora, si ya paso) mas
    un margen corto; si no, el plazo general desde la aprobacion.
    """
    prevista = prestamo.fecha_retiro_solicitada
    if prevista is None:
        return ahora + timedelta(hours=configuracion.HORAS_RETIRO_RESERVA)
    return max(prevista, ahora) + timedelta(hours=configuracion.HORAS_GRACIA_RETIRO_PROGRAMADO)


def aplicar_aprobacion(
    db: Session,
    prestamo: PrestamoCabecera,
    personal: Usuario,
    ahora: datetime,
) -> None:
    """Reserva un ejemplar de cada material y marca la solicitud como `aprobado`. No confirma la transaccion.

    Se separa de `aprobar` para que la entrega pueda aprobar y entregar en un
    solo paso (ver entrega_servicio).
    """
    maquina_estados.validar_transicion(prestamo.estado, PRESTAMO_APROBADO)

    materiales = material_estado_servicio.bloquear_materiales(
        db, [d.material_id for d in prestamo.detalles]
    )
    reglas_prestamo.validar_materiales_disponibles(materiales)

    prestamo.estado = PRESTAMO_APROBADO
    prestamo.aprobado_por_id = personal.id
    prestamo.fecha_retiro_limite = _limite_de_retiro(prestamo, ahora)
    material_estado_servicio.recalcular(db, materiales, ahora)  # los ejemplares quedan reservados


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
