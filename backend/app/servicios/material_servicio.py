from datetime import datetime
from typing import List, Optional, Tuple
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session, selectinload
from sqlalchemy.sql import Select

from app.core.constantes_inventario import ESTADO_DISPONIBLE
from app.core.paginacion import paginar
from app.core.utilidades_modelo import aplicar_cambios
from app.esquemas.material import MaterialActualizar, MaterialCrear
from app.modelos.material import Material
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio

# Campos que no admiten NULL en la tabla: un None enviado por el cliente se ignora.
_CAMPOS_OBLIGATORIOS = (
    "titulo",
    "tipo_material",
    "categoria_id",
    "estado",
    "condicion",
    "es_prestable",
)


def _consulta_materiales(
    texto: Optional[str] = None,
    tipo: Optional[str] = None,
    estado: Optional[str] = None,
    categoria_id: Optional[UUID] = None,
    solo_disponibles: bool = False,
) -> Select:
    """Arma la consulta de materiales no eliminados con los filtros indicados.

    - `texto`: busca en titulo, codigo, autor, marca, modelo y numero de serie.
    - `tipo`: tipo exacto (por ejemplo "proyector").
    - `estado`: estado exacto del material.
    - `categoria_id`: solo materiales de esa categoria.
    - `solo_disponibles`: solo unidades prestables y disponibles ahora.
    """
    # selectinload evita una consulta por fila al leer la categoria (listados y exportaciones).
    consulta = (
        select(Material)
        .options(selectinload(Material.categoria))
        .where(Material.eliminado == False)  # noqa: E712
    )

    if texto and texto.strip():
        patron = f"%{texto.strip()}%"
        consulta = consulta.where(
            or_(
                Material.titulo.ilike(patron),
                Material.codigo.ilike(patron),
                Material.autor.ilike(patron),
                Material.marca.ilike(patron),
                Material.modelo.ilike(patron),
                Material.numero_serie.ilike(patron),
            )
        )
    if tipo:
        consulta = consulta.where(Material.tipo_material == tipo)
    if estado:
        consulta = consulta.where(Material.estado == estado)
    if categoria_id:
        consulta = consulta.where(Material.categoria_id == categoria_id)
    if solo_disponibles:
        consulta = consulta.where(
            Material.estado == ESTADO_DISPONIBLE,
            Material.es_prestable == True,  # noqa: E712
        )

    return consulta.order_by(Material.fecha_creacion.desc(), Material.id)


def listar_materiales(
    db: Session,
    texto: Optional[str] = None,
    tipo: Optional[str] = None,
    estado: Optional[str] = None,
    solo_disponibles: bool = False,
    categoria_id: Optional[UUID] = None,
    limite: Optional[int] = None,
) -> List[Material]:
    """Lista los materiales no eliminados, con filtros y tope opcionales."""
    consulta = _consulta_materiales(texto, tipo, estado, categoria_id, solo_disponibles)
    if limite is not None:
        consulta = consulta.limit(limite)
    return list(db.execute(consulta).scalars().all())


def buscar_materiales(
    db: Session,
    pagina: int,
    tamano: int,
    texto: Optional[str] = None,
    tipo: Optional[str] = None,
    estado: Optional[str] = None,
    categoria_id: Optional[UUID] = None,
) -> Tuple[List[Material], int]:
    """Una pagina de materiales y el total que cumple el filtro."""
    consulta = _consulta_materiales(texto, tipo, estado, categoria_id)
    return paginar(db, consulta, pagina, tamano)


def obtener_material_por_id(db: Session, material_id: UUID) -> Optional[Material]:
    """Obtiene un material por ID (excluyendo eliminados)."""
    consulta = select(Material).where(
        Material.id == material_id,
        Material.eliminado == False,  # noqa: E712
    )
    return db.execute(consulta).scalar_one_or_none()


def obtener_material_por_codigo(db: Session, codigo: str) -> Optional[Material]:
    """Obtiene un material por codigo de inventario."""
    consulta = select(Material).where(
        Material.codigo == codigo,
        Material.eliminado == False,  # noqa: E712
    )
    return db.execute(consulta).scalar_one_or_none()


def crear_material(
    db: Session,
    datos: MaterialCrear,
    usuario_admin: Optional[Usuario] = None,
) -> Material:
    """Registra una nueva unidad de material."""
    if obtener_material_por_codigo(db, datos.codigo):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El codigo del material ya esta en uso",
        )

    material = Material(**datos.model_dump())
    db.add(material)
    db.commit()
    db.refresh(material)

    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id if usuario_admin else None,
        accion="CREATE",
        tabla_afectada="materiales",
        registro_id=material.id,
        detalles={"codigo": material.codigo, "titulo": material.titulo},
    )
    return material


def actualizar_material(
    db: Session,
    material_id: UUID,
    datos: MaterialActualizar,
    usuario_admin: Optional[Usuario] = None,
) -> Material:
    """Actualiza los campos enviados de un material existente."""
    material = obtener_material_por_id(db, material_id)
    if material is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado",
        )

    cambios = datos.model_dump(exclude_unset=True)
    aplicar_cambios(material, cambios, _CAMPOS_OBLIGATORIOS)
    material.fecha_actualizacion = datetime.utcnow()
    db.commit()
    db.refresh(material)

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
    """Elimina logicamente un material."""
    material = obtener_material_por_id(db, material_id)
    if material is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material no encontrado",
        )

    material.eliminado = True
    material.fecha_eliminacion = datetime.utcnow()
    db.commit()

    bitacora_servicio.registrar_accion(
        db=db,
        usuario_id=usuario_admin.id,
        accion="DELETE",
        tabla_afectada="materiales",
        registro_id=material.id,
        detalles={"codigo": material.codigo, "titulo": material.titulo},
    )
    return True
