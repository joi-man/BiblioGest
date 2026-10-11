from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.core.dependencias import obtener_usuario_actual
from app.esquemas.prestamo_cabecera import PrestamoRespuesta, SolicitudCrear
from app.modelos.usuario import Usuario
from app.rutas.dependencias_prestamos import vencimientos_al_dia
from app.servicios.prestamos import consulta_prestamo_servicio, solicitud_servicio

# Rutas del usuario sobre sus propias solicitudes (las usa la app movil del estudiante).
router = APIRouter(
    prefix="/api/solicitudes",
    tags=["Solicitudes"],
    dependencies=[Depends(vencimientos_al_dia)],
)


@router.post("/", response_model=PrestamoRespuesta, status_code=status.HTTP_201_CREATED)
def crear_solicitud(
    datos: SolicitudCrear,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Solicita en prestamo o reserva uno o varios materiales."""
    return solicitud_servicio.crear_solicitud(
        db, usuario, datos.material_ids, datos.observaciones
    )


@router.get("/mias", response_model=List[PrestamoRespuesta])
def listar_mis_solicitudes(
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista las solicitudes y prestamos del usuario que hace la consulta."""
    return consulta_prestamo_servicio.listar_prestamos(db, usuario_id=usuario.id)


@router.post("/{prestamo_id}/cancelar", response_model=PrestamoRespuesta)
def cancelar_solicitud(
    prestamo_id: UUID,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Cancela una solicitud pendiente o una reserva aprobada propia."""
    return solicitud_servicio.cancelar(db, prestamo_id, usuario)
