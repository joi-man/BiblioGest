from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.esquemas.devolucion import DevolucionRespuesta
from app.esquemas.tipos import FechaUTC


# ---------------------------------------------------------------------------
# Resumenes que se incrustan dentro de un prestamo
# ---------------------------------------------------------------------------
class UsuarioResumen(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    username: str
    nombre: str
    apellido: str
    numero_documento: str
    correo_electronico: str


class MaterialResumen(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    codigo: str
    titulo: str
    tipo_material: str
    estado: str
    ubicacion: Optional[str] = None
    tomo: Optional[str] = None
    total_tomos: Optional[int] = None


# ---------------------------------------------------------------------------
# Respuestas
# ---------------------------------------------------------------------------
class PrestamoDetalleRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    material: MaterialResumen
    fecha_devolucion_esperada: Optional[FechaUTC] = None
    devuelto: bool
    devolucion: Optional[DevolucionRespuesta] = None


class PrestamoRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    estado: str
    usuario: UsuarioResumen
    detalles: List[PrestamoDetalleRespuesta]
    fecha_solicitud: FechaUTC
    fecha_retiro_solicitada: Optional[FechaUTC] = None
    fecha_retiro_limite: Optional[FechaUTC] = None
    fecha_prestamo: Optional[FechaUTC] = None
    fecha_devolucion_esperada: Optional[FechaUTC] = None
    fecha_devolucion_real: Optional[FechaUTC] = None
    aprobado_por: Optional[UsuarioResumen] = None
    entregado_por: Optional[UsuarioResumen] = None
    observaciones: Optional[str] = None
    motivo_rechazo: Optional[str] = None


# ---------------------------------------------------------------------------
# Peticiones
# ---------------------------------------------------------------------------
class SolicitudCrear(BaseModel):
    """Solicitud de prestamo o reserva hecha por un usuario para si mismo."""

    material_ids: List[UUID] = Field(..., min_length=1, max_length=10)
    observaciones: Optional[str] = Field(None, max_length=500)
    # Cuando pasara a retirar el material. Opcional por compatibilidad con aplicaciones
    # anteriores; la app movil la pide siempre.
    fecha_retiro_solicitada: Optional[FechaUTC] = None


class PrestamoDirectoCrear(BaseModel):
    """Prestamo registrado por el personal en el mostrador, sin solicitud previa."""

    usuario_id: UUID
    material_ids: List[UUID] = Field(..., min_length=1, max_length=10)
    observaciones: Optional[str] = Field(None, max_length=500)
    # Si se indica, reemplaza el plazo calculado de todos los items.
    fecha_devolucion_esperada: Optional[FechaUTC] = None
    # Permite al personal saltarse el limite de items y el bloqueo por vencidos.
    omitir_validaciones_usuario: bool = False


class RechazoPeticion(BaseModel):
    motivo: str = Field(..., min_length=3, max_length=500)


class EntregaPeticion(BaseModel):
    """Datos opcionales al entregar una solicitud aprobada."""

    # Si se indica, reemplaza el plazo calculado de todos los items.
    fecha_devolucion_esperada: Optional[FechaUTC] = None


class CesionPeticion(BaseModel):
    """Presta una reserva aprobada a otra persona (caso excepcional).

    El motivo es obligatorio: se le muestra y se le envia por correo a quien
    habia reservado.
    """

    usuario_id: UUID
    motivo: str = Field(..., min_length=10, max_length=500)
    # Si se indica, reemplaza el plazo calculado de todos los items.
    fecha_devolucion_esperada: Optional[FechaUTC] = None
    omitir_validaciones_usuario: bool = False
