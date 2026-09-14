from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime


class CategoriaBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100)
    descripcion: Optional[str] = None


class CategoriaCrear(CategoriaBase):
    pass


class CategoriaActualizar(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None


class CategoriaRespuesta(CategoriaBase):
    id: UUID
    fecha_creacion: datetime

    class Config:
        from_attributes = True
