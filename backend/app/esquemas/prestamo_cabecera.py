from pydantic import BaseModel, Field
from typing import Optional, List
from uuid import UUID
from datetime import date, datetime


class PrestamoCabeceraBase(BaseModel):
    usuario_id: UUID
    fecha_prestamo: date = Field(default_factory=date.today)
    fecha_devolucion_esperada: date
    observaciones: Optional[str] = None


class PrestamoCabeceraCrear(PrestamoCabeceraBase):
    materiales_ids: List[UUID]  # Lista de IDs de materiales a prestar


class PrestamoCabeceraActualizar(BaseModel):
    fecha_devolucion_esperada: Optional[date] = None
    estado: Optional[str] = None
    observaciones: Optional[str] = None


class PrestamoDetalleRespuesta(BaseModel):
    id: UUID
    material_id: UUID
    fecha_creacion: datetime

    class Config:
        from_attributes = True


class PrestamoCabeceraRespuesta(PrestamoCabeceraBase):
    id: UUID
    fecha_devolucion_real: Optional[date]
    estado: str
    fecha_creacion: datetime
    fecha_actualizacion: datetime
    detalles: List[PrestamoDetalleRespuesta]

    class Config:
        from_attributes = True
