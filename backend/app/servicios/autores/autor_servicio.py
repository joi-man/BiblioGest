"""Alta, edicion, baja y busqueda de autores."""
from datetime import datetime
from typing import List, Optional, Tuple
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session
from sqlalchemy.sql import Select

from app.core.paginacion import paginar
from app.core.texto_busqueda import normalizar, palabras
from app.esquemas.autor import AutorActualizar, AutorCrear
from app.modelos.autor import Autor, MaterialAutor
from app.modelos.material import Material
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio
from app.servicios.autores import busqueda_material


def _consulta(texto: Optional[str] = None) -> Select:
    consulta = select(Autor).where(Autor.eliminado == False)  # noqa: E712
    for palabra in palabras(texto):
        consulta = consulta.where(Autor.nombre_normalizado.like(f"%{palabra}%"))
    return consulta.order_by(Autor.nombre_normalizado, Autor.id)


def listar_autores(db: Session, texto: Optional[str] = None, limite: Optional[int] = None) -> List[Autor]:
    consulta = _consulta(texto)
    if limite is not None:
        consulta = consulta.limit(limite)
    return list(db.execute(consulta).scalars().all())


def buscar_autores(db: Session, pagina: int, tamano: int, texto: Optional[str] = None) -> Tuple[List[Autor], int]:
    return paginar(db, _consulta(texto), pagina, tamano)


def obtener_autor(db: Session, autor_id: UUID) -> Optional[Autor]:
    return db.execute(
        select(Autor).where(Autor.id == autor_id, Autor.eliminado == False)  # noqa: E712
    ).scalar_one_or_none()


def obtener_por_nombre(db: Session, nombre: str) -> Optional[Autor]:
    """El autor vigente cuyo nombre equivale a `nombre` (sin importar tildes ni mayusculas)."""
    return db.execute(
        select(Autor).where(
            Autor.nombre_normalizado == normalizar(nombre),
            Autor.eliminado == False,  # noqa: E712
        )
    ).scalars().first()


def contar_materiales(db: Session, autor_ids: List[UUID]) -> dict:
    """Cuantos materiales vigentes tiene cada autor."""
    if not autor_ids:
        return {}
    consulta = (
        select(MaterialAutor.autor_id, func.count(MaterialAutor.id))
        .join(Material, Material.id == MaterialAutor.material_id)
        .where(
            MaterialAutor.autor_id.in_(autor_ids),
            MaterialAutor.eliminado == False,  # noqa: E712
            Material.eliminado == False,  # noqa: E712
        )
        .group_by(MaterialAutor.autor_id)
    )
    return {autor_id: total for autor_id, total in db.execute(consulta).all()}


def obtener_o_crear(db: Session, nombre: str) -> Autor:
    """Devuelve el autor con ese nombre o lo crea. No confirma la transaccion."""
    nombre = " ".join(nombre.split())
    existente = obtener_por_nombre(db, nombre)
    if existente is not None:
        return existente
    autor = Autor(nombre=nombre, nombre_normalizado=normalizar(nombre))
    db.add(autor)
    db.flush()
    return autor


def _exigir_nombre_libre(db: Session, nombre: str, autor_id: Optional[UUID] = None) -> None:
    existente = obtener_por_nombre(db, nombre)
    if existente is not None and existente.id != autor_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un autor con ese nombre",
        )


def crear_autor(db: Session, datos: AutorCrear, usuario: Optional[Usuario] = None) -> Autor:
    nombre = " ".join(datos.nombre.split())
    _exigir_nombre_libre(db, nombre)
    autor = Autor(nombre=nombre, nombre_normalizado=normalizar(nombre))
    db.add(autor)
    db.commit()
    db.refresh(autor)
    bitacora_servicio.registrar_accion(
        db=db, usuario_id=usuario.id if usuario else None, accion="CREATE",
        tabla_afectada="autores", registro_id=autor.id, detalles={"nombre": autor.nombre},
    )
    return autor


def actualizar_autor(
    db: Session, autor_id: UUID, datos: AutorActualizar, usuario: Optional[Usuario] = None
) -> Autor:
    """Cambia el nombre y actualiza el resumen y la busqueda de sus materiales."""
    autor = obtener_autor(db, autor_id)
    if autor is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Autor no encontrado")

    nombre = " ".join(datos.nombre.split())
    _exigir_nombre_libre(db, nombre, autor.id)
    autor.nombre = nombre
    autor.nombre_normalizado = normalizar(nombre)
    autor.fecha_actualizacion = datetime.utcnow()
    db.flush()
    for vinculo in autor.vinculos:
        if not vinculo.eliminado and not vinculo.material.eliminado:
            busqueda_material.actualizar_texto(vinculo.material)
    db.commit()
    db.refresh(autor)
    bitacora_servicio.registrar_accion(
        db=db, usuario_id=usuario.id if usuario else None, accion="UPDATE",
        tabla_afectada="autores", registro_id=autor.id, detalles={"nombre": autor.nombre},
    )
    return autor


def eliminar_autor(db: Session, autor_id: UUID, usuario: Usuario) -> None:
    """Baja logica. No se permite si todavia tiene materiales."""
    autor = obtener_autor(db, autor_id)
    if autor is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Autor no encontrado")
    if contar_materiales(db, [autor.id]).get(autor.id, 0):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se puede eliminar un autor que tiene materiales asociados",
        )
    autor.eliminado = True
    autor.fecha_eliminacion = datetime.utcnow()
    db.commit()
    bitacora_servicio.registrar_accion(
        db=db, usuario_id=usuario.id, accion="DELETE",
        tabla_afectada="autores", registro_id=autor.id, detalles={"nombre": autor.nombre},
    )
