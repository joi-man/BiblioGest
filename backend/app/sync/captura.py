"""Captura de cambios: sube la `version` de las filas modificadas y, en el
ejecutable de escritorio, guarda cada transaccion como un lote para enviarlo
al servidor.

Se engancha a SQLAlchemy, asi los servicios y las rutas no necesitan saber
nada de sincronizacion. Todo ocurre dentro de la misma transaccion del cambio:
si la transaccion se deshace, el lote tambien.
"""
import threading
from contextlib import contextmanager
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import Any, Dict, List, Optional

from sqlalchemy import event
from sqlalchemy.orm import Session

from app.core.database import CLAVE_MODO_LOCAL
from app.modelos.sincronizable import Sincronizable
from app.modelos.sincronizacion import SyncLote

# Claves de Session.info
CLAVE_ENTRADAS = "sync_entradas"  # cambios de la transaccion en curso
CLAVE_SILENCIOSO = "sync_silencioso"  # True mientras se aplican filas recibidas del servidor
CLAVE_AUTOMATICO = "sync_automatico"  # True si el cambio lo origina el sistema, no una persona

_candado_reloj = threading.Lock()
_ultimo_instante = datetime.min


def _instante_creciente() -> datetime:
    """Hora actual, garantizando que cada llamada devuelva un valor mayor que la anterior.

    Los lotes se envian en el orden en que se crearon; si dos transacciones
    seguidas obtuvieran la misma hora, podrian enviarse al reves.
    """
    global _ultimo_instante
    with _candado_reloj:
        ahora = datetime.utcnow()
        if ahora <= _ultimo_instante:
            ahora = _ultimo_instante + timedelta(microseconds=1)
        _ultimo_instante = ahora
        return ahora


OPERACION_INSERTAR = "insert"
OPERACION_MODIFICAR = "update"


@dataclass
class EntradaCambio:
    """Una fila tocada durante la transaccion."""

    fila: Any
    operacion: str
    # Version de la fila antes de la transaccion (solo para modificaciones).
    version_base: Optional[int]


def marcar_como_automatico(db: Session) -> None:
    """Indica que los cambios de esta transaccion no los hizo una persona.

    Los lotes automaticos (por ejemplo "marcar vencido") no generan conflictos
    que revisar: si el servidor ya cambio esas filas, se descartan.
    """
    db.info[CLAVE_AUTOMATICO] = True


@contextmanager
def aplicando_datos_del_servidor(db: Session):
    """Dentro del bloque, los cambios no suben la version ni se guardan como lote."""
    db.info[CLAVE_SILENCIOSO] = True
    try:
        yield
    finally:
        db.info.pop(CLAVE_SILENCIOSO, None)


def _tabla_de(fila):
    from app.sync.tablas import TABLAS_POR_NOMBRE

    return TABLAS_POR_NOMBRE.get(getattr(fila, "__tablename__", None))


@event.listens_for(Session, "before_flush")
def _registrar_cambios(session: Session, contexto, instancias) -> None:
    """Anota las filas nuevas y modificadas y sube la version de las modificadas."""
    if session.info.get(CLAVE_SILENCIOSO):
        return
    entradas: Dict[int, EntradaCambio] = session.info.setdefault(CLAVE_ENTRADAS, {})

    for fila in session.new:
        if _tabla_de(fila) is None:
            continue
        if isinstance(fila, Sincronizable) and fila.version is None:
            fila.version = 1
        entradas.setdefault(id(fila), EntradaCambio(fila, OPERACION_INSERTAR, None))

    for fila in session.dirty:
        tabla = _tabla_de(fila)
        if tabla is None or not tabla.admite_modificar:
            continue
        if not session.is_modified(fila, include_collections=False):
            continue
        # La version sube una sola vez por transaccion, aunque haya varios flush.
        if id(fila) not in entradas:
            entradas[id(fila)] = EntradaCambio(fila, OPERACION_MODIFICAR, fila.version)
            fila.version = (fila.version or 1) + 1


@event.listens_for(Session, "before_commit")
def _guardar_lote(session: Session) -> None:
    """En el ejecutable, guarda los cambios de la transaccion como un lote pendiente."""
    session.flush()  # asegura que todo cambio pendiente quede registrado
    entradas = session.info.pop(CLAVE_ENTRADAS, None)
    automatico = session.info.pop(CLAVE_AUTOMATICO, False)

    if not entradas or session.info.get(CLAVE_SILENCIOSO):
        return
    if not session.info.get(CLAVE_MODO_LOCAL):
        return

    filas = _filas_del_lote(list(entradas.values()))
    if filas:
        session.add(
            SyncLote(
                creado_en=_instante_creciente(),
                filas=filas,
                descripcion=describir_lote(filas),
                automatico=bool(automatico),
            )
        )


@event.listens_for(Session, "after_rollback")
def _descartar_cambios(session: Session) -> None:
    """Si la transaccion se deshace, no queda nada que sincronizar."""
    session.info.pop(CLAVE_ENTRADAS, None)
    session.info.pop(CLAVE_AUTOMATICO, None)


def _filas_del_lote(entradas: List[EntradaCambio]) -> List[Dict[str, Any]]:
    from app.sync.serializador import fila_a_json
    from app.sync.tablas import ACCIONES_BITACORA_LOCALES

    filas = []
    for entrada in entradas:
        tabla = _tabla_de(entrada.fila)
        if tabla.nombre == "bitacora_acciones" and entrada.fila.accion in ACCIONES_BITACORA_LOCALES:
            continue
        filas.append(
            {
                "tabla": tabla.nombre,
                "id": str(entrada.fila.id),
                "op": entrada.operacion,
                "base_version": entrada.version_base,
                "datos": fila_a_json(entrada.fila),
            }
        )
    return filas


def describir_lote(filas: List[Dict[str, Any]]) -> str:
    """Resume un lote para mostrarlo a una persona. Ej.: "Prestamo «activo» nuevo · Material «PROY-001» modificado"."""
    from app.sync.tablas import TABLAS_POR_NOMBRE

    # Los items y la bitacora son detalle; se mencionan solo si no hay nada mas.
    secundarias = ("prestamos_detalle", "bitacora_acciones")
    principales = [f for f in filas if f["tabla"] not in secundarias] or filas

    partes = []
    for fila in principales[:5]:
        tabla = TABLAS_POR_NOMBRE[fila["tabla"]]
        valor = fila["datos"].get(tabla.campo_descripcion, "")
        accion = "nuevo" if fila["op"] == OPERACION_INSERTAR else "modificado"
        partes.append(f"{tabla.etiqueta} «{valor}» {accion}")
    if len(principales) > 5:
        partes.append(f"y {len(principales) - 5} mas")
    return " · ".join(partes)
