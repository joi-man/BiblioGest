"""Registro de devoluciones de los items de un prestamo."""
import math
from datetime import datetime, timedelta
from typing import Optional, Sequence
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core import reloj
from app.core.constantes_prestamo import (
    ESTADOS_EN_CURSO,
    MAX_DIAS_DEVOLUCION_RETROACTIVA,
    MIN_CARACTERES_MOTIVO_FECHA,
    TOLERANCIA_RELOJ_SEGUNDOS,
)
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


def _fecha_efectiva(
    prestamo: PrestamoCabecera,
    indicada: Optional[datetime],
    motivo: Optional[str],
    ahora: datetime,
) -> datetime:
    """Fecha y hora que se anota como la de la devolucion.

    Sin fecha indicada es `ahora`. Una fecha indicada (el material se recibio antes
    de registrarlo) debe tener un motivo, no ser futura, no ser anterior a la
    entrega ni a mas de MAX_DIAS_DEVOLUCION_RETROACTIVA dias.
    """
    if indicada is None:
        return ahora

    if len((motivo or "").strip()) < MIN_CARACTERES_MOTIVO_FECHA:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Explica por que se registra con otra fecha "
                f"(al menos {MIN_CARACTERES_MOTIVO_FECHA} caracteres)"
            ),
        )
    if indicada > ahora + timedelta(seconds=TOLERANCIA_RELOJ_SEGUNDOS):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha de devolucion no puede ser posterior a este momento",
        )
    if prestamo.fecha_prestamo is not None and indicada < prestamo.fecha_prestamo:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha de devolucion no puede ser anterior a la entrega del prestamo",
        )
    if indicada < ahora - timedelta(days=MAX_DIAS_DEVOLUCION_RETROACTIVA):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "La fecha de devolucion no puede ser de hace mas de "
                f"{MAX_DIAS_DEVOLUCION_RETROACTIVA} dias"
            ),
        )
    return min(indicada, ahora)  # un pequeno adelanto del reloj del equipo no cuenta como futuro


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
    fecha_devolucion: Optional[datetime] = None,
    motivo_fecha: Optional[str] = None,
) -> PrestamoCabecera:
    """Registra la devolucion de uno o varios items de un prestamo en curso.

    Por cada item guarda la condicion, los dias de retraso y la multa (si estan
    habilitadas), y deja la unidad lista segun su condicion. Si ya no quedan
    items pendientes el prestamo pasa a `devuelto`.

    `fecha_devolucion` permite anotar la hora real en que se recibio el material
    cuando difiere del momento del registro. Los dias de retraso y la multa se
    calculan con esa fecha, y la bitacora guarda la fecha indicada, el motivo, la
    hora en que realmente se registro y quien lo hizo.
    """
    ahora = reloj.ahora_utc()
    prestamo = consulta_prestamo_servicio.obtener_prestamo_bloqueado(db, prestamo_id)

    if prestamo.estado not in ESTADOS_EN_CURSO:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"El prestamo esta '{prestamo.estado}': solo se devuelven prestamos entregados",
        )

    recibido_en = _fecha_efectiva(prestamo, fecha_devolucion, motivo_fecha, ahora)
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
        dias = calcular_dias_retraso(detalle.fecha_devolucion_esperada, recibido_en)

        detalle.devolucion = Devolucion(
            prestamo_detalle_id=detalle.id,
            fecha_devolucion=recibido_en,
            condicion=item.condicion,
            observaciones=item.observaciones,
            recibido_por_id=personal.id,
            dias_retraso=dias,
            multa_monto=multa_servicio.calcular_multa(dias, item.condicion, material),
        )
        material_estado_servicio.recibir(material, item.condicion)

    estado_prestamo_servicio.recalcular(prestamo, ahora, fecha_devolucion_real=recibido_en)
    material_estado_servicio.recalcular(db, list(materiales.values()), ahora)

    auditoria_prestamo.registrar(
        db, personal, "DEVOLUCION_REGISTRADA", prestamo,
        {
            "items": [
                {"material": detalles[i.prestamo_detalle_id].material.codigo, "condicion": i.condicion}
                for i in items
            ],
            # Solo si la devolucion se anoto con otra fecha: queda quien, cuando y por que.
            **(
                {
                    "fecha_devolucion_indicada": recibido_en.isoformat(),
                    "registrado_en": ahora.isoformat(),
                    "motivo_fecha": motivo_fecha.strip(),
                }
                if fecha_devolucion is not None
                else {}
            ),
        },
    )
    db.commit()
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)
