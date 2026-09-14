from datetime import timedelta
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import select, or_
from fastapi import HTTPException, status
from app.modelos.usuario import Usuario
from app.core.seguridad import verificar_contrasena, crear_token_acceso
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
            Usuario.correo_electronico == correo_o_usuario,
            Usuario.username == correo_o_usuario,
        ),
        Usuario.eliminado == False
    )
    usuario = db.execute(stmt).scalar_one_or_none()
    
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
