from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.esquemas.autor import AutorResumen
from app.core.constantes_inventario import (
    CONDICIONES_MATERIAL,
    ESTADOS_MATERIAL,
    TIPOS_MATERIAL,
    patron_opciones,
)

# Maximo de horas de plazo permitido: un año.
_MAX_HORAS_PLAZO = 24 * 365
_MAX_EJEMPLARES = 10000


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
    # Obras de varios tomos: cada tomo es un material con su codigo y su cantidad.
    tomo: Optional[str] = Field(None, max_length=20)
    total_tomos: Optional[int] = Field(None, ge=1, le=999)

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
    # Ejemplares que tiene la biblioteca de este material.
    cantidad_total: int = Field(1, ge=1, le=_MAX_EJEMPLARES)

    imagen_url: Optional[str] = None


class MaterialCrear(MaterialBase):
    """Datos para registrar un material con sus ejemplares y autores.

    Los autores pueden indicarse por ID (`autores_ids`, ya existentes) y/o por
    nombre (`autores_nuevos`, se crean si no existen), asi se cargan en el
    mismo paso. Sigue aceptandose `autor` como texto ("A; B") por compatibilidad.
    """

    autores_ids: Optional[List[UUID]] = None
    autores_nuevos: Optional[List[str]] = None


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
    tomo: Optional[str] = Field(None, max_length=20)
    total_tomos: Optional[int] = Field(None, ge=1, le=999)
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
    cantidad_total: Optional[int] = Field(None, ge=1, le=_MAX_EJEMPLARES)
    # Ejemplares fuera de servicio. `estado` se acepta por compatibilidad: "fuera_de_servicio"
    # deja sin servicio todos los ejemplares libres y "disponible" los vuelve a habilitar.
    cantidad_fuera_servicio: Optional[int] = Field(None, ge=0, le=_MAX_EJEMPLARES)
    autores_ids: Optional[List[UUID]] = None
    autores_nuevos: Optional[List[str]] = None


class MaterialRespuesta(MaterialBase):
    """Material tal como lo devuelve la API."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    estado: str
    autores: List[AutorResumen] = []
    cantidad_reservada: int
    cantidad_prestada: int
    cantidad_vencida: int
    cantidad_fuera_servicio: int
    cantidad_disponible: int
    fecha_creacion: datetime
    fecha_actualizacion: datetime
