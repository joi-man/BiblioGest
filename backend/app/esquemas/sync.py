"""Esquemas de los intercambios de sincronizacion."""
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class FilaSync(BaseModel):
    """Una fila cambiada dentro de un lote."""

    tabla: str
    id: str
    op: str = Field(..., pattern="^(insert|update)$")
    base_version: Optional[int] = None  # version en la que se baso el cambio (solo update)
    datos: Dict[str, Any]


class LoteSync(BaseModel):
    """Cambios de una transaccion: se aplican completos o no se aplican."""

    id: str
    filas: List[FilaSync]


class EnvioLotes(BaseModel):
    lotes: List[LoteSync]


class ResultadoLoteSync(BaseModel):
    id: str
    estado: str  # aplicado | conflicto | error
    mensaje: Optional[str] = None


class RespuestaEnvio(BaseModel):
    resultados: List[ResultadoLoteSync]


class PeticionFilas(BaseModel):
    tabla: str
    ids: List[str]


class FilaDescargada(BaseModel):
    id: str
    version: Optional[int] = None
    datos: Dict[str, Any]


class RespuestaCambios(BaseModel):
    filas: List[FilaDescargada]
    hay_mas: bool
    # Posicion de la ultima fila entregada, para pedir la pagina siguiente.
    cursor_fecha: Optional[str] = None
    cursor_id: Optional[str] = None
