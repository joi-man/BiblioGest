import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.modelos.sincronizable import Sincronizable


class Material(Sincronizable, Base):
    __tablename__ = "materiales"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    codigo = Column(String(50), unique=True, nullable=False, index=True)
    titulo = Column(String(255), nullable=False)
    tipo_material = Column(String(30), nullable=False, default="libro")  # ver TIPOS_MATERIAL
    estado = Column(String(20), nullable=False, default="disponible", index=True)  # ver ESTADOS_MATERIAL
    imagen_url = Column(String(500), nullable=True)
    
    # Campos especificos para libros (opcionales para otros materiales)
    # `autor` es el resumen en texto ("A, B"); los autores reales estan en `vinculos_autores`
    # y lo mantiene `autor_servicio`. Se conserva para las aplicaciones que aun lo leen.
    autor = Column(String(255), nullable=True)
    descripcion = Column(Text, nullable=True)
    isbn = Column(String(20), nullable=True)
    editorial = Column(String(200), nullable=True)
    anio_publicacion = Column(Integer, nullable=True)
    numero_paginas = Column(Integer, nullable=True)
    # Obras de varios tomos: cada tomo es un material con su propio codigo y cantidad.
    tomo = Column(String(20), nullable=True)  # Ej: "2", "II"
    total_tomos = Column(Integer, nullable=True)  # Ej: 5

    # Campos especificos para materiales que no son libros
    formato = Column(String(50), nullable=True)  # Ej: "DVD", "CD", "Audiolibro"
    duracion = Column(String(50), nullable=True)  # Ej: "120 min", "3 horas"

    # Campos especificos para equipos (proyectores, alargadores, laptops...)
    marca = Column(String(100), nullable=True)
    modelo = Column(String(100), nullable=True)
    numero_serie = Column(String(100), nullable=True)
    ubicacion = Column(String(150), nullable=True)  # Ej: "Estante B3", "Sala de equipos"
    accesorios = Column(Text, nullable=True)  # Ej: "Cable HDMI, control remoto, maletin"

    # Gestion de la unidad fisica
    condicion = Column(String(20), nullable=False, default="bueno")  # nuevo, bueno, regular, malo
    valor_referencial = Column(Numeric(10, 2), nullable=True)  # Para reposicion si se pierde
    es_prestable = Column(Boolean, nullable=False, default=True)  # False = solo consulta en sala
    plazo_prestamo_horas = Column(Integer, nullable=True)  # Si es nulo, se usa el de la categoria

    # Cantidad de ejemplares. Reservados, prestados y vencidos se recalculan a partir de los
    # prestamos (ver material_estado_servicio); fuera de servicio lo fija el personal o una
    # devolucion con danos mayores o perdida. Disponibles = total - los demas.
    cantidad_total = Column(Integer, nullable=False, default=1, server_default="1")
    cantidad_reservada = Column(Integer, nullable=False, default=0, server_default="0")
    cantidad_prestada = Column(Integer, nullable=False, default=0, server_default="0")
    cantidad_vencida = Column(Integer, nullable=False, default=0, server_default="0")
    cantidad_fuera_servicio = Column(Integer, nullable=False, default=0, server_default="0")

    # Texto sin tildes con titulo, autores, codigo, ISBN, editorial... para la busqueda.
    texto_busqueda = Column(Text, nullable=True)

    # Foreign Key
    categoria_id = Column(UUID(as_uuid=True), ForeignKey("categorias.id"), nullable=False)
    
    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)

    # Relaciones
    categoria = relationship("Categoria", back_populates="materiales")
    detalles_prestamo = relationship("PrestamoDetalle", back_populates="material")
    vinculos_autores = relationship(
        "MaterialAutor", back_populates="material", order_by="MaterialAutor.orden"
    )

    @property
    def autores(self):
        """Autores vigentes del material, en el orden de la portada."""
        return [
            v.autor for v in self.vinculos_autores
            if not v.eliminado and not v.autor.eliminado
        ]

    @property
    def cantidad_disponible(self) -> int:
        """Ejemplares que se pueden reservar o prestar ahora."""
        ocupados = (
            self.cantidad_reservada + self.cantidad_prestada
            + self.cantidad_vencida + self.cantidad_fuera_servicio
        )
        return max(0, (self.cantidad_total or 0) - ocupados)

    def __repr__(self):
        return f"<Material {self.codigo} - {self.titulo}>"
