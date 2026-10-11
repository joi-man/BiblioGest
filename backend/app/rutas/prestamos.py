from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.esquemas.prestamo_cabecera import (
    EntregaPeticion,
    PrestamoDirectoCrear,
    PrestamoRespuesta,
    RechazoPeticion,
)
from app.modelos.usuario import Usuario
from app.rutas.dependencias_prestamos import personal_requerido, vencimientos_al_dia
from app.servicios.prestamos import (
    aprobacion_servicio,
    consulta_prestamo_servicio,
    entrega_servicio,
    solicitud_servicio,
)

# Gestion de solicitudes y prestamos por parte del personal de la biblioteca.
router = APIRouter(
    prefix="/api/prestamos",
    tags=["Prestamos"],
    dependencies=[Depends(vencimientos_al_dia)],
)


@router.get("/", response_model=List[PrestamoRespuesta])
def listar_prestamos(
    estado: Optional[List[str]] = Query(None, description="Uno o mas estados a incluir"),
    usuario_id: Optional[UUID] = Query(None, description="Solo prestamos de este usuario"),
    q: Optional[str] = Query(None, description="Texto en nombre, documento, usuario o material"),
    mas_antiguos_primero: bool = Query(False, description="Util para la cola de solicitudes"),
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Lista solicitudes y prestamos con filtros opcionales."""
    return consulta_prestamo_servicio.listar_prestamos(
        db,
        estados=estado,
        usuario_id=usuario_id,
        texto=q,
        mas_antiguos_primero=mas_antiguos_primero,
    )


@router.post("/directo", response_model=PrestamoRespuesta, status_code=status.HTTP_201_CREATED)
def crear_prestamo_directo(
    datos: PrestamoDirectoCrear,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Registra un prestamo en el mostrador, sin solicitud previa."""
    return entrega_servicio.crear_prestamo_directo(db, personal, datos)


@router.get("/{prestamo_id}", response_model=PrestamoRespuesta)
def obtener_prestamo(
    prestamo_id: UUID,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Obtiene el detalle de un prestamo."""
    return consulta_prestamo_servicio.obtener_prestamo(db, prestamo_id)


@router.post("/{prestamo_id}/aprobar", response_model=PrestamoRespuesta)
def aprobar_solicitud(
    prestamo_id: UUID,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Aprueba una solicitud pendiente y reserva las unidades."""
    return aprobacion_servicio.aprobar(db, prestamo_id, personal)


@router.post("/{prestamo_id}/rechazar", response_model=PrestamoRespuesta)
def rechazar_solicitud(
    prestamo_id: UUID,
    datos: RechazoPeticion,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Rechaza una solicitud pendiente indicando el motivo."""
    return aprobacion_servicio.rechazar(db, prestamo_id, personal, datos.motivo)


@router.post("/{prestamo_id}/entregar", response_model=PrestamoRespuesta)
def entregar_prestamo(
    prestamo_id: UUID,
    datos: Optional[EntregaPeticion] = None,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Entrega los materiales. Sobre una solicitud pendiente aprueba y entrega en un paso."""
    fecha = datos.fecha_devolucion_esperada if datos else None
    return entrega_servicio.entregar(db, prestamo_id, personal, fecha)


@router.post("/{prestamo_id}/cancelar", response_model=PrestamoRespuesta)
def cancelar_prestamo(
    prestamo_id: UUID,
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Cancela una solicitud pendiente o una reserva aprobada."""
    return solicitud_servicio.cancelar(db, prestamo_id, personal)
