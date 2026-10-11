from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.esquemas.dashboard import ResumenDashboard
from app.modelos.usuario import Usuario
from app.rutas.dependencias_prestamos import personal_requerido, vencimientos_al_dia
from app.servicios import dashboard_servicio

router = APIRouter(
    prefix="/api/dashboard",
    tags=["Dashboard"],
    dependencies=[Depends(vencimientos_al_dia)],
)


@router.get("/resumen", response_model=ResumenDashboard)
def obtener_resumen(
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Metricas del panel de inicio: materiales por estado y operacion de prestamos."""
    return dashboard_servicio.obtener_resumen(db)
