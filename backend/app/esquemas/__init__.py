from .usuario import UsuarioCrear, UsuarioActualizar, UsuarioRespuesta
from .categoria import CategoriaCrear, CategoriaActualizar, CategoriaRespuesta
from .material import MaterialCrear, MaterialActualizar, MaterialRespuesta
from .prestamo_cabecera import (
    PrestamoCabeceraCrear, 
    PrestamoCabeceraActualizar, 
    PrestamoCabeceraRespuesta
)
from .devolucion import DevolucionCrear, DevolucionRespuesta

__all__ = [
    "UsuarioCrear",
    "UsuarioActualizar", 
    "UsuarioRespuesta",
    "CategoriaCrear",
    "CategoriaActualizar",
    "CategoriaRespuesta",
    "MaterialCrear",
    "MaterialActualizar",
    "MaterialRespuesta",
    "PrestamoCabeceraCrear",
    "PrestamoCabeceraActualizar",
    "PrestamoCabeceraRespuesta",
    "DevolucionCrear",
    "DevolucionRespuesta",
]
