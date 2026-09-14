import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class Material(Base):
    __tablename__ = "materiales"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    codigo = Column(String(50), unique=True, nullable=False, index=True)
    titulo = Column(String(255), nullable=False)
    tipo_material = Column(String(30), nullable=False, default="libro")  # libro, revista, dvd, cd, proyector, otro
    estado = Column(String(20), nullable=False, default="disponible", index=True)  # disponible, prestado, vencido, fuera_de_servicio
    imagen_url = Column(String(500), nullable=True)
    
    # Campos especificos para libros (opcionales para otros materiales)
    autor = Column(String(255), nullable=True)
    descripcion = Column(Text, nullable=True)
    isbn = Column(String(20), nullable=True)
    editorial = Column(String(200), nullable=True)
    anio_publicacion = Column(Integer, nullable=True)
    numero_paginas = Column(Integer, nullable=True)
    
    # Campos especificos para materiales que no son libros
    formato = Column(String(50), nullable=True)  # Ej: "DVD", "CD", "Audiolibro"
    duracion = Column(String(50), nullable=True)  # Ej: "120 min", "3 horas"
    
    # Foreign Key
    categoria_id = Column(UUID(as_uuid=True), ForeignKey("categorias.id"), nullable=False)
    
    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relaciones
    categoria = relationship("Categoria", back_populates="materiales")
    detalles_prestamo = relationship("PrestamoDetalle", back_populates="material")

    def __repr__(self):
        return f"<Material {self.codigo} - {self.titulo}>"
