import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class Devolucion(Base):
    __tablename__ = "devoluciones"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Foreign Key - Detalle del prestamo que se esta devolviendo
    prestamo_detalle_id = Column(
        UUID(as_uuid=True), 
        ForeignKey("prestamos_detalle.id"), 
        unique=True,
        nullable=False
    )
    
    # Fecha y hora de la devolucion
    fecha_devolucion = Column(DateTime, nullable=False, default=datetime.utcnow)
    
    # Condicion del material al devolverlo
    condicion = Column(String(20), nullable=False, default="bueno")
    # opciones: bueno, dano_menor, dano_mayor, perdido
    
    # Observaciones sobre la devolucion
    observaciones = Column(Text, nullable=True)
    
    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamp
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

    # Relacion
    prestamo_detalle = relationship("PrestamoDetalle", back_populates="devolucion")

    def __repr__(self):
        return f"<Devolucion {self.id} - {self.condicion}>"
