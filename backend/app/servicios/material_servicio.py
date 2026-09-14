from typing import List, Optional
from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import select
from fastapi import HTTPException, status
from app.modelos.material import Material
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio


def listar_materiales(db: Session) -> List[Material]:
    """Listar todos los materiales (excluyendo eliminados)."""
    stmt = select(Material).where(Material.eliminado == False).order_by(Material.fecha_creacion.desc())
    return list(db.execute(stmt).scalars().all())


def obtener_material_por_id(db: Session, material_id: UUID) -> Optional[Material]:
    """Obtener un material por ID (excluyendo eliminados)."""
    stmt = select(Material).where(
        Material.id == material_id,
        Material.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def obtener_material_por_codigo(db: Session, codigo: str) -> Optional[Material]:
    """Obtener un material por codigo."""
    stmt = select(Material).where(
        Material.codigo == codigo,
        Material.eliminado == False
    )
    return db.execute(stmt).scalar_one_or_none()


def crear_material(
    db: Session,
    codigo: str,
    titulo: str,
    tipo_material: str,
    categoria_id: UUID,
    autor: Optional[str] = None,
    descripcion: Optional[str] = None,
    isbn: Optional[str] = None,
    editorial: Optional[str] = None,
    anio_publicacion: Optional[int] = None,
    numero_paginas: Optional[int] = None,
    formato: Optional[str] = None,
    duracion: Optional[str] = None,
    imagen_url: Optional[str] = None,
    usuario_admin: Optional[Usuario] = None,
) -> Material:
    """Crear un nuevo material."""
    # Verificar que el codigo no este en uso
    if obtener_material_por_codigo(db, codigo):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El codigo del material ya esta en uso"
        )
    
    # Crear material
    material = Material(
        codigo=codigo,
        titulo=titulo,
        tipo_material=tipo_material,
        categoria_id=categoria_id,
        autor=autor,
        descripcion=descripcion,
        isbn=isbn,
        editorial=editorial,
        anio_publicacion=anio_publicacion,
        numero_paginas=numero_paginas,
        formato=formato,
        duracion=duracion,
        imagen_url=imagen_url,
    )
    db.add(material)
    db.commit()
    db.refresh(material)
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="CREATE",
        tabla_afectada="materiales",
        registro_id=material.id,
        detalles={"codigo": codigo, "titulo": titulo},
    )
    
    return material


def actualizar_material(
    db: Session,
    material_id: UUID,
    codigo: Optional[str] = None,
    titulo: Optional[str] = None,
    tipo_material: Optional[str] = None,
    estado: Optional[str] = None,
    categoria_id: Optional[UUID] = None,
    autor: Optional[str] = None,
    descripcion: Optional[str] = None,
    isbn: Optional[str] = None,
    editorial: Optional[str] = None,
    anio_publicacion: Optional[int] = None,
    numero_paginas: Optional[int] = None,
    formato: Optional[str] = None,
    duracion: Optional[str] = None,
    imagen_url: Optional[str] = None,
    usuario_admin: Optional[Usuario] = None,
) -> Material:
    """Actualizar un material existente."""
    material = obtener_material_por_id(db, material_id)
    if material is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado"
        )
    
    # Verificar codigo unico si se esta cambiando
    if codigo and codigo != material.codigo:
        if obtener_material_por_codigo(db, codigo):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El codigo del material ya esta en uso"
            )
        material.codigo = codigo
    
    # Actualizar campos
    if titulo is not None:
        material.titulo = titulo
    if tipo_material is not None:
        material.tipo_material = tipo_material
    if estado is not None:
        material.estado = estado
    if categoria_id is not None:
        material.categoria_id = categoria_id
    if autor is not None:
        material.autor = autor
    if descripcion is not None:
        material.descripcion = descripcion
    if isbn is not None:
        material.isbn = isbn
    if editorial is not None:
        material.editorial = editorial
    if anio_publicacion is not None:
        material.anio_publicacion = anio_publicacion
    if numero_paginas is not None:
        material.numero_paginas = numero_paginas
    if formato is not None:
        material.formato = formato
    if duracion is not None:
        material.duracion = duracion
    if imagen_url is not None:
        material.imagen_url = imagen_url
    
    material.fecha_actualizacion = datetime.utcnow()
    db.commit()
    db.refresh(material)
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="UPDATE",
        tabla_afectada="materiales",
        registro_id=material.id,
        detalles={"codigo": material.codigo, "titulo": material.titulo},
    )
    
    return material


def eliminar_material(
    db: Session,
    material_id: UUID,
    usuario_admin: Usuario,
) -> bool:
    """Eliminar logicamente un material."""
    material = obtener_material_por_id(db, material_id)
    if material is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado"
        )
    
    material.eliminado = True
    material.fecha_eliminacion = datetime.utcnow()
    db.commit()
    
    # Registrar en bitacora
    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id,
        accion="DELETE",
        tabla_afectada="materiales",
        registro_id=material.id,
        detalles={"codigo": material.codigo, "titulo": material.titulo},
    )
    
    return True
