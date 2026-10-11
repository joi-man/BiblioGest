"""Calculo de la fecha limite de devolucion de un material."""
from datetime import datetime, timedelta

from app.core.config import configuracion
from app.modelos.material import Material


def horas_de_plazo(material: Material) -> int:
    """Devuelve el plazo de prestamo del material, en horas.

    Orden de prioridad: plazo propio del material, plazo de su categoria y,
    si ninguno esta definido, el plazo general de la configuracion.
    """
    if material.plazo_prestamo_horas:
        return material.plazo_prestamo_horas
    if material.categoria is not None and material.categoria.plazo_prestamo_horas:
        return material.categoria.plazo_prestamo_horas
    return configuracion.PLAZO_PRESTAMO_HORAS_DEFECTO


def fecha_limite(material: Material, desde: datetime) -> datetime:
    """Fecha y hora limite para devolver `material` si se entrega en `desde`."""
    return desde + timedelta(hours=horas_de_plazo(material))
