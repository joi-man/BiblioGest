"""Avisos por correo al estudiante sobre sus solicitudes.

Cada funcion `aviso_*` arma el mensaje en el momento (con la sesion abierta) y
devuelve un `Aviso` simple; `enviar` lo manda despues de responder la peticion
(BackgroundTasks), asi un SMTP lento o caido nunca demora ni rompe la operacion.
"""
import logging
from app.core.hora_paraguay import a_paraguay
from dataclasses import dataclass
from typing import Optional

from app.core.config import configuracion
from app.core.database import es_modo_local
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.servicios import email_servicio

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class Aviso:
    destino: str
    asunto: str
    cuerpo: str


def _lista_materiales(prestamo: PrestamoCabecera) -> str:
    return "\n".join(f"  - {d.material.titulo} ({d.material.codigo})" for d in prestamo.detalles)


def _saludo(prestamo: PrestamoCabecera) -> str:
    return f"Hola {prestamo.usuario.nombre},\n\n"


def aviso_aprobacion(prestamo: PrestamoCabecera) -> Aviso:
    limite = prestamo.fecha_retiro_limite
    hasta = f" Tienes hasta el {a_paraguay(limite):%d/%m/%Y %H:%M} (hora de Paraguay) para retirarlo." if limite else ""
    return Aviso(
        destino=prestamo.usuario.correo_electronico,
        asunto="Tu solicitud fue aprobada - BiblioGest",
        cuerpo=(
            _saludo(prestamo)
            + "Aprobamos tu solicitud. Ya esta reservado para ti en la biblioteca:\n"
            + _lista_materiales(prestamo)
            + f"\n\nPasa a retirarlo.{hasta}"
        ),
    )


def aviso_rechazo(prestamo: PrestamoCabecera) -> Aviso:
    return Aviso(
        destino=prestamo.usuario.correo_electronico,
        asunto="Tu solicitud no fue aprobada - BiblioGest",
        cuerpo=(
            _saludo(prestamo)
            + "No pudimos aprobar tu solicitud de:\n"
            + _lista_materiales(prestamo)
            + f"\n\nMotivo: {prestamo.motivo_rechazo}\n\n"
            "Puedes volver a solicitarlo desde la aplicacion cuando quieras."
        ),
    )


def aviso_cesion(reserva: PrestamoCabecera) -> Aviso:
    return Aviso(
        destino=reserva.usuario.correo_electronico,
        asunto="Tu reserva fue cedida a otra persona - BiblioGest",
        cuerpo=(
            _saludo(reserva)
            + "Lamentamos avisarte que tu reserva de:\n"
            + _lista_materiales(reserva)
            + "\n\nse presto a otra persona por una razon importante.\n\n"
            f"Motivo: {reserva.motivo_rechazo}\n\n"
            "Puedes volver a solicitarlo desde la aplicacion en cuanto quede disponible."
        ),
    )


def enviar(aviso: Optional[Aviso]) -> None:
    """Envia el aviso. Nunca lanza: un correo fallido no debe afectar la operacion."""
    if aviso is None:
        return
    # El ejecutable de escritorio no lleva la clave del correo; los avisos salen del servidor.
    if es_modo_local() and not configuracion.SMTP_CLAVE:
        return
    try:
        email_servicio.enviar_correo(aviso.destino, aviso.asunto, aviso.cuerpo)
    except Exception:
        logger.exception("No se pudo enviar el aviso a %s", aviso.destino)
