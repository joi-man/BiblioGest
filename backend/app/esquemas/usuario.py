import re

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from uuid import UUID
from datetime import datetime


def limpiar_documento(valor):
    """El numero de documento va sin puntos ni espacios (4.111.222 -> 4111222)."""
    return re.sub(r"[.\s]", "", valor) if isinstance(valor, str) else valor


class UsuarioBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    correo_electronico: EmailStr
    numero_documento: str = Field(..., min_length=3, max_length=20)
    nombre: str = Field(..., min_length=1, max_length=100)
    apellido: str = Field(..., min_length=1, max_length=100)
    rol: str = Field(..., pattern=r"^(admin|bibliotecario|estudiante)$")
    telefono: Optional[str] = None

    _documento_limpio = field_validator("numero_documento", mode="before")(limpiar_documento)


class UsuarioCrear(UsuarioBase):
    contrasena: str = Field(..., min_length=6)


class UsuarioActualizar(BaseModel):
    correo_electronico: Optional[EmailStr] = None
    numero_documento: Optional[str] = Field(None, min_length=3, max_length=20)
    # Si viene, reemplaza la contrasena; si no, se conserva la actual.
    contrasena: Optional[str] = Field(None, min_length=6)
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    rol: Optional[str] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = None

    _documento_limpio = field_validator("numero_documento", mode="before")(limpiar_documento)


class UsuarioRespuesta(UsuarioBase):
    id: UUID
    activo: bool
    fecha_creacion: Optional[datetime] = None
    fecha_actualizacion: Optional[datetime] = None

    class Config:
        from_attributes = True
