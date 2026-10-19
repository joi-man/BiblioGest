from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.autor import AutorActualizar, AutorCrear, AutorRespuesta
from app.esquemas.paginacion import Pagina
from app.modelos.autor import Autor
from app.modelos.usuario import Usuario
from app.rutas.dependencias_listados import ParametrosPagina, armar_pagina, parametros_pagina
from app.servicios.autores import autor_servicio

router = APIRouter(prefix="/api/autores", tags=["Autores"])

PERSONAL = ["admin", "bibliotecario"]


def _con_cantidades(db: Session, autores: List[Autor]) -> List[AutorRespuesta]:
    """Respuestas de autores con el numero de materiales de cada uno (una sola consulta)."""
    cantidades = autor_servicio.contar_materiales(db, [a.id for a in autores])
    return [
        AutorRespuesta(
            id=a.id,
            nombre=a.nombre,
            fecha_creacion=a.fecha_creacion,
            cantidad_materiales=cantidades.get(a.id, 0),
        )
        for a in autores
    ]


@router.get("/", response_model=List[AutorRespuesta])
def listar_autores(
    q: Optional[str] = Query(None, description="Parte del nombre, sin importar tildes"),
    limite: int = Query(50, ge=1, le=200),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    """Autores que coinciden con la busqueda (para elegirlos al cargar un material)."""
    return _con_cantidades(db, autor_servicio.listar_autores(db, q, limite))


@router.get("/buscar", response_model=Pagina[AutorRespuesta])
def buscar_autores(
    q: Optional[str] = Query(None, description="Parte del nombre, sin importar tildes"),
    paginacion: ParametrosPagina = Depends(parametros_pagina),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    """Una pagina de autores con el numero de materiales de cada uno."""
    autores, total = autor_servicio.buscar_autores(db, paginacion.pagina, paginacion.tamano, q)
    return armar_pagina(_con_cantidades(db, autores), total, paginacion)


@router.get("/{autor_id}", response_model=AutorRespuesta)
def obtener_autor(
    autor_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    autor = autor_servicio.obtener_autor(db, autor_id)
    if autor is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Autor no encontrado")
    return _con_cantidades(db, [autor])[0]


@router.post("/", response_model=AutorRespuesta, status_code=status.HTTP_201_CREATED)
def crear_autor(
    datos: AutorCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    return _con_cantidades(db, [autor_servicio.crear_autor(db, datos, usuario)])[0]


@router.put("/{autor_id}", response_model=AutorRespuesta)
def actualizar_autor(
    autor_id: UUID,
    datos: AutorActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    return _con_cantidades(db, [autor_servicio.actualizar_autor(db, autor_id, datos, usuario)])[0]


@router.delete("/{autor_id}", status_code=status.HTTP_200_OK)
def eliminar_autor(
    autor_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(PERSONAL)),
):
    """Baja logica; se rechaza si el autor aun tiene materiales."""
    autor_servicio.eliminar_autor(db, autor_id, usuario)
    return {"mensaje": "Autor eliminado correctamente"}
