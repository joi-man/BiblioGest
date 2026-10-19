from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.constantes_inventario import TIPOS_BIBLIOGRAFICOS
from app.core.constantes_roles import ROLES_PERSONAL
from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.material import MaterialActualizar, MaterialCrear, MaterialRespuesta
from app.esquemas.paginacion import Pagina
from app.modelos.categoria import Categoria
from app.rutas.dependencias_listados import (
    ParametrosPagina,
    armar_pagina,
    parametros_pagina,
    respuesta_de_descarga,
)
from app.modelos.usuario import Usuario
from app.servicios import material_servicio
from app.servicios.exportacion.exportador import exportar
from app.servicios.exportacion.materiales_exportacion import tabla_de_materiales
from app.servicios.exportacion.tabla_exportable import MAX_FILAS_EXPORTACION

router = APIRouter(prefix="/api/materiales", tags=["Materiales"])


@router.get("/", response_model=List[MaterialRespuesta])
def listar_materiales(
    q: Optional[str] = Query(None, description="Palabras a buscar en titulo, autor, codigo, ISBN, editorial, marca, modelo o serie"),
    tipo: Optional[str] = Query(None, description="Tipo de material, por ejemplo 'proyector'"),
    estado: Optional[str] = Query(None, description="Estado del material"),
    disponible: bool = Query(False, description="Solo materiales prestables con algun ejemplar libre"),
    autor_id: Optional[UUID] = Query(None, description="Solo materiales de este autor"),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista los materiales, con busqueda y filtros opcionales.

    Un estudiante solo ve libros y revistas (y no las unidades fuera de servicio).
    """
    es_estudiante = usuario.rol not in ROLES_PERSONAL
    return material_servicio.listar_materiales(
        db,
        texto=q,
        tipo=tipo,
        estado=estado,
        solo_disponibles=disponible,
        tipos=TIPOS_BIBLIOGRAFICOS if es_estudiante else None,
        ocultar_fuera_de_servicio=es_estudiante,
        autor_id=autor_id,
    )


@router.get("/buscar", response_model=Pagina[MaterialRespuesta])
def buscar_materiales(
    q: Optional[str] = Query(None, description="Palabras a buscar en titulo, autor, codigo, ISBN, editorial, marca, modelo o serie"),
    tipo: Optional[str] = Query(None),
    estado: Optional[str] = Query(None),
    categoria_id: Optional[UUID] = Query(None),
    autor_id: Optional[UUID] = Query(None, description="Solo materiales de este autor"),
    paginacion: ParametrosPagina = Depends(parametros_pagina),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Una pagina del inventario con busqueda y filtros."""
    materiales, total = material_servicio.buscar_materiales(
        db,
        paginacion.pagina,
        paginacion.tamano,
        texto=q,
        tipo=tipo,
        estado=estado,
        categoria_id=categoria_id,
        autor_id=autor_id,
    )
    return armar_pagina(
        [MaterialRespuesta.model_validate(m) for m in materiales], total, paginacion
    )


@router.get("/exportar")
def exportar_materiales(
    formato: str = Query("xlsx", description="xlsx o pdf"),
    q: Optional[str] = Query(None),
    tipo: Optional[str] = Query(None),
    estado: Optional[str] = Query(None),
    categoria_id: Optional[UUID] = Query(None),
    autor_id: Optional[UUID] = Query(None),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Descarga todo el inventario que cumple el filtro (no solo una pagina)."""
    materiales = material_servicio.listar_materiales(
        db,
        texto=q,
        tipo=tipo,
        estado=estado,
        categoria_id=categoria_id,
        autor_id=autor_id,
        limite=MAX_FILAS_EXPORTACION,
    )
    categoria = db.get(Categoria, categoria_id) if categoria_id else None
    tabla = tabla_de_materiales(
        materiales,
        busqueda=q,
        tipo=tipo,
        estado=estado,
        categoria=categoria.nombre if categoria else None,
    )
    return respuesta_de_descarga(exportar(tabla, formato, "materiales"))


@router.get("/{material_id}", response_model=MaterialRespuesta)
def obtener_material(
    material_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Obtiene un material por ID."""
    material = material_servicio.obtener_material_por_id(db, material_id)
    if material is None or (
        usuario.rol not in ROLES_PERSONAL and material.tipo_material not in TIPOS_BIBLIOGRAFICOS
    ):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado",
        )
    return material


@router.post("/", response_model=MaterialRespuesta, status_code=status.HTTP_201_CREATED)
def crear_material(
    datos: MaterialCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Registra un nuevo material."""
    return material_servicio.crear_material(db, datos, usuario_admin=usuario)


@router.put("/{material_id}", response_model=MaterialRespuesta)
def actualizar_material(
    material_id: UUID,
    datos: MaterialActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Actualiza los campos enviados de un material."""
    return material_servicio.actualizar_material(
        db, material_id, datos, usuario_admin=usuario
    )


@router.delete("/{material_id}", status_code=status.HTTP_200_OK)
def eliminar_material(
    material_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Elimina logicamente un material."""
    material_servicio.eliminar_material(db, material_id, usuario_admin=usuario)
    return {"mensaje": "Material eliminado correctamente"}
