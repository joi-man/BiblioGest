from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class AutorCrear(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=200)


class AutorActualizar(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=200)


class AutorResumen(BaseModel):
    """Autor tal como aparece dentro de un material."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    nombre: str


class AutorRespuesta(AutorResumen):
    fecha_creacion: datetime
    # Cuantos materiales tiene; solo se informa en los listados de autores.
    cantidad_materiales: int = 0
