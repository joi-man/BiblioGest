from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

# Maximo de horas de plazo permitido: un año.
_MAX_HORAS_PLAZO = 24 * 365


class CategoriaBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100)
    descripcion: Optional[str] = None
    # Plazo de prestamo por defecto de los materiales de la categoria (horas).
    plazo_prestamo_horas: Optional[int] = Field(None, ge=1, le=_MAX_HORAS_PLAZO)


class CategoriaCrear(CategoriaBase):
    """Datos para crear una categoria."""


class CategoriaActualizar(BaseModel):
    """Datos editables de una categoria. Solo se aplican los campos enviados."""

    nombre: Optional[str] = Field(None, min_length=1, max_length=100)
    descripcion: Optional[str] = None
    plazo_prestamo_horas: Optional[int] = Field(None, ge=1, le=_MAX_HORAS_PLAZO)


class CategoriaRespuesta(CategoriaBase):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    fecha_creacion: datetime
