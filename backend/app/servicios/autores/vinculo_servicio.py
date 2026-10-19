"""Autores de un material: asignarlos, quitarlos y crearlos al vuelo."""
import re
from datetime import datetime
from typing import List, Optional, Sequence
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.modelos.autor import Autor, MaterialAutor
from app.modelos.material import Material
from app.servicios.autores import autor_servicio, busqueda_material

# La coma no separa: "Apellido, Nombre" es un solo autor.
_SEPARADORES = re.compile(r"\s*[;/]\s*|\s+y\s+|\s+&\s+")


def separar_nombres(texto: str) -> List[str]:
    """Parte "Cervantes; Quevedo y Lope" en nombres (separan ";", "/", "&" y "y"). Lo usan los clientes que aun envian texto."""
    return [n.strip() for n in _SEPARADORES.split(texto) if n and n.strip()]


def _resolver(
    db: Session, autores_ids: Sequence[UUID], autores_nuevos: Sequence[str]
) -> List[Autor]:
    """Autores pedidos (por ID) y a crear (por nombre), sin repetidos y en ese orden."""
    resultado: List[Autor] = []
    for autor_id in autores_ids:
        autor = autor_servicio.obtener_autor(db, autor_id)
        if autor is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Autor no encontrado: {autor_id}",
            )
        resultado.append(autor)
    for nombre in autores_nuevos:
        if nombre.strip():
            resultado.append(autor_servicio.obtener_o_crear(db, nombre))
    unicos = {}
    for autor in resultado:
        unicos.setdefault(autor.id, autor)
    return list(unicos.values())


def asignar_autores(
    db: Session,
    material: Material,
    autores_ids: Optional[Sequence[UUID]],
    autores_nuevos: Optional[Sequence[str]],
) -> None:
    """Deja al material con exactamente esos autores. No confirma la transaccion.

    Los vinculos que sobran se dan de baja (borrado logico) y se reutiliza el
    vinculo de un autor que vuelve a agregarse.
    """
    autores = _resolver(db, autores_ids or [], autores_nuevos or [])
    ahora = datetime.utcnow()
    existentes = {v.autor_id: v for v in material.vinculos_autores}

    for orden, autor in enumerate(autores):
        vinculo = existentes.get(autor.id)
        if vinculo is None:
            vinculo = MaterialAutor(material_id=material.id, autor_id=autor.id, orden=orden)
            vinculo.autor = autor
            material.vinculos_autores.append(vinculo)
            db.add(vinculo)
        else:
            vinculo.orden = orden
            if vinculo.eliminado:
                vinculo.eliminado = False
                vinculo.fecha_eliminacion = None
    ids_nuevos = {a.id for a in autores}
    for autor_id, vinculo in existentes.items():
        if autor_id not in ids_nuevos and not vinculo.eliminado:
            vinculo.eliminado = True
            vinculo.fecha_eliminacion = ahora

    db.flush()
    if not autores:
        material.autor = None
    busqueda_material.actualizar_texto(material)
