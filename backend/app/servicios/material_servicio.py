from datetime import datetime
from typing import List, Optional, Sequence, Tuple
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import exists, or_, select
from sqlalchemy.orm import Session, selectinload
from sqlalchemy.sql import Select

from app.core.constantes_inventario import ESTADO_DISPONIBLE, ESTADO_FUERA_DE_SERVICIO
from app.core.texto_busqueda import palabras
from app.core.paginacion import paginar
from app.core.utilidades_modelo import aplicar_cambios
from app.esquemas.material import MaterialActualizar, MaterialCrear
from app.modelos.autor import MaterialAutor
from app.modelos.material import Material
from app.modelos.usuario import Usuario
from app.servicios import bitacora_servicio
from app.servicios.autores import busqueda_material, vinculo_servicio
from app.servicios.prestamos import material_estado_servicio

# Campos que no admiten NULL en la tabla: un None enviado por el cliente se ignora.
_CAMPOS_OBLIGATORIOS = (
    "titulo",
    "tipo_material",
    "categoria_id",
    "estado",
    "condicion",
    "es_prestable",
    "cantidad_total",
    "cantidad_fuera_servicio",
)
# Campos que no se copian tal cual al material: se procesan aparte.
_CAMPOS_ESPECIALES = ("autor", "autores_ids", "autores_nuevos", "estado")


def _consulta_materiales(
    texto: Optional[str] = None,
    tipo: Optional[str] = None,
    estado: Optional[str] = None,
    categoria_id: Optional[UUID] = None,
    solo_disponibles: bool = False,
    tipos: Optional[Sequence[str]] = None,
    ocultar_fuera_de_servicio: bool = False,
    autor_id: Optional[UUID] = None,
) -> Select:
    """Arma la consulta de materiales no eliminados con los filtros indicados.

    - `texto`: cada palabra debe aparecer en el titulo, los autores, el codigo, el ISBN, la
      editorial, el tomo, la marca, el modelo o la serie, sin importar tildes ni mayusculas.
    - `autor_id`: solo materiales de ese autor.
    - `tipo`: tipo exacto (por ejemplo "proyector").
    - `estado`: estado exacto del material.
    - `categoria_id`: solo materiales de esa categoria.
    - `solo_disponibles`: solo unidades prestables y disponibles ahora.
    - `tipos`: solo materiales de alguno de estos tipos (catalogo del estudiante).
    - `ocultar_fuera_de_servicio`: excluye las unidades fuera de servicio.
    """
    # selectinload evita una consulta por fila al leer la categoria (listados y exportaciones).
    consulta = (
        select(Material)
        .options(
            selectinload(Material.categoria),
            selectinload(Material.vinculos_autores).selectinload(MaterialAutor.autor),
        )
        .where(Material.eliminado == False)  # noqa: E712
    )

    for palabra in palabras(texto):
        patron = f"%{palabra}%"
        consulta = consulta.where(
            or_(
                Material.texto_busqueda.like(patron),
                # Respaldo para filas que aun no tienen el texto de busqueda calculado.
                Material.titulo.ilike(patron),
                Material.codigo.ilike(patron),
                Material.autor.ilike(patron),
            )
        )
    if autor_id:
        consulta = consulta.where(
            exists().where(
                MaterialAutor.material_id == Material.id,
                MaterialAutor.autor_id == autor_id,
                MaterialAutor.eliminado == False,  # noqa: E712
            )
        )
    if tipo:
        consulta = consulta.where(Material.tipo_material == tipo)
    if tipos is not None:
        consulta = consulta.where(Material.tipo_material.in_(tipos))
    if ocultar_fuera_de_servicio:
        consulta = consulta.where(Material.estado != ESTADO_FUERA_DE_SERVICIO)
    if estado:
        consulta = consulta.where(Material.estado == estado)
    if categoria_id:
        consulta = consulta.where(Material.categoria_id == categoria_id)
    if solo_disponibles:
        consulta = consulta.where(
            Material.estado == ESTADO_DISPONIBLE,  # queda al menos un ejemplar libre
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
    tipos: Optional[Sequence[str]] = None,
    ocultar_fuera_de_servicio: bool = False,
    autor_id: Optional[UUID] = None,
) -> List[Material]:
    """Lista los materiales no eliminados, con filtros y tope opcionales."""
    consulta = _consulta_materiales(
        texto, tipo, estado, categoria_id, solo_disponibles, tipos, ocultar_fuera_de_servicio, autor_id
    )
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
    autor_id: Optional[UUID] = None,
) -> Tuple[List[Material], int]:
    """Una pagina de materiales y el total que cumple el filtro."""
    consulta = _consulta_materiales(texto, tipo, estado, categoria_id, autor_id=autor_id)
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


def _nombres_de_autores(datos) -> Optional[List[str]]:
    """Autores a crear por nombre. Un `autor` en texto (clientes antiguos) se separa en nombres."""
    if datos.autores_nuevos is not None or datos.autores_ids is not None:
        return datos.autores_nuevos
    if datos.autor:
        return vinculo_servicio.separar_nombres(datos.autor)
    return None


def _aplicar_cantidades(material: Material, cambios: dict) -> None:
    """Valida y aplica `cantidad_total` y los ejemplares fuera de servicio.

    No se pueden dejar menos ejemplares que los que estan reservados, prestados
    o vencidos. `estado` (clientes antiguos) se traduce a ejemplares fuera de servicio.
    """
    total = cambios.get("cantidad_total") or material.cantidad_total
    ocupados = (
        material.cantidad_reservada + material.cantidad_prestada + material.cantidad_vencida
    )
    fuera = cambios.get("cantidad_fuera_servicio")
    if fuera is None:
        estado = cambios.get("estado")
        if estado == ESTADO_FUERA_DE_SERVICIO:
            fuera = max(0, total - ocupados)
        elif estado == ESTADO_DISPONIBLE:
            fuera = 0
        else:
            fuera = material.cantidad_fuera_servicio

    if total < ocupados + fuera:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"No se puede dejar {total} ejemplares: hay {ocupados} reservados o prestados "
                f"y {fuera} fuera de servicio"
            ),
        )
    material.cantidad_total = total
    material.cantidad_fuera_servicio = fuera


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

    campos = datos.model_dump(exclude={"autores_ids", "autores_nuevos", "autor"})
    material = Material(**campos)
    db.add(material)
    db.flush()
    vinculo_servicio.asignar_autores(
        db, material, datos.autores_ids, _nombres_de_autores(datos)
    )
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
    _aplicar_cantidades(material, cambios)
    aplicar_cambios(
        material,
        {k: v for k, v in cambios.items() if k not in _CAMPOS_ESPECIALES},
        _CAMPOS_OBLIGATORIOS,
    )
    # Un cliente antiguo reenvia el resumen en texto sin cambios: no hay que tocar los autores.
    solo_texto_sin_cambios = (
        "autores_ids" not in cambios
        and "autores_nuevos" not in cambios
        and cambios.get("autor") == material.autor
    )
    if not solo_texto_sin_cambios and (
        "autores_ids" in cambios or "autores_nuevos" in cambios or "autor" in cambios
    ):
        vinculo_servicio.asignar_autores(
            db, material, datos.autores_ids, _nombres_de_autores(datos)
        )
    material.estado = material_estado_servicio.derivar_estado(material)
    busqueda_material.actualizar_texto(material)
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
