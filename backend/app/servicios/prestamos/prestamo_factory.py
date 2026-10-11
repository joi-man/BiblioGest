"""Construccion de objetos de prestamo (sin tocar la base de datos)."""
from datetime import datetime
from typing import Optional, Sequence
from uuid import UUID

from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle


def nuevo_prestamo(
    usuario_id: UUID,
    materiales: Sequence[Material],
    estado: str,
    ahora: datetime,
    observaciones: Optional[str] = None,
) -> PrestamoCabecera:
    """Crea una cabecera con un detalle por cada material.

    El llamador es quien la agrega a la sesion y completa los datos propios de
    su flujo (aprobacion, entrega, plazos).
    """
    prestamo = PrestamoCabecera(
        usuario_id=usuario_id,
        estado=estado,
        fecha_solicitud=ahora,
        observaciones=observaciones,
    )
    prestamo.detalles = [PrestamoDetalle(material_id=m.id) for m in materiales]
    # Se enlaza el objeto Material para poder calcular plazos sin otra consulta.
    for detalle, material in zip(prestamo.detalles, materiales):
        detalle.material = material
    return prestamo
