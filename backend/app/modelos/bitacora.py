import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from app.core.database import Base


class BitacoraAccion(Base):
    __tablename__ = "bitacora_acciones"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Usuario que realiza la accion
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=True)
    
    # Tipo de accion
    accion = Column(String(50), nullable=False)
    # CREATE, UPDATE, DELETE, LOGIN, LOGOUT, LOGIN_FAILED
    
    # Tabla afectada
    tabla_afectada = Column(String(50), nullable=True)
    
    # ID del registro afectado
    registro_id = Column(UUID(as_uuid=True), nullable=True)
    
    # Detalles adicionales en JSON
    detalles = Column(JSONB, nullable=True)
    
    # Informacion de conexion
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    
    # Timestamp
    fecha_accion = Column(DateTime, default=datetime.utcnow)

    # Relacion
    usuario = relationship("Usuario", foreign_keys=[usuario_id])

    def __repr__(self):
        return f"<BitacoraAccion {self.accion} - {self.tabla_afectada}>"
