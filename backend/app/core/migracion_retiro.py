"""Agrega a una base existente la fecha de retiro que propone el usuario al reservar.

Lo usan la migracion de Alembic (servidor) y el arranque de la API y del ejecutable
de escritorio (SQLite, sin Alembic). Es repetible.
"""
from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection


def agregar_fecha_retiro_solicitada(conexion: Connection) -> None:
    columnas = {c["name"] for c in inspect(conexion).get_columns("prestamos_cabecera")}
    if "fecha_retiro_solicitada" in columnas:
        return
    tipo = "DATETIME" if conexion.dialect.name == "sqlite" else "TIMESTAMP"
    conexion.execute(text(f"ALTER TABLE prestamos_cabecera ADD COLUMN fecha_retiro_solicitada {tipo}"))
