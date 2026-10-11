from typing import List, Optional
from uuid import UUID
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import obtener_db
from app.core.seguridad import decodificar_token_acceso
from app.modelos.usuario import Usuario

oauth2_schema = OAuth2PasswordBearer(tokenUrl="/api/auth/login")
# Igual que el anterior pero sin error si no llega token (rutas que solo exigen sesion en ciertos casos).
oauth2_schema_opcional = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)


def obtener_usuario_actual(
    token: str = Depends(oauth2_schema),
    db: Session = Depends(obtener_db)
) -> Usuario:
    """Obtener el usuario actual a partir del token JWT."""
    credenciales_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decodificar_token_acceso(token)
    if payload is None:
        raise credenciales_exception
    
    usuario_id: Optional[str] = payload.get("sub")
    if usuario_id is None:
        raise credenciales_exception

    # El ID viaja como texto en el token; la columna es UUID.
    try:
        usuario_uuid = UUID(usuario_id)
    except ValueError:
        raise credenciales_exception

    # Buscar usuario en la base de datos
    from sqlalchemy import select
    stmt = select(Usuario).where(Usuario.id == usuario_uuid)
    usuario = db.execute(stmt).scalar_one_or_none()
    
    if usuario is None:
        raise credenciales_exception
    
    # Verificar que no este eliminado
    if usuario.eliminado:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario desactivado"
        )
    
    # Verificar que este activo
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario desactivado"
        )
    
    return usuario


def require_role(roles_permitidos: List[str]):
    """Dependency factory que requiere que el usuario tenga uno de los roles especificados."""
    def dependency(usuario: Usuario = Depends(obtener_usuario_actual)) -> Usuario:
        if usuario.rol not in roles_permitidos:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Se requiere uno de los roles: {', '.join(roles_permitidos)}"
            )
        return usuario
    return dependency


def obtener_usuario_opcional(
    token: Optional[str] = Depends(oauth2_schema_opcional),
    db: Session = Depends(obtener_db),
) -> Optional[Usuario]:
    """Usuario de la sesion, o None si no se envio token."""
    if token is None:
        return None
    return obtener_usuario_actual(token=token, db=db)
