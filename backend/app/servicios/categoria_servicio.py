from typing import List, Optional
from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import select
from fastapi import HTTPException, status
from app.modelos.categoria import Categoria
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio


def listar_categorias(db: Session) -> List[Categoria]:
    """Listar todas las categorias (excluyendo eliminadas)."""
    stmt = select(Categoria).where(Categoria.eliminado == False).order_by(Categoria.nombre)
    return list(db.execute(stmt).scalars().all())


def obtener_categoria_por_id(db: Session, categoria_id: UUID) -> Optional[Categoria]:
    """Obtener una categoria por ID (excluyendo eliminadas)."""
    stmt = select(Categoria).where(
        Categoria.id == categoria_id,
        Categoria.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def obtener_categoria_por_nombre(db: Session, nombre: str) -> Optional[Categoria]:
    """Obtener una categoria por nombre."""
    stmt = select(Categoria).where(
        Categoria.nombre == nombre,
        Categoria.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def crear_categoria(
    db: Session,
    nombre: str,
    descripcion: Optional[str] = None,
    usuario_admin: Optional[Usuario] = None,
) -> Categoria:
    """Crear una nueva categoria."""
    # Verificar que el nombre no este en uso
    if obtener_categoria_por_nombre(db, nombre):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe una categoria con ese nombre"
        )
    
    # Crear categoria
    categoria = Categoria(
        nombre=nombre,
        descripcion=descripcion,
    )
    db.add(categoria)
    db.commit()
    db.refresh(categoria)
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="CREATE",
        tabla_afectada="categorias",
        registro_id=categoria.id,
        detalles={"nombre": nombre},
    )
    
    return categoria


def actualizar_categoria(
    db: Session,
    categoria_id: UUID,
    nombre: Optional[str] = None,
    descripcion: Optional[str] = None,
    usuario_admin: Optional[Usuario] = None,
) -> Categoria:
    """Actualizar una categoria existente."""
    categoria = obtener_categoria_por_id(db, categoria_id)
    if categoria is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Categoria no encontrada"
        )
    
    # Verificar nombre unico si se esta cambiando
    if nombre and nombre != categoria.nombre:
        if obtener_categoria_por_nombre(db, nombre):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ya existe una categoria con ese nombre"
            )
        categoria.nombre = nombre
    
    if descripcion is not None:
        categoria.descripcion = descripcion
    
    db.commit()
    db.refresh(categoria)
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="UPDATE",
        tabla_afectada="categorias",
        registro_id=categoria.id,
        detalles={"nombre": categoria.nombre},
    )
    
    return categoria


def eliminar_categoria(
    db: Session,
    categoria_id: UUID,
    usuario_admin: Usuario,
) -> bool:
    """Eliminar logicamente una categoria."""
    categoria = obtener_categoria_por_id(db, categoria_id)
    if categoria is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Categoria no encontrada"
        )
    
    # Verificar si tiene materiales asociados
    from app.modelos.material import Material
    stmt = select(Material).where(
        Material.categoria_id == categoria_id,
        Material.eliminado == False
    )
    materiales = db.execute(stmt).scalars().all()
    if materiales:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se puede eliminar una categoria que tiene materiales asociados"
        )
    
    categoria.eliminado = True
    categoria.fecha_eliminacion = datetime.utcnow()
    db.commit()
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id,
        accion="DELETE",
        tabla_afectada="categorias",
        registro_id=categoria.id,
        detalles={"nombre": categoria.nombre},
    )
    
    return True
