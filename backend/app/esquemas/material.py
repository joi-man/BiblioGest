from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime


class MaterialBase(BaseModel):
    codigo: str = Field(..., min_length=1, max_length=50)
    titulo: str = Field(..., min_length=1, max_length=255)
    tipo_material: str = Field(..., pattern=r"^(libro|revista|dvd|cd|proyector|otro)$")
    categoria_id: UUID
    
    # Campos opcionales para libros
    autor: Optional[str] = None
    descripcion: Optional[str] = None
    isbn: Optional[str] = None
    editorial: Optional[str] = None
    anio_publicacion: Optional[int] = None
    numero_paginas: Optional[int] = None
    
    # Campos opcionales para otros materiales
    formato: Optional[str] = None
    duracion: Optional[str] = None
    
    imagen_url: Optional[str] = None


class MaterialCrear(MaterialBase):
    pass


class MaterialActualizar(BaseModel):
    titulo: Optional[str] = None
    tipo_material: Optional[str] = None
    categoria_id: Optional[UUID] = None
    estado: Optional[str] = None
    autor: Optional[str] = None
    descripcion: Optional[str] = None
    isbn: Optional[str] = None
    editorial: Optional[str] = None
    anio_publicacion: Optional[int] = None
    numero_paginas: Optional[int] = None
    formato: Optional[str] = None
    duracion: Optional[str] = None
    imagen_url: Optional[str] = None


class MaterialRespuesta(MaterialBase):
    id: UUID
    estado: str
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True
