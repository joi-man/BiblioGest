from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

from . import compatibilidad_sqlite
from .config import configuracion

# Clave de Session.info que marca las sesiones del ejecutable de escritorio:
# solo ellas registran sus cambios para sincronizarlos con el servidor central.
CLAVE_MODO_LOCAL = "modo_local"


def es_modo_local() -> bool:
    """Indica si esta instancia es el ejecutable de escritorio (SQLite)."""
    return configuracion.MODO_APLICACION == "local"


def _crear_motor():
    """Crea el motor segun la base configurada (PostgreSQL o SQLite)."""
    url = configuracion.BASE_DATOS_URL
    if url.startswith("sqlite"):
        motor = create_engine(
            url,
            echo=configuracion.MODO_DEBUG,
            connect_args={"check_same_thread": False},
        )
        compatibilidad_sqlite.preparar_conexiones_sqlite(motor)
        return motor
    return create_engine(
        url,
        echo=configuracion.MODO_DEBUG,
        pool_pre_ping=True,
        pool_size=10,
        max_overflow=20,
    )


engine = _crear_motor()

# Crear sesion de base de datos
SesionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    info={CLAVE_MODO_LOCAL: es_modo_local()},
)


class Base(DeclarativeBase):
    """Clase base para todos los modelos de SQLAlchemy."""
    pass


def obtener_db():
    """Dependency para obtener una sesion de base de datos."""
    db = SesionLocal()
    try:
        yield db
    finally:
        db.close()
