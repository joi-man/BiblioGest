from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime


class DevolucionBase(BaseModel):
    prestamo_detalle_id: UUID
    condicion: str = Field(default="bueno", pattern=r"^(bueno|dano_menor|dano_mayor|perdido)$")
    observaciones: Optional[str] = None


class DevolucionCrear(DevolucionBase):
    pass


class DevolucionRespuesta(DevolucionBase):
    id: UUID
    fecha_devolucion: datetime
    fecha_creacion: datetime

    class Config:
        from_attributes = True
