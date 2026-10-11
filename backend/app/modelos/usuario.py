import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.modelos.sincronizable import Sincronizable


class Usuario(Sincronizable, Base):
    __tablename__ = "usuarios"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(50), unique=True, nullable=False, index=True)
    correo_electronico = Column(String(255), unique=True, nullable=False, index=True)
    contrasena_hash = Column(String(255), nullable=False)
    numero_documento = Column(String(20), unique=True, nullable=False, index=True)  # CI Paraguay
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    rol = Column(String(20), nullable=False, default="estudiante")  # admin, bibliotecario, estudiante
    telefono = Column(String(20), nullable=True)  # Para estudiantes
    activo = Column(Boolean, default=True)
    
    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)

    # Relaciones
    # Prestamos donde este usuario es quien recibe el material (no el personal que lo gestiona)
    prestamos = relationship(
        "PrestamoCabecera",
        back_populates="usuario",
        foreign_keys="PrestamoCabecera.usuario_id",
    )

    def __repr__(self):
        return f"<Usuario {self.nombre} {self.apellido}>"
