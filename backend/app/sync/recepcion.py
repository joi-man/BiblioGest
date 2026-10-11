"""Servidor central: recibe los lotes de los equipos y los aplica.

Cada lote se aplica completo o se rechaza completo. Un cambio a una fila
existente solo se acepta si la fila sigue en la version en la que se baso el
equipo; si no, alguien la cambio antes y el lote queda como conflicto.
"""
from dataclasses import dataclass
from typing import Any, Dict, List, Optional
from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core import reloj
from app.modelos.sincronizacion import SyncLoteRecibido
from app.modelos.usuario import Usuario
from app.sync.serializador import datos_desde_json
from app.sync.tablas import POSICION_TABLA, TABLAS_POR_NOMBRE, TablaSync

ESTADO_APLICADO = "aplicado"
ESTADO_CONFLICTO = "conflicto"
ESTADO_ERROR = "error"

# Valor que reemplaza la contrasena de quien no usa el ejecutable (estudiantes).
# Nunca debe escribirse en el servidor.
HASH_NO_REPLICADO = "!"

# Columnas que el servidor decide; nunca se copian desde el equipo.
_COLUMNAS_DEL_SERVIDOR = ("version", "fecha_actualizacion")
# Columnas que no cambian despues de crear la fila.
_COLUMNAS_INMUTABLES = ("id", "fecha_creacion")


class ConflictoSincronizacion(Exception):
    """El lote no puede aplicarse; el mensaje explica por que."""


@dataclass
class ResultadoLote:
    id: str
    estado: str
    mensaje: Optional[str] = None


def recibir_lotes(db: Session, lotes: List[Dict[str, Any]], usuario: Usuario) -> List[ResultadoLote]:
    """Aplica cada lote por separado y devuelve el resultado de cada uno, en orden."""
    return [_procesar_lote(db, lote, usuario) for lote in lotes]


def _procesar_lote(db: Session, lote: Dict[str, Any], usuario: Usuario) -> ResultadoLote:
    lote_id = UUID(lote["id"])
    if db.get(SyncLoteRecibido, lote_id) is not None:
        return ResultadoLote(lote["id"], ESTADO_APLICADO)  # reintento de un lote ya aplicado

    try:
        _aplicar_filas(db, lote["filas"], usuario)
        db.add(SyncLoteRecibido(id=lote_id, usuario_id=usuario.id))
        db.commit()
        return ResultadoLote(lote["id"], ESTADO_APLICADO)
    except ConflictoSincronizacion as error:
        db.rollback()
        return ResultadoLote(lote["id"], ESTADO_CONFLICTO, str(error))
    except IntegrityError:
        db.rollback()
        return ResultadoLote(
            lote["id"],
            ESTADO_CONFLICTO,
            "Choca con datos del servidor (un codigo, usuario, correo o documento repetido, "
            "o un registro del que depende ya no existe).",
        )
    except Exception as error:  # noqa: BLE001 - se informa al equipo y se reintenta mas tarde
        db.rollback()
        return ResultadoLote(lote["id"], ESTADO_ERROR, f"Error del servidor: {error}")


def _aplicar_filas(db: Session, filas: List[Dict[str, Any]], usuario: Usuario) -> None:
    # Primero las filas nuevas y luego las modificadas, cada grupo en orden de dependencia.
    ordenadas = sorted(
        filas,
        key=lambda f: (f["op"] != "insert", POSICION_TABLA.get(f["tabla"], len(POSICION_TABLA))),
    )
    for fila in ordenadas:
        tabla = TABLAS_POR_NOMBRE.get(fila["tabla"])
        if tabla is None:
            raise ConflictoSincronizacion(f"Tabla desconocida: {fila['tabla']}")
        _validar_permiso(tabla, usuario)
        if fila["op"] == "insert":
            _insertar(db, tabla, fila)
        else:
            _modificar(db, tabla, fila)
    db.flush()  # fuerza ahora los errores de integridad para poder rechazar el lote


def _validar_permiso(tabla: TablaSync, usuario: Usuario) -> None:
    if usuario.rol not in tabla.roles_subida:
        raise ConflictoSincronizacion(
            f"Tu rol ({usuario.rol}) no puede enviar cambios de {tabla.etiqueta.lower()}."
        )


def _insertar(db: Session, tabla: TablaSync, fila: Dict[str, Any]) -> None:
    clave = UUID(fila["id"])
    if db.get(tabla.modelo, clave) is not None:
        raise ConflictoSincronizacion(f"{tabla.etiqueta} ya existe en el servidor.")
    datos = datos_desde_json(tabla.modelo, fila["datos"])
    for columna in _COLUMNAS_DEL_SERVIDOR:
        datos.pop(columna, None)
    db.add(tabla.modelo(**datos))


def _modificar(db: Session, tabla: TablaSync, fila: Dict[str, Any]) -> None:
    if not tabla.admite_modificar:
        raise ConflictoSincronizacion(f"{tabla.etiqueta} no admite modificaciones.")

    existente = db.get(tabla.modelo, UUID(fila["id"]))
    if existente is None:
        raise ConflictoSincronizacion(f"{tabla.etiqueta} ya no existe en el servidor.")
    if existente.version != fila["base_version"]:
        raise ConflictoSincronizacion(
            f"{tabla.etiqueta} cambio en el servidor mientras trabajabas sin conexion "
            f"(version {existente.version}; tu cambio partia de la {fila['base_version']})."
        )

    datos = datos_desde_json(tabla.modelo, fila["datos"])
    for clave, valor in datos.items():
        if clave in _COLUMNAS_DEL_SERVIDOR or clave in _COLUMNAS_INMUTABLES:
            continue
        if clave == "contrasena_hash" and valor == HASH_NO_REPLICADO:
            continue
        setattr(existente, clave, valor)
    # Fuerza el cambio aunque los valores sean iguales, para que la version
    # del servidor suba igual que la del equipo.
    existente.fecha_actualizacion = reloj.ahora_utc()
