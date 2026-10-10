import secrets
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.config import configuracion
from app.core.seguridad import hashear_contrasena, verificar_contrasena
from app.modelos.codigo_recuperacion import CodigoRecuperacion
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio
from app.servicios.usuario_servicio import obtener_usuario_por_correo


def solicitar_codigo(
    db: Session,
    correo: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> Optional[tuple[Usuario, str]]:
    """Genera un codigo de 6 digitos para el usuario. Devuelve (usuario, codigo) o None si no aplica."""
    usuario = obtener_usuario_por_correo(db, correo)
    if usuario is None or not usuario.activo:
        return None

    # Invalida codigos anteriores pendientes
    db.execute(
        update(CodigoRecuperacion)
        .where(CodigoRecuperacion.usuario_id == usuario.id, CodigoRecuperacion.usado == False)
        .values(usado=True)
    )

    codigo = f"{secrets.randbelow(1_000_000):06d}"
    db.add(
        CodigoRecuperacion(
            usuario_id=usuario.id,
            codigo_hash=hashear_contrasena(codigo),
            expira_en=datetime.utcnow() + timedelta(minutes=configuracion.CODIGO_RESET_EXPIRACION_MINUTOS),
        )
    )
    db.commit()

    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario.id,
        accion="PASSWORD_RESET_REQUEST",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return usuario, codigo


def restablecer_contrasena(
    db: Session,
    correo: str,
    codigo: str,
    nueva_contrasena: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> bool:
    """Valida el codigo y cambia la contrasena. Devuelve False si el codigo no es valido."""
    usuario = obtener_usuario_por_correo(db, correo)
    if usuario is None or not usuario.activo:
        return False

    registro = db.execute(
        select(CodigoRecuperacion)
        .where(CodigoRecuperacion.usuario_id == usuario.id, CodigoRecuperacion.usado == False)
        .order_by(CodigoRecuperacion.fecha_creacion.desc())
        .limit(1)
    ).scalar_one_or_none()

    if registro is None or registro.expira_en < datetime.utcnow():
        return False

    if registro.intentos >= configuracion.CODIGO_RESET_MAX_INTENTOS:
        return False

    if not verificar_contrasena(codigo, registro.codigo_hash):
        registro.intentos += 1
        db.commit()
        return False

    registro.usado = True
    usuario.contrasena_hash = hashear_contrasena(nueva_contrasena)
    usuario.fecha_actualizacion = datetime.utcnow()
    db.commit()

    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario.id,
        accion="PASSWORD_RESET",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return True
