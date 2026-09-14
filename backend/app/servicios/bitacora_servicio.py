from typing import Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.modelos.bitacora import BitacoraAccion


def registrar_accion(
    db: Session,
    usuario_id: Optional[UUID],
    accion: str,
    tabla_afectada: Optional[str] = None,
    registro_id: Optional[UUID] = None,
    detalles: Optional[Dict[str, Any]] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> BitacoraAccion:
    """Registrar una accion en la bitacora de auditoria."""
    bitacora = BitacoraAccion(
        usuario_id=usuario_id,
        accion=accion,
        tabla_afectada=tabla_afectada,
        registro_id=registro_id,
        detalles=detalles,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(bitacora)
    db.commit()
    db.refresh(bitacora)
    return bitacora


def registrar_login(
    db: Session,
    usuario_id: UUID,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> BitacoraAccion:
    """Registrar un inicio de sesion exitoso."""
    return registrar_accion(
        db=db,
        usuario_id=usuario_id,
        accion="LOGIN",
        tabla_afectada="usuarios",
        registro_id=usuario_id,
        ip_address=ip_address,
        user_agent=user_agent,
    )


def registrar_login_fallido(
    db: Session,
    correo_electronico: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> BitacoraAccion:
    """Registrar un intento de login fallido."""
    return registrar_accion(
        db=db,
        usuario_id=None,
        accion="LOGIN_FAILED",
        tabla_afectada="usuarios",
        detalles={"correo_electronico": correo_electronico},
        ip_address=ip_address,
        user_agent=user_agent,
    )


def registrar_logout(
    db: Session,
    usuario_id: UUID,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> BitacoraAccion:
    """Registrar un cierre de sesion."""
    return registrar_accion(
        db=db,
        usuario_id=usuario_id,
        accion="LOGOUT",
        tabla_afectada="usuarios",
        registro_id=usuario_id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
