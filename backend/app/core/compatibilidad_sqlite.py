"""Ajustes para que los modelos (pensados para PostgreSQL) funcionen en SQLite.

El ejecutable de escritorio guarda sus datos en SQLite. Este modulo se importa
una sola vez al crear el motor de base de datos.
"""
from sqlalchemy import event
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine import Engine
from sqlalchemy.ext.compiler import compiles


@compiles(JSONB, "sqlite")
def _jsonb_en_sqlite(elemento, compilador, **kw):
    """SQLite no tiene JSONB: se guarda como JSON."""
    return "JSON"


def preparar_conexiones_sqlite(motor: Engine) -> None:
    """Activa claves foraneas y un modo de escritura que tolera varios lectores.

    - foreign_keys: SQLite no las verifica salvo que se le pida.
    - WAL: permite leer mientras otro hilo escribe (peticiones y sincronizacion).
    - busy_timeout: espera hasta 15 s si la base esta ocupada en vez de fallar.
    """

    @event.listens_for(motor, "connect")
    def _al_conectar(conexion, _registro):
        cursor = conexion.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA busy_timeout=15000")
        cursor.close()
