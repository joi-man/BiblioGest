import uuid
from datetime import datetime

from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PrestamoCabecera(Base):
    """Solicitud o prestamo de uno o varios materiales para un usuario.

    Es un unico registro con una maquina de estados (ver
    `app.servicios.prestamos.maquina_estados`): empieza como `pendiente`
    cuando el estudiante solicita, y termina en `devuelto`, `rechazado` o
    `cancelado`. Todas las fechas se guardan en UTC.
    """

    __tablename__ = "prestamos_cabecera"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Usuario que recibe el material
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=False)

    # Estado: pendiente, aprobado, rechazado, cancelado, activo, vencido, devuelto
    estado = Column(String(20), nullable=False, default="pendiente", index=True)

    # Fechas del ciclo de vida
    fecha_solicitud = Column(DateTime, nullable=False, default=datetime.utcnow)
    fecha_retiro_limite = Column(DateTime, nullable=True)  # hasta cuando se puede retirar una reserva aprobada
    fecha_prestamo = Column(DateTime, nullable=True)  # momento de la entrega
    fecha_devolucion_esperada = Column(DateTime, nullable=True)  # la mas proxima entre los items pendientes
    fecha_devolucion_real = Column(DateTime, nullable=True)  # cuando se devolvio el ultimo item

    # Personal que intervino
    aprobado_por_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=True)
    entregado_por_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id"), nullable=True)

    observaciones = Column(Text, nullable=True)
    motivo_rechazo = Column(Text, nullable=True)  # tambien se usa para el motivo de cancelacion automatica

    # Eliminacion logica
    eliminado = Column(Boolean, default=False, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)

    # Timestamps
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relaciones
    usuario = relationship("Usuario", back_populates="prestamos", foreign_keys=[usuario_id])
    aprobado_por = relationship("Usuario", foreign_keys=[aprobado_por_id])
    entregado_por = relationship("Usuario", foreign_keys=[entregado_por_id])
    detalles = relationship(
        "PrestamoDetalle",
        back_populates="prestamo_cabecera",
        cascade="all, delete-orphan",
    )

    def __repr__(self):
        return f"<PrestamoCabecera {self.id} - {self.estado}>"
