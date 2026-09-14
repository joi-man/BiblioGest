from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from uuid import UUID
from datetime import datetime


class UsuarioBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    correo_electronico: EmailStr
    numero_documento: str = Field(..., min_length=3, max_length=20)
    nombre: str = Field(..., min_length=1, max_length=100)
    apellido: str = Field(..., min_length=1, max_length=100)
    rol: str = Field(..., pattern=r"^(admin|bibliotecario|estudiante)$")
    telefono: Optional[str] = None


class UsuarioCrear(UsuarioBase):
    contrasena: str = Field(..., min_length=6)


class UsuarioActualizar(BaseModel):
    correo_electronico: Optional[EmailStr] = None
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    rol: Optional[str] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = None


class UsuarioRespuesta(UsuarioBase):
    id: UUID
    activo: bool
    fecha_creacion: Optional[datetime] = None
    fecha_actualizacion: Optional[datetime] = None

    class Config:
        from_attributes = True
