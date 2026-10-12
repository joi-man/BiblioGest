from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, select, or_
from fastapi import HTTPException, status
from app.modelos.usuario import Usuario
from app.core.seguridad import hashear_contrasena, verificar_contrasena, crear_token_acceso
from app.core.config import configuracion
from app.servicios import bitacora_servicio


def autenticar_usuario(
    db: Session,
    correo_o_usuario: str,
    contrasena: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> Optional[Usuario]:
    """Autenticar usuario con correo o username y contrasena."""
    stmt = select(Usuario).where(
        or_(
            func.lower(Usuario.correo_electronico) == correo_o_usuario.strip().lower(),
            Usuario.username == correo_o_usuario,
        ),
        Usuario.eliminado == False
    )
    usuario = db.execute(stmt).scalars().first()
    
    if usuario is None:
        bitacora_servicio.registrar_login_fallido(
            db=db,
            correo_electronico=correo_o_usuario,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return None
    
    if not usuario.activo:
        bitacora_servicio.registrar_login_fallido(
            db=db,
            correo_electronico=correo_o_usuario,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return None
    
    if not verificar_contrasena(contrasena, usuario.contrasena_hash):
        bitacora_servicio.registrar_login_fallido(
            db=db,
            correo_electronico=correo_o_usuario,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return None
    
    bitacora_servicio.registrar_login(
        db=db,
        usuario_id=usuario.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    
    return usuario


def crear_token_usuario(usuario: Usuario) -> str:
    """Crear token JWT para un usuario."""
    datos_token = {
        "sub": str(usuario.id),
        "correo": usuario.correo_electronico,
        "rol": usuario.rol,
    }
    tiempo_expiracion = timedelta(minutes=configuracion.EXPIRACION_TOKEN_MINUTOS)
    return crear_token_acceso(datos_token, tiempo_expiracion)


def cambiar_contrasena(
    db: Session,
    usuario: Usuario,
    contrasena_actual: str,
    nueva_contrasena: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> bool:
    """Cambia la contrasena de `usuario`. Devuelve False si la actual no coincide."""
    if not verificar_contrasena(contrasena_actual, usuario.contrasena_hash):
        return False

    usuario.contrasena_hash = hashear_contrasena(nueva_contrasena)
    usuario.fecha_actualizacion = datetime.utcnow()
    db.commit()

    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario.id,
        accion="PASSWORD_CHANGE",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return True
