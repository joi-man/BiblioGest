"""Esquemas de la API propia del ejecutable de escritorio."""
from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class ConfigurarSoloLocal(BaseModel):
    """Datos del primer administrador de un equipo sin servidor."""

    username: str = Field(..., min_length=3, max_length=50)
    correo_electronico: EmailStr
    numero_documento: str = Field(..., min_length=3, max_length=20)
    nombre: str = Field(..., min_length=1, max_length=100)
    apellido: str = Field(..., min_length=1, max_length=100)
    contrasena: str = Field(..., min_length=6)


class ConectarServidor(BaseModel):
    servidor_url: str
    usuario: str
    contrasena: str
    reemplazar_datos_locales: bool = False


class EstadoLocal(BaseModel):
    modo: str
    configurado: bool  # ya hay al menos un usuario
    servidor_url: Optional[str]
    conectado: Optional[bool]  # None = todavia no se sabe
    sincronizando: bool
    pendientes: int  # lotes por enviar
    conflictos: int  # lotes rechazados por revisar
    ultima_sincronizacion: Optional[str]
    ultimo_error: Optional[str]
    requiere_inicio_de_sesion: bool  # hay servidor pero nadie ha iniciado sesion aun


class ResumenSincronizacionRespuesta(BaseModel):
    enviados: int
    conflictos: int
    recibidos: int
    estado: EstadoLocal


class ConflictoRespuesta(BaseModel):
    id: UUID
    creado_en: datetime
    descripcion: str
    mensaje: Optional[str]
