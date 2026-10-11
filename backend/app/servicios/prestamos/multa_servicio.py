"""Calculo de multas por retraso o danos. Es una funcionalidad opcional."""
from typing import Optional

from app.core.config import configuracion
from app.core.constantes_prestamo import (
    CONDICION_DANO_MAYOR,
    CONDICION_DANO_MENOR,
    CONDICION_PERDIDO,
)
from app.modelos.material import Material


def calcular_multa(dias_retraso: int, condicion: str, material: Material) -> Optional[float]:
    """Calcula la multa de una devolucion.

    Devuelve `None` cuando las multas estan desactivadas
    (`MULTAS_HABILITADAS=False`), de modo que el sistema funciona igual sin
    ellas. Si estan activas, suma:

    - la tarifa por cada dia de retraso,
    - un cargo fijo por dano menor o mayor,
    - el valor referencial del material si se perdio.
    """
    if not configuracion.MULTAS_HABILITADAS:
        return None

    total = dias_retraso * configuracion.MULTA_POR_DIA_RETRASO

    if condicion == CONDICION_DANO_MENOR:
        total += configuracion.MULTA_DANO_MENOR
    elif condicion == CONDICION_DANO_MAYOR:
        total += configuracion.MULTA_DANO_MAYOR
    elif condicion == CONDICION_PERDIDO:
        total += float(material.valor_referencial or 0)

    return round(total, 2)
