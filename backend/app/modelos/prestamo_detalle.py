import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class PrestamoDetalle(Base):
    __tablename__ = "prestamos_detalle"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Foreign Keys
    prestamo_cabecera_id = Column(
        UUID(as_uuid=True), 
        ForeignKey("prestamos_cabecera.id", ondelete="CASCADE"), 
        nullable=False
    )
    material_id = Column(
        UUID(as_uuid=True), 
        ForeignKey("materiales.id"), 
        nullable=False
    )
    
    # Fecha limite de devolucion de este item (cada material tiene su propio plazo).
    # Es nula mientras la solicitud no se haya entregado.
    fecha_devolucion_esperada = Column(DateTime, nullable=True)

    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamp
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

    # Relaciones
    prestamo_cabecera = relationship("PrestamoCabecera", back_populates="detalles")
    material = relationship("Material", back_populates="detalles_prestamo")
    devolucion = relationship("Devolucion", back_populates="prestamo_detalle", uselist=False)

    @property
    def devuelto(self) -> bool:
        """Indica si este item ya fue devuelto (tiene una devolucion registrada)."""
        return self.devolucion is not None

    def __repr__(self):
        return f"<PrestamoDetalle {self.id}>"
