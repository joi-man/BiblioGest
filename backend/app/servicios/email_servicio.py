import logging
import smtplib
from email.message import EmailMessage

from app.core.config import configuracion

logger = logging.getLogger(__name__)


def enviar_correo(destino: str, asunto: str, cuerpo: str) -> bool:
    """Enviar un correo de texto plano por SMTP (STARTTLS). Devuelve True si se envio."""
    if not configuracion.SMTP_USUARIO or not configuracion.SMTP_CLAVE:
        logger.error("SMTP no configurado: defina SMTP_USUARIO y SMTP_CLAVE")
        return False

    mensaje = EmailMessage()
    mensaje["Subject"] = asunto
    mensaje["From"] = configuracion.SMTP_REMITENTE or configuracion.SMTP_USUARIO
    mensaje["To"] = destino
    mensaje.set_content(cuerpo)

    try:
        with smtplib.SMTP(configuracion.SMTP_HOST, configuracion.SMTP_PUERTO, timeout=15) as servidor:
            servidor.starttls()
            servidor.login(configuracion.SMTP_USUARIO, configuracion.SMTP_CLAVE)
            servidor.send_message(mensaje)
        logger.info("Correo enviado a %s: %s", destino, asunto)
        return True
    except Exception:
        logger.exception("Error enviando correo a %s", destino)
        return False
