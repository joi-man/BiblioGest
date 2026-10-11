"""Equipo: baja del servidor las filas que cambiaron y las aplica a la base local."""
from datetime import datetime, timedelta
from typing import Any, Dict, Iterable, List, Optional, Set, Tuple
from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from app.core.config import configuracion
from app.sync import estado_local
from app.sync.captura import aplicando_datos_del_servidor
from app.sync.cliente_central import ClienteCentral
from app.sync.serializador import datos_desde_json
from app.sync.tablas import TABLAS, TablaSync

Clave = Tuple[str, str]


def descargar_cambios(db: Session, cliente: ClienteCentral, protegidas: Set[Clave]) -> int:
    """Descarga todas las tablas en orden de dependencia. Devuelve cuantas filas se aplicaron.

    `protegidas`: filas con cambios locales sin aceptar; no se pisan.
    """
    total = 0
    for tabla in TABLAS:
        if tabla.se_descarga:
            total += _descargar_tabla(db, cliente, tabla, protegidas)
    return total


def _descargar_tabla(db: Session, cliente: ClienteCentral, tabla: TablaSync, protegidas: Set[Clave]) -> int:
    desde = _desde_guardado(db, tabla)
    despues_de_id: Optional[str] = None
    ultimo: Optional[Tuple[str, str]] = None
    aplicadas = 0

    while True:
        pagina = cliente.obtener_cambios(
            tabla.nombre, desde, despues_de_id, configuracion.SYNC_FILAS_POR_PAGINA
        )
        aplicadas += aplicar_filas(db, tabla, pagina["filas"], protegidas)
        if pagina["cursor_fecha"]:
            ultimo = (pagina["cursor_fecha"], pagina["cursor_id"])
        if not pagina["hay_mas"]:
            break
        desde = datetime.fromisoformat(pagina["cursor_fecha"])
        despues_de_id = pagina["cursor_id"]

    if ultimo is not None:
        estado_local.escribir(db, estado_local.PREFIJO_CURSOR + tabla.nombre, f"{ultimo[0]}|{ultimo[1]}")
    return aplicadas


def _desde_guardado(db: Session, tabla: TablaSync) -> Optional[datetime]:
    """Punto desde el que pedir cambios: el cursor guardado menos un margen.

    El margen evita perder filas confirmadas en el servidor justo despues de la
    ultima descarga; volver a aplicar una fila repetida no hace dano.
    """
    guardado = estado_local.leer(db, estado_local.PREFIJO_CURSOR + tabla.nombre)
    if not guardado:
        return None
    fecha = datetime.fromisoformat(guardado.split("|")[0])
    return fecha - timedelta(minutes=configuracion.SYNC_SOLAPAMIENTO_MINUTOS)


def aplicar_filas(
    db: Session,
    tabla: TablaSync,
    filas: Iterable[Dict[str, Any]],
    protegidas: Set[Clave],
) -> int:
    """Inserta o actualiza las filas recibidas, sin subir versiones ni crear lotes."""
    aplicadas = 0
    with aplicando_datos_del_servidor(db):
        for fila in filas:
            if (tabla.nombre, fila["id"]) in protegidas:
                continue
            try:
                with db.begin_nested():
                    if _aplicar_fila(db, tabla, fila):
                        aplicadas += 1
            except IntegrityError:
                # Choca con algo creado solo en este equipo; se resolvera como conflicto al enviarlo.
                continue
        db.commit()
    return aplicadas


def _aplicar_fila(db: Session, tabla: TablaSync, fila: Dict[str, Any]) -> bool:
    datos = datos_desde_json(tabla.modelo, fila["datos"])
    existente = db.get(tabla.modelo, UUID(fila["id"]))

    if existente is None:
        db.add(tabla.modelo(**datos))
        db.flush()
        return True

    if getattr(existente, "version", None) == fila.get("version") and (
        getattr(existente, "fecha_actualizacion", None) == datos.get("fecha_actualizacion")
    ):
        return False  # ya la teniamos

    for clave, valor in datos.items():
        setattr(existente, clave, valor)
    # Sin esto, SQLAlchemy reemplazaria la fecha por la de ahora (onupdate) si
    # solo cambio la version, y la fila local diferiria de la del servidor.
    if "fecha_actualizacion" in datos:
        flag_modified(existente, "fecha_actualizacion")
    db.flush()
    return True


def borrar_filas(db: Session, claves: List[Clave]) -> None:
    """Elimina del equipo filas que nunca llegaron al servidor (en orden inverso de dependencia)."""
    from app.sync.tablas import POSICION_TABLA, TABLAS_POR_NOMBRE

    with aplicando_datos_del_servidor(db):
        for tabla_nombre, id_texto in sorted(claves, key=lambda c: -POSICION_TABLA[c[0]]):
            fila = db.get(TABLAS_POR_NOMBRE[tabla_nombre].modelo, UUID(id_texto))
            if fila is not None:
                db.delete(fila)
                db.flush()
        db.commit()
