"""Registro de devoluciones de los items de un prestamo."""
import math
from datetime import datetime
from typing import Sequence
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.constantes_prestamo import ESTADOS_EN_CURSO
from app.esquemas.devolucion import ItemDevolucion
from app.modelos.devolucion import Devolucion
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle
from app.modelos.usuario import Usuario
from app.servicios.prestamos import (
    auditoria_prestamo,
    consulta_prestamo_servicio,
    estado_prestamo_servicio,
    material_estado_servicio,
    multa_servicio,
)

_SEGUNDOS_POR_DIA = 86400


def calcular_dias_retraso(fecha_esperada: datetime, ahora: datetime) -> int:
    """Dias de retraso, contando como dia completo cualquier fraccion pasada del plazo."""
    segundos = (ahora - fecha_esperada).total_seconds()
    if segundos <= 0:
        return 0
    return math.ceil(segundos / _SEGUNDOS_POR_DIA)


def _detalles_a_devolver(
    prestamo: PrestamoCabecera, items: Sequence[ItemDevolucion]
) -> dict[UUID, PrestamoDetalle]:
    """Valida que los items pertenezcan al prestamo y esten pendientes. Devuelve detalle por ID."""
    por_id = {d.id: d for d in prestamo.detalles}
    repetidos = [i.prestamo_detalle_id for i in items]
    if len(set(repetidos)) != len(repetidos):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un mismo item no puede devolverse dos veces en la misma operacion",
        )

    for item in items:
        detalle = por_id.get(item.prestamo_detalle_id)
        if detalle is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uno de los items no pertenece a este prestamo",
            )
        if detalle.devuelto:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"'{detalle.material.titulo}' ya fue devuelto",
            )
    return por_id


def devolver_items(
    db: Session,
    prestamo_id: UUID,
    items: Sequence[ItemDevolucion],
    personal: Usuario,
) -> PrestamoCabecera:
    """Registra la devolucion de uno o varios items de un prestamo en curso.

    Por cada item guarda la condicion, los dias de retraso y la multa (si estan
    habilitadas), y deja la unidad lista segun su condicion. Si ya no quedan
    items pendientes el prestamo pasa a `devuelto`.
    """
    ahora = reloj.ahora_utc()
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    if prestamo.estado not in ESTADOS_EN_CURSO:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"El prestamo esta '{prestamo.estado}': solo se devuelven prestamos entregados",
        )

    detalles = _detalles_a_devolver(prestamo, items)
    materiales = {
        m.id: m
        for m in material_estado_servicio.bloquear_materiales(
            db, [detalles[i.prestamo_detalle_id].material_id for i in items]
        )
    }

    for item in items:
        detalle = detalles[item.prestamo_detalle_id]
        material = materiales[detalle.material_id]
        dias = calcular_dias_retraso(detalle.fecha_devolucion_esperada, ahora)

        detalle.devolucion = Devolucion(
            prestamo_detalle_id=detalle.id,
            fecha_devolucion=ahora,
            condicion=item.condicion,
            observaciones=item.observaciones,
            recibido_por_id=personal.id,
            dias_retraso=dias,
            multa_monto=multa_servicio.calcular_multa(dias, item.condicion, material),
        )
        material_estado_servicio.recibir(material, item.condicion)

    estado_prestamo_servicio.recalcular(prestamo, ahora)
    material_estado_servicio.recalcular(db, list(materiales.values()), ahora)

    auditoria_prestamo.registrar(
        db, personal, "DEVOLUCION_REGISTRADA", prestamo,
        {
            "items": [
                {"material": detalles[i.prestamo_detalle_id].material.codigo, "condicion": i.condicion}
                for i in items
            ]
        },
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)
