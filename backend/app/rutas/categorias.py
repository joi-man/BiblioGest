from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.categoria import CategoriaActualizar, CategoriaCrear, CategoriaRespuesta
from app.modelos.usuario import Usuario
from app.servicios import categoria_servicio

router = APIRouter(prefix="/api/categorias", tags=["Categorias"])


@router.get("/", response_model=List[CategoriaRespuesta])
def listar_categorias(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista todas las categorias."""
    return categoria_servicio.listar_categorias(db)


@router.get("/{categoria_id}", response_model=CategoriaRespuesta)
def obtener_categoria(
    categoria_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Obtiene una categoria por ID."""
    categoria = categoria_servicio.obtener_categoria_por_id(db, categoria_id)
    if categoria is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Categoria no encontrada",
        )
    return categoria


@router.post("/", response_model=CategoriaRespuesta, status_code=status.HTTP_201_CREATED)
def crear_categoria(
    datos: CategoriaCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Crea una nueva categoria."""
    return categoria_servicio.crear_categoria(db, datos, usuario_admin=usuario)


@router.put("/{categoria_id}", response_model=CategoriaRespuesta)
def actualizar_categoria(
    categoria_id: UUID,
    datos: CategoriaActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Actualiza los campos enviados de una categoria."""
    return categoria_servicio.actualizar_categoria(
        db, categoria_id, datos, usuario_admin=usuario
    )


@router.delete("/{categoria_id}", status_code=status.HTTP_200_OK)
def eliminar_categoria(
    categoria_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin"])),
):
    """Elimina logicamente una categoria."""
    categoria_servicio.eliminar_categoria(db, categoria_id, usuario_admin=usuario)
    return {"mensaje": "Categoria eliminada correctamente"}
