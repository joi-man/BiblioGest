from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.core.constantes_prestamo import CONDICION_BUENO, CONDICIONES_DEVOLUCION
from app.core.constantes_inventario import patron_opciones
from app.esquemas.tipos import FechaUTC


class ItemDevolucion(BaseModel):
    """Un item del prestamo que se devuelve, con la condicion en que llega."""

    prestamo_detalle_id: UUID
    condicion: str = Field(
        default=CONDICION_BUENO, pattern=patron_opciones(CONDICIONES_DEVOLUCION)
    )
    observaciones: Optional[str] = None


class DevolverItemsPeticion(BaseModel):
    """Peticion para registrar la devolucion de uno o varios items de un prestamo."""

    items: List[ItemDevolucion] = Field(..., min_length=1)


class DevolucionRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    prestamo_detalle_id: UUID
    fecha_devolucion: FechaUTC
    condicion: str
    observaciones: Optional[str] = None
    dias_retraso: int
    multa_monto: Optional[float] = None  # nulo si el sistema de multas esta desactivado
