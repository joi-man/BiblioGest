"""Equipo: que hacer con los lotes que el servidor rechazo.

El bibliotecario decide entre dos caminos:
- reintentar: el lote vuelve a la bandeja de salida (util si el problema ya se
  arreglo, por ejemplo se devolvio la unidad que estaba prestada);
- descartar: se deshacen los cambios locales y se recupera la version del servidor.
"""
from typing import Dict, List, Set, Tuple
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.modelos.sincronizacion import LOTE_CONFLICTO, LOTE_PENDIENTE, SyncLote
from app.sync import descarga, estado_local
from app.sync.cliente_central import ClienteCentral
from app.sync.tablas import TABLAS_POR_NOMBRE

Clave = Tuple[str, str]


def listar(db: Session) -> List[SyncLote]:
    consulta = (
        select(SyncLote).where(SyncLote.estado == LOTE_CONFLICTO).order_by(SyncLote.creado_en)
    )
    return list(db.execute(consulta).scalars().all())


def _obtener_conflicto(db: Session, lote_id: UUID) -> SyncLote:
    lote = db.get(SyncLote, lote_id)
    if lote is None or lote.estado != LOTE_CONFLICTO:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No hay un conflicto con ese id")
    return lote


def reintentar(db: Session, lote_id: UUID) -> None:
    """Devuelve el lote a la bandeja de salida para enviarlo en la proxima sincronizacion."""
    lote = _obtener_conflicto(db, lote_id)
    lote.estado = LOTE_PENDIENTE
    lote.mensaje = None
    db.commit()


def lotes_afectados(db: Session, lote: SyncLote) -> List[SyncLote]:
    """El lote y los posteriores que dependen de sus filas.

    Si se descarta una prestamo, tambien hay que descartar la devolucion que se
    registro despues sobre ese prestamo: ya no tendria a que referirse.
    """
    afectados = [lote]
    claves: Set[Clave] = set(estado_local.claves_de(lote))
    posteriores = list(
        db.execute(
            select(SyncLote)
            .where(SyncLote.creado_en >= lote.creado_en, SyncLote.id != lote.id)
            .order_by(SyncLote.creado_en)
        ).scalars()
    )

    crecio = True
    while crecio:
        crecio = False
        for candidato in posteriores:
            if candidato in afectados:
                continue
            if estado_local.claves_de(candidato) & claves:
                afectados.append(candidato)
                claves |= estado_local.claves_de(candidato)
                crecio = True
    return afectados


def descartar(db: Session, cliente: ClienteCentral, lote_id: UUID) -> int:
    """Deshace los cambios locales del lote. Devuelve cuantos lotes se descartaron.

    Las filas que solo existian en este equipo se eliminan; las demas se
    reemplazan por la version del servidor (por eso hace falta conexion).
    """
    lote = _obtener_conflicto(db, lote_id)
    afectados = lotes_afectados(db, lote)

    insertadas: Set[Clave] = set()
    tocadas: Set[Clave] = set()
    for afectado in afectados:
        for fila in afectado.filas:
            clave = (fila["tabla"], fila["id"])
            tocadas.add(clave)
            if fila["op"] == "insert":
                insertadas.add(clave)

    a_refrescar: Dict[str, List[str]] = {}
    for tabla, id_texto in tocadas - insertadas:
        a_refrescar.setdefault(tabla, []).append(id_texto)

    # Primero se trae lo del servidor: si falla la conexion no se pierde nada.
    descargadas = {
        tabla: cliente.obtener_filas(tabla, ids) for tabla, ids in a_refrescar.items()
    }

    for afectado in afectados:
        db.delete(afectado)
    db.commit()

    descarga.borrar_filas(db, list(insertadas))
    for tabla, filas in descargadas.items():
        descarga.aplicar_filas(db, TABLAS_POR_NOMBRE[tabla], filas, protegidas=set())
    return len(afectados)
