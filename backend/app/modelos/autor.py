import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.modelos.sincronizable import Sincronizable


class Autor(Sincronizable, Base):
    """Persona que escribio uno o varios materiales. Un material puede tener varios autores."""

    __tablename__ = "autores"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(200), nullable=False)
    # Nombre sin tildes ni mayusculas: evita duplicados ("Garcia Marquez" = "García Márquez")
    # y permite buscar sin importar la escritura. Lo mantiene `autor_servicio`.
    nombre_normalizado = Column(String(200), nullable=False, index=True)

    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)

    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)

    vinculos = relationship("MaterialAutor", back_populates="autor")

    def __repr__(self):
        return f"<Autor {self.nombre}>"


class MaterialAutor(Sincronizable, Base):
    """Vinculo entre un material y uno de sus autores (relacion muchos a muchos).

    Es una tabla con id propio y eliminacion logica, como las demas, para poder
    sincronizarse con el ejecutable de escritorio.
    """

    __tablename__ = "materiales_autores"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    material_id = Column(UUID(as_uuid=True), ForeignKey("materiales.id"), nullable=False, index=True)
    autor_id = Column(UUID(as_uuid=True), ForeignKey("autores.id"), nullable=False, index=True)
    # Posicion del autor en la portada: el primero es el principal.
    orden = Column(Integer, nullable=False, default=0)

    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)

    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)

    material = relationship("Material", back_populates="vinculos_autores")
    autor = relationship("Autor", back_populates="vinculos")
