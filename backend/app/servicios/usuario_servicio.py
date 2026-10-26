from typing import List, Optional, Tuple
from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import func, or_, select
from sqlalchemy.sql import Select
from app.core.paginacion import paginar
from fastapi import HTTPException, status
from app.modelos.usuario import Usuario
from app.core.seguridad import hashear_contrasena
from app.servicios import bitacora_servicio


def _consulta_usuarios(
    texto: Optional[str] = None,
    rol: Optional[str] = None,
    activo: Optional[bool] = None,
) -> Select:
    """Arma la consulta de usuarios no eliminados con los filtros indicados.

    - `texto`: busca en nombre completo, username, correo y documento.
    - `rol`: rol exacto (admin, bibliotecario o estudiante).
    - `activo`: True/False para filtrar por estado; None no filtra.
    """
    consulta = select(Usuario).where(Usuario.eliminado == False)  # noqa: E712

    if texto and texto.strip():
        patron = f"%{texto.strip()}%"
        consulta = consulta.where(
            or_(
                (Usuario.nombre + " " + Usuario.apellido).ilike(patron),
                Usuario.username.ilike(patron),
                Usuario.correo_electronico.ilike(patron),
                Usuario.numero_documento.ilike(patron),
            )
        )
    if rol:
        consulta = consulta.where(Usuario.rol == rol)
    if activo is not None:
        consulta = consulta.where(Usuario.activo == activo)

    return consulta.order_by(Usuario.fecha_creacion.desc(), Usuario.id)


def listar_usuarios(
    db: Session,
    texto: Optional[str] = None,
    rol: Optional[str] = None,
    activo: Optional[bool] = None,
    limite: Optional[int] = None,
) -> List[Usuario]:
    """Lista usuarios (excluyendo eliminados), con filtros y tope opcionales."""
    consulta = _consulta_usuarios(texto, rol, activo)
    if limite is not None:
        consulta = consulta.limit(limite)
    return list(db.execute(consulta).scalars().all())


def buscar_usuarios(
    db: Session,
    pagina: int,
    tamano: int,
    texto: Optional[str] = None,
    rol: Optional[str] = None,
    activo: Optional[bool] = None,
) -> Tuple[List[Usuario], int]:
    """Una pagina de usuarios y el total que cumple el filtro."""
    return paginar(db, _consulta_usuarios(texto, rol, activo), pagina, tamano)


def obtener_usuario_por_id(db: Session, usuario_id: UUID) -> Optional[Usuario]:
    """Obtener un usuario por ID (excluyendo eliminados)."""
    stmt = select(Usuario).where(
        Usuario.id == usuario_id,
        Usuario.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def obtener_usuario_por_correo(db: Session, correo_electronico: str) -> Optional[Usuario]:
    """Obtener un usuario por correo electronico, sin distinguir mayusculas.

    Los teclados de los telefonos suelen poner la primera letra en mayuscula, y
    un correo no cambia por eso.
    """
    stmt = select(Usuario).where(
        func.lower(Usuario.correo_electronico) == correo_electronico.strip().lower(),
        Usuario.eliminado == False
    )
    return db.execute(stmt).scalars().first()


def obtener_usuario_por_username(db: Session, username: str) -> Optional[Usuario]:
    """Obtener un usuario por username."""
    stmt = select(Usuario).where(
        Usuario.username == username,
        Usuario.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def obtener_usuario_por_documento(db: Session, numero_documento: str) -> Optional[Usuario]:
    """Obtener un usuario por numero de documento."""
    stmt = select(Usuario).where(
        Usuario.numero_documento == numero_documento,
        Usuario.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def crear_usuario(
    db: Session,
    username: str,
    correo_electronico: str,
    contrasena: str,
    numero_documento: str,
    nombre: str,
    apellido: str,
    rol: str = "estudiante",
    telefono: Optional[str] = None,
    usuario_admin: Optional[Usuario] = None,
) -> Usuario:
    """Crear un nuevo usuario."""
    if obtener_usuario_por_username(db, username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nombre de usuario ya está en uso"
        )
    
    if obtener_usuario_por_correo(db, correo_electronico):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El correo electrónico ya está en uso"
        )
    
    if obtener_usuario_por_documento(db, numero_documento):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El número de documento ya está registrado"
        )
    
    usuario = Usuario(
        username=username,
        correo_electronico=correo_electronico,
        contrasena_hash=hashear_contrasena(contrasena),
        numero_documento=numero_documento,
        nombre=nombre,
        apellido=apellido,
        rol=rol,
        telefono=telefono,
    )
    db.add(usuario)
    db.commit()
    db.refresh(usuario)
    
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="CREATE",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        detalles={"correo_electronico": correo_electronico, "rol": rol},
    )
    
    return usuario


def actualizar_usuario(
    db: Session,
    usuario_id: UUID,
    correo_electronico: Optional[str] = None,
    numero_documento: Optional[str] = None,
    nombre: Optional[str] = None,
    apellido: Optional[str] = None,
    rol: Optional[str] = None,
    telefono: Optional[str] = None,
    activo: Optional[bool] = None,
    usuario_admin: Optional[Usuario] = None,
    contrasena: Optional[str] = None,
) -> Usuario:
    """Actualizar un usuario existente."""
    usuario = obtener_usuario_por_id(db, usuario_id)
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    if correo_electronico and correo_electronico != usuario.correo_electronico:
        if obtener_usuario_por_correo(db, correo_electronico):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El correo electrónico ya está en uso"
            )
        usuario.correo_electronico = correo_electronico
    
    if numero_documento and numero_documento != usuario.numero_documento:
        if obtener_usuario_por_documento(db, numero_documento):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El número de documento ya está registrado"
            )
        usuario.numero_documento = numero_documento
    
    if nombre is not None:
        usuario.nombre = nombre
    if apellido is not None:
        usuario.apellido = apellido
    if rol is not None:
        usuario.rol = rol
    if telefono is not None:
        usuario.telefono = telefono
    if activo is not None:
        if not activo and usuario_admin is not None and usuario.id == usuario_admin.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No puedes suspender tu propia cuenta",
            )
        usuario.activo = activo
    if contrasena:
        usuario.contrasena_hash = hashear_contrasena(contrasena)
    
    usuario.fecha_actualizacion = datetime.utcnow()
    db.commit()
    db.refresh(usuario)
    
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="UPDATE",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        detalles={"correo_electronico": usuario.correo_electronico, "activo": usuario.activo},
    )
    
    return usuario


def eliminar_usuario(
    db: Session,
    usuario_id: UUID,
    usuario_admin: Usuario,
) -> bool:
    """Eliminar logicamente un usuario."""
    usuario = obtener_usuario_por_id(db, usuario_id)
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    if usuario.id == usuario_admin.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No puedes eliminar tu propia cuenta"
        )
    
    if usuario.rol == "admin" and usuario_admin.rol != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes permiso para eliminar a otro administrador"
        )
    
    usuario.eliminado = True
    usuario.fecha_eliminacion = datetime.utcnow()
    db.commit()
    
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id,
        accion="DELETE",
        tabla_afectada="usuarios",
        registro_id=usuario.id,
        detalles={"correo_electronico": usuario.correo_electronico},
    )
    
    return True
