from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual, require_role
from app.esquemas.material import MaterialCrear, MaterialActualizar, MaterialRespuesta
from app.modelos.usuario import Usuario
from app.servicios import material_servicio

router = APIRouter(prefix="/api/materiales", tags=["Materiales"])


@router.get("/", response_model=List[MaterialRespuesta])
def listar_materiales(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Listar todos los materiales."""
    materiales = material_servicio.listar_materiales(db)
    return [MaterialRespuesta(
        id=str(m.id),
        codigo=m.codigo,
        titulo=m.titulo,
        tipo_material=m.tipo_material,
        estado=m.estado,
        categoria_id=str(m.categoria_id),
        autor=m.autor,
        descripcion=m.descripcion,
        isbn=m.isbn,
        editorial=m.editorial,
        anio_publicacion=m.anio_publicacion,
        numero_paginas=m.numero_paginas,
        formato=m.formato,
        duracion=m.duracion,
        imagen_url=m.imagen_url,
        fecha_creacion=m.fecha_creacion,
        fecha_actualizacion=m.fecha_actualizacion,
    ) for m in materiales]


@router.get("/{material_id}", response_model=MaterialRespuesta)
def obtener_material(
    material_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Obtener un material por ID."""
    material = material_servicio.obtener_material_por_id(db, material_id)
    if material is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado"
        )
    return MaterialRespuesta(
        id=str(material.id),
        codigo=material.codigo,
        titulo=material.titulo,
        tipo_material=material.tipo_material,
        estado=material.estado,
        categoria_id=str(material.categoria_id),
        autor=material.autor,
        descripcion=material.descripcion,
        isbn=material.isbn,
        editorial=material.editorial,
        anio_publicacion=material.anio_publicacion,
        numero_paginas=material.numero_paginas,
        formato=material.formato,
        duracion=material.duracion,
        imagen_url=material.imagen_url,
        fecha_creacion=material.fecha_creacion,
        fecha_actualizacion=material.fecha_actualizacion,
    )


@router.post("/", response_model=MaterialRespuesta, status_code=status.HTTP_201_CREATED)
def crear_material(
    datos: MaterialCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Crear un nuevo material."""
    material_creado = material_servicio.crear_material(
        db=db,
        codigo=datos.codigo,
        titulo=datos.titulo,
        tipo_material=datos.tipo_material,
        categoria_id=datos.categoria_id,
        autor=datos.autor,
        descripcion=datos.descripcion,
        isbn=datos.isbn,
        editorial=datos.editorial,
        anio_publicacion=datos.anio_publicacion,
        numero_paginas=datos.numero_paginas,
        formato=datos.formato,
        duracion=datos.duracion,
        imagen_url=datos.imagen_url,
        usuario_admin=usuario,
    )
    return MaterialRespuesta(
        id=str(material_creado.id),
        codigo=material_creado.codigo,
        titulo=material_creado.titulo,
        tipo_material=material_creado.tipo_material,
        estado=material_creado.estado,
        categoria_id=str(material_creado.categoria_id),
        autor=material_creado.autor,
        descripcion=material_creado.descripcion,
        isbn=material_creado.isbn,
        editorial=material_creado.editorial,
        anio_publicacion=material_creado.anio_publicacion,
        numero_paginas=material_creado.numero_paginas,
        formato=material_creado.formato,
        duracion=material_creado.duracion,
        imagen_url=material_creado.imagen_url,
        fecha_creacion=material_creado.fecha_creacion,
        fecha_actualizacion=material_creado.fecha_actualizacion,
    )


@router.put("/{material_id}", response_model=MaterialRespuesta)
def actualizar_material(
    material_id: UUID,
    datos: MaterialActualizar,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Actualizar un material."""
    material_actualizado = material_servicio.actualizar_material(
        db=db,
        material_id=material_id,
        titulo=datos.titulo,
        tipo_material=datos.tipo_material,
        estado=datos.estado,
        categoria_id=datos.categoria_id,
        autor=datos.autor,
        descripcion=datos.descripcion,
        isbn=datos.isbn,
        editorial=datos.editorial,
        anio_publicacion=datos.anio_publicacion,
        numero_paginas=datos.numero_paginas,
        formato=datos.formato,
        duracion=datos.duracion,
        imagen_url=datos.imagen_url,
        usuario_admin=usuario,
    )
    return MaterialRespuesta(
        id=str(material_actualizado.id),
        codigo=material_actualizado.codigo,
        titulo=material_actualizado.titulo,
        tipo_material=material_actualizado.tipo_material,
        estado=material_actualizado.estado,
        categoria_id=str(material_actualizado.categoria_id),
        autor=material_actualizado.autor,
        descripcion=material_actualizado.descripcion,
        isbn=material_actualizado.isbn,
        editorial=material_actualizado.editorial,
        anio_publicacion=material_actualizado.anio_publicacion,
        numero_paginas=material_actualizado.numero_paginas,
        formato=material_actualizado.formato,
        duracion=material_actualizado.duracion,
        imagen_url=material_actualizado.imagen_url,
        fecha_creacion=material_actualizado.fecha_creacion,
        fecha_actualizacion=material_actualizado.fecha_actualizacion,
    )


@router.delete("/{material_id}", status_code=status.HTTP_200_OK)
def eliminar_material(
    material_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(["admin", "bibliotecario"])),
):
    """Eliminar logicamente un material."""
    material_servicio.eliminar_material(
        db=db,
        material_id=material_id,
        usuario_admin=usuario,
    )
    return {"mensaje": "Material eliminado correctamente"}

