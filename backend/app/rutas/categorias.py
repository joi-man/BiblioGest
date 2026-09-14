from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.categoria import CategoriaCrear, CategoriaActualizar, CategoriaRespuesta
from app.modelos.usuario import Usuario
from app.servicios import categoria_servicio

router = APIRouter(prefix="/api/categorias", tags=["Categorias"])


@router.get("/", response_model=List[CategoriaRespuesta])
def listar_categorias(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Listar todas las categorias."""
    categorias = categoria_servicio.listar_categorias(db)
    return [CategoriaRespuesta(
        id=str(c.id),
        nombre=c.nombre,
        descripcion=c.descripcion,
        fecha_creacion=c.fecha_creacion,
    ) for c in categorias]


@router.get("/{categoria_id}", response_model=CategoriaRespuesta)
def obtener_categoria(
    categoria_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Obtener una categoria por ID."""
    categoria = categoria_servicio.obtener_categoria_por_id(db, categoria_id)
    if categoria is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Categoria no encontrada"
        )
    return CategoriaRespuesta(
        id=str(categoria.id),
        nombre=categoria.nombre,
        descripcion=categoria.descripcion,
        fecha_creacion=categoria.fecha_creacion,
    )


@router.post("/", response_model=CategoriaRespuesta, status_code=status.HTTP_201_CREATED)
def crear_categoria(
    datos: CategoriaCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Crear una nueva categoria."""
    categoria_creada = categoria_servicio.crear_categoria(
        db=db,
        nombre=datos.nombre,
        descripcion=datos.descripcion,
        usuario_admin=usuario,
    )
    return CategoriaRespuesta(
        id=str(categoria_creada.id),
        nombre=categoria_creada.nombre,
        descripcion=categoria_creada.descripcion,
        fecha_creacion=categoria_creada.fecha_creacion,
    )


@router.put("/{categoria_id}", response_model=CategoriaRespuesta)
def actualizar_categoria(
    categoria_id: UUID,
    datos: CategoriaActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Actualizar una categoria."""
    categoria_actualizada = categoria_servicio.actualizar_categoria(
        db=db,
        categoria_id=categoria_id,
        nombre=datos.nombre,
        descripcion=datos.descripcion,
        usuario_admin=usuario,
    )
    return CategoriaRespuesta(
        id=str(categoria_actualizada.id),
        nombre=categoria_actualizada.nombre,
        descripcion=categoria_actualizada.descripcion,
        fecha_creacion=categoria_actualizada.fecha_creacion,
    )


@router.delete("/{categoria_id}", status_code=status.HTTP_200_OK)
def eliminar_categoria(
    categoria_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Eliminar logicamente una categoria."""
    categoria_servicio.eliminar_categoria(
        db=db,
        categoria_id=categoria_id,
        usuario_admin=usuario,
    )
    return {"mensaje": "Categoria eliminada correctamente"}

