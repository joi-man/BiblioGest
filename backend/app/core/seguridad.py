from datetime import datetime, timedelta
from typing import Optional
import jwt
from passlib.context import CryptContext
from .config import configuracion


# Contexto para hashear contrasenas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hashear_contrasena(contrasena: str) -> str:
    """Hashear una contrasena."""
    return pwd_context.hash(contrasena)


def verificar_contrasena(contrasena_plana: str, contrasena_hasheada: str) -> bool:
    """Verificar una contrasena contra su hash.

    Un hash que no es valido (por ejemplo el marcador "!" de quienes no usan el
    ejecutable) nunca coincide.
    """
    try:
        return pwd_context.verify(contrasena_plana, contrasena_hasheada)
    except ValueError:
        return False


def crear_token_acceso(datos: dict, tiempo_expiracion: Optional[timedelta] = None) -> str:
    """Crear un token JWT de acceso."""
    a_copiar = datos.copy()
    if tiempo_expiracion:
        expiracion = datetime.utcnow() + tiempo_expiracion
    else:
        expiracion = datetime.utcnow() + timedelta(minutes=configuracion.EXPIRACION_TOKEN_MINUTOS)
    
    a_copiar.update({"exp": expiracion})
    token_jwt = jwt.encode(a_copiar, configuracion.SECRETO_JWT, algorithm=configuracion.ALGORITMO_JWT)
    return token_jwt


def decodificar_token_acceso(token: str) -> Optional[dict]:
    """Decodificar y validar un token JWT."""
    try:
        payload = jwt.decode(token, configuracion.SECRETO_JWT, algorithms=[configuracion.ALGORITMO_JWT])
        return payload
    except jwt.PyJWTError:
        return None
