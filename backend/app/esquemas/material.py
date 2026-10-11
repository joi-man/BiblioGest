from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.core.constantes_inventario import (
    CONDICIONES_MATERIAL,
    ESTADOS_MATERIAL,
    TIPOS_MATERIAL,
    patron_opciones,
)

# Maximo de horas de plazo permitido: un año.
_MAX_HORAS_PLAZO = 24 * 365


class MaterialBase(BaseModel):
    """Campos comunes a toda unidad de material (libro o equipo)."""

    codigo: str = Field(..., min_length=1, max_length=50)
    titulo: str = Field(..., min_length=1, max_length=255)
    tipo_material: str = Field(..., pattern=patron_opciones(TIPOS_MATERIAL))
    categoria_id: UUID

    # Campos bibliograficos (libros y revistas)
    autor: Optional[str] = None
    descripcion: Optional[str] = None
    isbn: Optional[str] = None
    editorial: Optional[str] = None
    anio_publicacion: Optional[int] = None
    numero_paginas: Optional[int] = None

    # Campos de medios (dvd, cd, audiolibros)
    formato: Optional[str] = None
    duracion: Optional[str] = None

    # Campos de equipos (proyectores, alargadores, laptops...)
    marca: Optional[str] = Field(None, max_length=100)
    modelo: Optional[str] = Field(None, max_length=100)
    numero_serie: Optional[str] = Field(None, max_length=100)
    ubicacion: Optional[str] = Field(None, max_length=150)
    accesorios: Optional[str] = None

    # Gestion de la unidad fisica
    condicion: str = Field("bueno", pattern=patron_opciones(CONDICIONES_MATERIAL))
    valor_referencial: Optional[float] = Field(None, ge=0)
    es_prestable: bool = True
    plazo_prestamo_horas: Optional[int] = Field(None, ge=1, le=_MAX_HORAS_PLAZO)

    imagen_url: Optional[str] = None


class MaterialCrear(MaterialBase):
    """Datos para registrar una nueva unidad de material."""


class MaterialActualizar(BaseModel):
    """Datos editables de un material. Solo se aplican los campos enviados."""

    titulo: Optional[str] = Field(None, min_length=1, max_length=255)
    tipo_material: Optional[str] = Field(None, pattern=patron_opciones(TIPOS_MATERIAL))
    categoria_id: Optional[UUID] = None
    estado: Optional[str] = Field(None, pattern=patron_opciones(ESTADOS_MATERIAL))
    autor: Optional[str] = None
    descripcion: Optional[str] = None
    isbn: Optional[str] = None
    editorial: Optional[str] = None
    anio_publicacion: Optional[int] = None
    numero_paginas: Optional[int] = None
    formato: Optional[str] = None
    duracion: Optional[str] = None
    marca: Optional[str] = Field(None, max_length=100)
    modelo: Optional[str] = Field(None, max_length=100)
    numero_serie: Optional[str] = Field(None, max_length=100)
    ubicacion: Optional[str] = Field(None, max_length=150)
    accesorios: Optional[str] = None
    condicion: Optional[str] = Field(None, pattern=patron_opciones(CONDICIONES_MATERIAL))
    valor_referencial: Optional[float] = Field(None, ge=0)
    es_prestable: Optional[bool] = None
    plazo_prestamo_horas: Optional[int] = Field(None, ge=1, le=_MAX_HORAS_PLAZO)
    imagen_url: Optional[str] = None


class MaterialRespuesta(MaterialBase):
    """Material tal como lo devuelve la API."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    estado: str
    fecha_creacion: datetime
    fecha_actualizacion: datetime
