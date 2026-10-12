from typing import List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.paginacion import Pagina
from app.esquemas.usuario import UsuarioCrear, UsuarioActualizar, UsuarioRespuesta
from app.modelos.usuario import Usuario
from app.rutas.dependencias_listados import (
    ParametrosPagina,
    armar_pagina,
    parametros_pagina,
    respuesta_de_descarga,
)
from app.servicios import usuario_servicio
from app.servicios.exportacion.exportador import exportar
from app.servicios.exportacion.tabla_exportable import MAX_FILAS_EXPORTACION
from app.servicios.exportacion.usuarios_exportacion import tabla_de_usuarios

router = APIRouter(prefix="/api/usuarios", tags=["Usuarios"])


@router.get("/", response_model=List[UsuarioRespuesta])
def listar_usuarios(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Listar todos los usuarios."""
    usuarios = usuario_servicio.listar_usuarios(db)
    return [UsuarioRespuesta(
        id=str(u.id),
        username=u.username,
        correo_electronico=u.correo_electronico,
        numero_documento=u.numero_documento,
        nombre=u.nombre,
        apellido=u.apellido,
        rol=u.rol,
        telefono=u.telefono,
        activo=u.activo,
    ) for u in usuarios]


@router.get("/buscar", response_model=Pagina[UsuarioRespuesta])
def buscar_usuarios(
    q: Optional[str] = Query(None, description="Texto a buscar en nombre, usuario, correo o documento"),
    rol: Optional[str] = Query(None, description="admin, bibliotecario o estudiante"),
    activo: Optional[bool] = Query(None, description="Filtra por usuarios activos o inactivos"),
    paginacion: ParametrosPagina = Depends(parametros_pagina),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Una pagina de usuarios con busqueda y filtros."""
    usuarios, total = usuario_servicio.buscar_usuarios(
        db, paginacion.pagina, paginacion.tamano, texto=q, rol=rol, activo=activo
    )
    return armar_pagina(
        [UsuarioRespuesta.model_validate(u) for u in usuarios], total, paginacion
    )


@router.get("/exportar")
def exportar_usuarios(
    formato: str = Query("xlsx", description="xlsx o pdf"),
    q: Optional[str] = Query(None),
    rol: Optional[str] = Query(None),
    activo: Optional[bool] = Query(None),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Descarga todos los usuarios que cumplen el filtro (no solo una pagina)."""
    usuarios = usuario_servicio.listar_usuarios(
        db, texto=q, rol=rol, activo=activo, limite=MAX_FILAS_EXPORTACION
    )
    tabla = tabla_de_usuarios(usuarios, busqueda=q, rol=rol, activo=activo)
    return respuesta_de_descarga(exportar(tabla, formato, "usuarios"))


@router.get("/{usuario_id}", response_model=UsuarioRespuesta)
def obtener_usuario(
    usuario_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Obtener un usuario por ID."""
    usuario_encontrado = usuario_servicio.obtener_usuario_por_id(db, usuario_id)
    if usuario_encontrado is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    return UsuarioRespuesta(
        id=str(usuario_encontrado.id),
        username=usuario_encontrado.username,
        correo_electronico=usuario_encontrado.correo_electronico,
        numero_documento=usuario_encontrado.numero_documento,
        nombre=usuario_encontrado.nombre,
        apellido=usuario_encontrado.apellido,
        rol=usuario_encontrado.rol,
        telefono=usuario_encontrado.telefono,
        activo=usuario_encontrado.activo,
    )


@router.post("/", response_model=UsuarioRespuesta, status_code=status.HTTP_201_CREATED)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Crear un nuevo usuario."""
    usuario_creado = usuario_servicio.crear_usuario(
        db=db,
        username=datos.username,
        correo_electronico=datos.correo_electronico,
        contrasena=datos.contrasena,
        numero_documento=datos.numero_documento,
        nombre=datos.nombre,
        apellido=datos.apellido,
        rol=datos.rol,
        telefono=datos.telefono,
        usuario_admin=usuario,
    )
    return UsuarioRespuesta(
        id=str(usuario_creado.id),
        username=usuario_creado.username,
        correo_electronico=usuario_creado.correo_electronico,
        numero_documento=usuario_creado.numero_documento,
        nombre=usuario_creado.nombre,
        apellido=usuario_creado.apellido,
        rol=usuario_creado.rol,
        telefono=usuario_creado.telefono,
        activo=usuario_creado.activo,
    )


@router.put("/{usuario_id}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    usuario_id: UUID,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Actualizar un usuario."""
    usuario_actualizado = usuario_servicio.actualizar_usuario(
        db=db,
        usuario_id=usuario_id,
        correo_electronico=datos.correo_electronico,
        numero_documento=datos.numero_documento,
        contrasena=datos.contrasena,
        nombre=datos.nombre,
        apellido=datos.apellido,
        rol=datos.rol,
        telefono=datos.telefono,
        activo=datos.activo,
        usuario_admin=usuario,
    )
    return UsuarioRespuesta(
        id=str(usuario_actualizado.id),
        username=usuario_actualizado.username,
        correo_electronico=usuario_actualizado.correo_electronico,
        numero_documento=usuario_actualizado.numero_documento,
        nombre=usuario_actualizado.nombre,
        apellido=usuario_actualizado.apellido,
        rol=usuario_actualizado.rol,
        telefono=usuario_actualizado.telefono,
        activo=usuario_actualizado.activo,
    )


@router.delete("/{usuario_id}", status_code=status.HTTP_200_OK)
def eliminar_usuario(
    usuario_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Eliminar logicamente un usuario."""
    usuario_servicio.eliminar_usuario(
        db=db,
        usuario_id=usuario_id,
        usuario_admin=usuario,
    )
    return {"mensaje": "Usuario eliminado correctamente"}
