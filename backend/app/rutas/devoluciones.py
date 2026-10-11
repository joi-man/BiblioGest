from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.esquemas.devolucion import DevolverItemsPeticion
from app.esquemas.prestamo_cabecera import PrestamoRespuesta
from app.modelos.usuario import Usuario
from app.rutas.dependencias_prestamos import personal_requerido, vencimientos_al_dia
from app.servicios.prestamos import consulta_prestamo_servicio, devolucion_servicio

# Recepcion de materiales devueltos. Solo el personal puede registrar devoluciones.
router = APIRouter(
    prefix="/api/devoluciones",
    tags=["Devoluciones"],
    dependencies=[Depends(vencimientos_al_dia)],
)


@router.get("/pendientes", response_model=List[PrestamoRespuesta])
def listar_pendientes_de_devolucion(
    q: Optional[str] = Query(None, description="Texto en nombre, documento, usuario o material"),
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Prestamos con material en manos de los usuarios, los mas urgentes primero."""
    return consulta_prestamo_servicio.listar_pendientes_de_devolucion(db, texto=q)


@router.post("/{prestamo_id}", response_model=PrestamoRespuesta)
def registrar_devolucion(
    prestamo_id: UUID,
    datos: DevolverItemsPeticion,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Registra la devolucion de uno o varios items del prestamo."""
    return devolucion_servicio.devolver_items(db, prestamo_id, datos.items, personal)
