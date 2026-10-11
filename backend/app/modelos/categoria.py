import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class Categoria(Base):
    __tablename__ = "categorias"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(100), unique=True, nullable=False)
    descripcion = Column(Text, nullable=True)

    # Plazo de prestamo por defecto para los materiales de esta categoria (en horas).
    # Ej: libros 168 (7 dias), proyectores 4. Si es nulo se usa el plazo general.
    plazo_prestamo_horas = Column(Integer, nullable=True)

    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

    # Relaciones
    materiales = relationship("Material", back_populates="categoria")

    def __repr__(self):
        return f"<Categoria {self.nombre}>"
