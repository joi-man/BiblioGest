import uuid
from datetime import datetime, date
from sqlalchemy import Column, String, Boolean, DateTime, Date, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class PrestamoCabecera(Base):
    __tablename__ = "prestamos_cabecera"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Foreign Key - Usuario que realiza el prestamo
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=False)
    
    # Fechas del prestamo
    fecha_prestamo = Column(Date, nullable=False, default=date.today)
    fecha_devolucion_esperada = Column(Date, nullable=False)
    fecha_devolucion_real = Column(Date, nullable=True)
    
    # Estado del prestamo
    estado = Column(String(20), nullable=False, default="activo", index=True)
    # opciones: activo, devuelto, vencido
    
    # Observaciones generales del prestamo
    observaciones = Column(Text, nullable=True)
    
    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relaciones
    usuario = relationship("Usuario", back_populates="prestamos")
    detalles = relationship("PrestamoDetalle", back_populates="prestamo_cabecera", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<PrestamoCabecera {self.id} - {self.estado}>"
