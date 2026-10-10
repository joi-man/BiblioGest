import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base


class CodigoRecuperacion(Base):
    __tablename__ = "codigos_recuperacion"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=False, index=True)
    codigo_hash = Column(String(255), nullable=False)
    expira_en = Column(DateTime, nullable=False)
    usado = Column(Boolean, nullable=False, default=False)
    intentos = Column(Integer, nullable=False, default=0)
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<CodigoRecuperacion usuario={self.usuario_id} usado={self.usado}>"
