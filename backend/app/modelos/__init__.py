from .usuario import Usuario
from .categoria import Categoria
from .material import Material
from .prestamo_cabecera import PrestamoCabecera
from .prestamo_detalle import PrestamoDetalle
from .devolucion import Devolucion
from .bitacora import BitacoraAccion
from .codigo_recuperacion import CodigoRecuperacion
from .sincronizacion import ConfiguracionLocal, SyncLote, SyncLoteRecibido

__all__ = [
    "ConfiguracionLocal",
    "SyncLote",
    "SyncLoteRecibido",
    "CodigoRecuperacion",
    "Usuario",
    "Categoria",
    "Material",
    "PrestamoCabecera",
    "PrestamoDetalle",
    "Devolucion",
    "BitacoraAccion",
]

# Registra los enganches de SQLAlchemy que versionan y capturan los cambios.
from app.sync import captura  # noqa: E402,F401
