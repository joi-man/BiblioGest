"""Actualiza una base de datos existente al modelo con autores, cantidades y tomos.

Lo usan la migracion de Alembic (servidor, PostgreSQL) y el arranque del
ejecutable de escritorio (SQLite), que no usa Alembic. Es repetible: lo que ya
esta hecho no se vuelve a hacer.

Los autores y sus vinculos reciben un ID calculado a partir del nombre (UUID v5),
asi el servidor y cada equipo que migran por separado llegan a los mismos IDs y
al sincronizar no aparecen autores duplicados.
"""
import uuid
from datetime import datetime

from sqlalchemy import inspect, select, text
from sqlalchemy.engine import Connection
from sqlalchemy.orm import Session

from app.core.database import Base
from app.core.texto_busqueda import normalizar
from app.modelos.autor import Autor, MaterialAutor
from app.modelos.material import Material
from app.servicios.autores import busqueda_material
from app.servicios.autores.vinculo_servicio import separar_nombres
from app.sync import captura

_ESPACIO_DE_NOMBRES = uuid.UUID("6f1c2b1e-4f7a-4c52-9d3e-0b1a5e8c7d10")

# (nombre, tipo SQL, valor por defecto o None si admite nulos)
_COLUMNAS_MATERIALES = (
    ("tomo", "VARCHAR(20)", None),
    ("total_tomos", "INTEGER", None),
    ("cantidad_total", "INTEGER", "1"),
    ("cantidad_reservada", "INTEGER", "0"),
    ("cantidad_prestada", "INTEGER", "0"),
    ("cantidad_vencida", "INTEGER", "0"),
    ("cantidad_fuera_servicio", "INTEGER", "0"),
    ("texto_busqueda", "TEXT", None),
)

# Estado que tenia cada unidad -> columna de cantidad que le corresponde.
_CANTIDAD_POR_ESTADO = {
    "reservado": "cantidad_reservada",
    "prestado": "cantidad_prestada",
    "vencido": "cantidad_vencida",
    "fuera_de_servicio": "cantidad_fuera_servicio",
}


def id_de_autor(nombre: str) -> uuid.UUID:
    return uuid.uuid5(_ESPACIO_DE_NOMBRES, normalizar(nombre))


def _id_de_vinculo(material_id: uuid.UUID, autor_id: uuid.UUID) -> uuid.UUID:
    return uuid.uuid5(_ESPACIO_DE_NOMBRES, f"{material_id}/{autor_id}")


def _agregar_columnas(conexion: Connection) -> bool:
    """Agrega a `materiales` las columnas que falten. Devuelve True si agrego alguna."""
    existentes = {c["name"] for c in inspect(conexion).get_columns("materiales")}
    agregadas = False
    for nombre, tipo, defecto in _COLUMNAS_MATERIALES:
        if nombre in existentes:
            continue
        definicion = f"{tipo} NOT NULL DEFAULT {defecto}" if defecto is not None else tipo
        conexion.execute(text(f"ALTER TABLE materiales ADD COLUMN {nombre} {definicion}"))
        agregadas = True
    return agregadas


def _cantidades_segun_estado(conexion: Connection) -> None:
    """Las unidades que ya estaban reservadas, prestadas... pasan a contar como un ejemplar."""
    for estado, columna in _CANTIDAD_POR_ESTADO.items():
        conexion.execute(
            text(f"UPDATE materiales SET {columna} = 1 WHERE estado = :estado"), {"estado": estado}
        )


def _autores_desde_texto(sesion: Session) -> None:
    """Crea un autor por cada nombre del campo de texto `autor` y lo vincula a su material."""
    autores = {a.id: a for a in sesion.execute(select(Autor)).scalars()}
    vinculados = {
        (v.material_id, v.autor_id)
        for v in sesion.execute(select(MaterialAutor)).scalars()
    }
    ahora = datetime.utcnow()
    for material in sesion.execute(select(Material)).scalars():
        if not material.autor or any(m == material.id for m, _ in vinculados):
            continue
        for orden, nombre in enumerate(dict.fromkeys(separar_nombres(material.autor))):
            autor_id = id_de_autor(nombre)
            if autor_id not in autores:
                autores[autor_id] = Autor(
                    id=autor_id, nombre=nombre, nombre_normalizado=normalizar(nombre),
                    fecha_creacion=ahora, fecha_actualizacion=ahora,
                )
                sesion.add(autores[autor_id])
            if (material.id, autor_id) not in vinculados:
                sesion.add(
                    MaterialAutor(
                        id=_id_de_vinculo(material.id, autor_id), material_id=material.id,
                        autor_id=autor_id, orden=orden,
                        fecha_creacion=ahora, fecha_actualizacion=ahora,
                    )
                )
                vinculados.add((material.id, autor_id))
    sesion.flush()


def actualizar_esquema_materiales(conexion: Connection) -> None:
    """Deja la base lista: tablas de autores, columnas nuevas y datos existentes convertidos."""
    Base.metadata.create_all(
        bind=conexion, tables=[Autor.__table__, MaterialAutor.__table__], checkfirst=True
    )
    columnas_nuevas = _agregar_columnas(conexion)
    if columnas_nuevas:
        _cantidades_segun_estado(conexion)

    sesion = Session(bind=conexion)
    try:
        with captura.aplicando_datos_del_servidor(sesion):  # no son cambios para sincronizar
            _autores_desde_texto(sesion)
            for material in sesion.execute(
                select(Material).where(Material.texto_busqueda.is_(None))
            ).scalars():
                busqueda_material.actualizar_texto(material)
            sesion.flush()
    finally:
        sesion.close()
