"""Datos propios del equipo (servidor, cursores de descarga) y consultas sobre su bandeja de salida."""
from datetime import datetime
from typing import Optional, Set, Tuple

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.modelos.sincronizacion import (
    LOTE_CONFLICTO,
    LOTE_PENDIENTE,
    ConfiguracionLocal,
    SyncLote,
)

CLAVE_SERVIDOR_URL = "servidor_url"
CLAVE_ULTIMA_SINCRONIZACION = "ultima_sincronizacion"
CLAVE_ULTIMO_ERROR = "ultimo_error"
PREFIJO_CURSOR = "cursor."


def leer(db: Session, clave: str, defecto: Optional[str] = None) -> Optional[str]:
    fila = db.get(ConfiguracionLocal, clave)
    return fila.valor if fila is not None and fila.valor is not None else defecto


def escribir(db: Session, clave: str, valor: Optional[str]) -> None:
    """Guarda un valor (o lo borra si es None) y confirma."""
    fila = db.get(ConfiguracionLocal, clave)
    if valor is None:
        if fila is not None:
            db.delete(fila)
    elif fila is None:
        db.add(ConfiguracionLocal(clave=clave, valor=valor))
    else:
        fila.valor = valor
    db.commit()


def servidor_url(db: Session) -> Optional[str]:
    return leer(db, CLAVE_SERVIDOR_URL)


def borrar_cursores(db: Session) -> None:
    for fila in db.execute(select(ConfiguracionLocal)).scalars().all():
        if fila.clave.startswith(PREFIJO_CURSOR):
            db.delete(fila)
    db.commit()


def marcar_sincronizado(db: Session, ahora: datetime) -> None:
    escribir(db, CLAVE_ULTIMA_SINCRONIZACION, ahora.isoformat())
    escribir(db, CLAVE_ULTIMO_ERROR, None)


def contar_lotes(db: Session, estado: str) -> int:
    return len(list(db.execute(select(SyncLote.id).where(SyncLote.estado == estado)).all()))


def claves_de(lote: SyncLote) -> Set[Tuple[str, str]]:
    """(tabla, id) de las filas que toca un lote."""
    return {(fila["tabla"], fila["id"]) for fila in lote.filas}


def claves_sin_sincronizar(db: Session) -> Set[Tuple[str, str]]:
    """Filas con cambios locales que el servidor aun no acepto.

    Mientras sigan asi, lo que se descarga del servidor no debe pisarlas.
    """
    consulta = select(SyncLote).where(SyncLote.estado.in_([LOTE_PENDIENTE, LOTE_CONFLICTO]))
    claves: Set[Tuple[str, str]] = set()
    for lote in db.execute(consulta).scalars().all():
        claves |= claves_de(lote)
    return claves
