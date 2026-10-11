"""Servidor central: entrega a los equipos las filas que cambiaron."""
from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from app.sync.recepcion import HASH_NO_REPLICADO
from app.sync.serializador import fila_a_json, valor_a_json
from app.sync.tablas import PERSONAL, TablaSync


def _fila_para_descarga(tabla: TablaSync, fila) -> Dict[str, Any]:
    datos = fila_a_json(fila)
    # El ejecutable solo la necesita para iniciar sesion al personal; las demas
    # contrasenas no salen del servidor.
    if tabla.nombre == "usuarios" and fila.rol not in PERSONAL:
        datos["contrasena_hash"] = HASH_NO_REPLICADO
    return {"id": str(fila.id), "version": getattr(fila, "version", None), "datos": datos}


def obtener_cambios(
    db: Session,
    tabla: TablaSync,
    desde: Optional[datetime],
    despues_de_id: Optional[UUID],
    limite: int,
) -> Dict[str, Any]:
    """Filas modificadas desde un punto, ordenadas por (fecha_actualizacion, id).

    Con `despues_de_id` se continua exactamente despues de esa fila; sin el, se
    incluyen las filas con la misma fecha de `desde` (repetirlas es inocuo).
    """
    modelo = tabla.modelo
    consulta = select(modelo)
    if desde is not None:
        if despues_de_id is None:
            consulta = consulta.where(modelo.fecha_actualizacion >= desde)
        else:
            consulta = consulta.where(
                or_(
                    modelo.fecha_actualizacion > desde,
                    and_(modelo.fecha_actualizacion == desde, modelo.id > despues_de_id),
                )
            )
    consulta = consulta.order_by(modelo.fecha_actualizacion, modelo.id).limit(limite + 1)

    filas = list(db.execute(consulta).scalars().all())
    hay_mas = len(filas) > limite
    filas = filas[:limite]

    ultima = filas[-1] if filas else None
    return {
        "filas": [_fila_para_descarga(tabla, f) for f in filas],
        "hay_mas": hay_mas,
        "cursor_fecha": valor_a_json(ultima.fecha_actualizacion) if ultima else None,
        "cursor_id": str(ultima.id) if ultima else None,
    }


def obtener_filas(db: Session, tabla: TablaSync, ids: List[UUID]) -> List[Dict[str, Any]]:
    """Filas concretas por id (para refrescar lo que el equipo descarto)."""
    if not ids:
        return []
    consulta = select(tabla.modelo).where(tabla.modelo.id.in_(ids))
    return [_fila_para_descarga(tabla, f) for f in db.execute(consulta).scalars().all()]
