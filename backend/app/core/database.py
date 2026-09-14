from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from .config import configuracion


# Crear motor de base de datos
# Usamos la URL local para desarrollo fuera de Docker
engine = create_engine(
    configuracion.BASE_DATOS_URL,
    echo=configuracion.MODO_DEBUG,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

# Crear sesion de base de datos
SesionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


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
