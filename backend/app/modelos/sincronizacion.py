"""Tablas de apoyo a la sincronizacion entre el servidor y los equipos."""
import uuid
from datetime import datetime

from sqlalchemy import JSON, Boolean, Column, DateTime, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base

# Estados de un lote guardado en el equipo.
LOTE_PENDIENTE = "pendiente"  # esperando enviarse al servidor
LOTE_CONFLICTO = "conflicto"  # el servidor lo rechazo; espera decision del bibliotecario


class SyncLote(Base):
    """Bandeja de salida del equipo: los cambios de UNA transaccion.

    Un lote se aplica completo o no se aplica: es la unidad de sincronizacion.
    Solo existe en el ejecutable de escritorio.
    """

    __tablename__ = "sync_lotes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    creado_en = Column(DateTime, nullable=False, default=datetime.utcnow, index=True)
    estado = Column(String(15), nullable=False, default=LOTE_PENDIENTE, index=True)

    # Texto legible para el bibliotecario, por ejemplo "Prestamo nuevo · Material PROY-001".
    descripcion = Column(Text, nullable=False, default="")

    # Filas cambiadas: [{tabla, id, op, base_version, datos}, ...]
    filas = Column(JSON, nullable=False)

    # True si lo genero el sistema solo (por ejemplo, marcar un prestamo como vencido).
    automatico = Column(Boolean, nullable=False, default=False)

    # Motivo del rechazo cuando estado = conflicto.
    mensaje = Column(Text, nullable=True)
    intentos = Column(Integer, nullable=False, default=0)


class SyncLoteRecibido(Base):
    """Lotes que el servidor ya aplico, para no repetirlos si el equipo reintenta."""

    __tablename__ = "sync_lotes_recibidos"

    id = Column(UUID(as_uuid=True), primary_key=True)
    recibido_en = Column(DateTime, nullable=False, default=datetime.utcnow)
    usuario_id = Column(UUID(as_uuid=True), nullable=True)


class ConfiguracionLocal(Base):
    """Pares clave/valor propios del equipo: servidor, cursores de descarga, etc."""

    __tablename__ = "configuracion_local"

    clave = Column(String(80), primary_key=True)
    valor = Column(Text, nullable=True)
