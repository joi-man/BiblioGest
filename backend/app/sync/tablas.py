"""Tablas que participan en la sincronizacion, en orden de dependencia."""
from dataclasses import dataclass
from typing import Dict, Tuple

from app.modelos.autor import Autor, MaterialAutor
from app.modelos.bitacora import BitacoraAccion
from app.modelos.categoria import Categoria
from app.modelos.devolucion import Devolucion
from app.modelos.material import Material
from app.modelos.prestamo_cabecera import PrestamoCabecera
from app.modelos.prestamo_detalle import PrestamoDetalle
from app.modelos.usuario import Usuario

SOLO_ADMIN = ("admin",)
PERSONAL = ("admin", "bibliotecario")


@dataclass(frozen=True)
class TablaSync:
    nombre: str
    modelo: type
    etiqueta: str  # nombre legible en singular
    campo_descripcion: str  # campo que identifica la fila ante una persona
    # Roles que pueden subir cambios de esta tabla. Sincronizar salta las reglas
    # de las rutas, asi que aqui se repiten las mas importantes (por ejemplo,
    # solo un administrador puede crear o cambiar usuarios).
    roles_subida: Tuple[str, ...] = PERSONAL
    # False: el equipo solo envia (bitacora); no se descarga.
    se_descarga: bool = True
    # False: solo se aceptan filas nuevas, nunca modificaciones (bitacora).
    admite_modificar: bool = True


# El orden importa: una fila solo puede apuntar a filas de tablas anteriores.
TABLAS: Tuple[TablaSync, ...] = (
    TablaSync("categorias", Categoria, "Categoria", "nombre", roles_subida=SOLO_ADMIN),
    TablaSync("usuarios", Usuario, "Usuario", "username", roles_subida=SOLO_ADMIN),
    TablaSync("autores", Autor, "Autor", "nombre"),
    TablaSync("materiales", Material, "Material", "codigo"),
    TablaSync("materiales_autores", MaterialAutor, "Autor de un material", "id"),
    TablaSync("prestamos_cabecera", PrestamoCabecera, "Prestamo", "estado"),
    TablaSync("prestamos_detalle", PrestamoDetalle, "Item de prestamo", "id"),
    TablaSync("devoluciones", Devolucion, "Devolucion", "condicion"),
    TablaSync(
        "bitacora_acciones",
        BitacoraAccion,
        "Registro de bitacora",
        "accion",
        se_descarga=False,
        admite_modificar=False,
    ),
)

TABLAS_POR_NOMBRE: Dict[str, TablaSync] = {t.nombre: t for t in TABLAS}
POSICION_TABLA: Dict[str, int] = {t.nombre: i for i, t in enumerate(TABLAS)}

# Acciones de la bitacora que no vale la pena enviar al servidor (una por cada inicio de sesion).
ACCIONES_BITACORA_LOCALES = ("LOGIN", "LOGIN_FAILED", "LOGOUT")
