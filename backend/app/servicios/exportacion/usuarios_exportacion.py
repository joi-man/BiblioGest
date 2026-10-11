"""Arma la tabla exportable del listado de usuarios."""
from typing import Optional, Sequence

from app.modelos.usuario import Usuario
from app.servicios.exportacion.tabla_exportable import TablaExportable
from app.servicios.exportacion.texto_listado import describir_filtros, etiqueta, texto

COLUMNAS = ["Documento", "Nombre", "Apellido", "Usuario", "Correo", "Telefono", "Rol", "Estado"]


def tabla_de_usuarios(
    usuarios: Sequence[Usuario],
    busqueda: Optional[str] = None,
    rol: Optional[str] = None,
    activo: Optional[bool] = None,
) -> TablaExportable:
    """Una fila por usuario, con la descripcion de los filtros usados."""
    estado = None if activo is None else ("Activo" if activo else "Inactivo")
    filas = [
        [
            u.numero_documento,
            u.nombre,
            u.apellido,
            u.username,
            u.correo_electronico,
            texto(u.telefono),
            etiqueta(u.rol),
            "Activo" if u.activo else "Inactivo",
        ]
        for u in usuarios
    ]
    return TablaExportable(
        titulo="Usuarios de BiblioGest",
        columnas=COLUMNAS,
        filas=filas,
        descripcion=describir_filtros(busqueda=busqueda, rol=rol, estado=estado) + f" | Total: {len(filas)}",
    )
