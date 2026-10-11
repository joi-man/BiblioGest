"""Rutas del servidor central para sincronizar equipos con el ejecutable."""
from datetime import datetime
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import obtener_db
from app.core.dependencias import require_role
from app.esquemas.sync import (
    EnvioLotes,
    PeticionFilas,
    RespuestaCambios,
    RespuestaEnvio,
)
from app.modelos.usuario import Usuario
from app.sync import emision, recepcion
from app.sync.tablas import PERSONAL, TABLAS_POR_NOMBRE

router = APIRouter(prefix="/api/sync", tags=["Sincronizacion"])


def _tabla_descargable(nombre: str):
    tabla = TABLAS_POR_NOMBRE.get(nombre)
    if tabla is None or not tabla.se_descarga:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tabla no sincronizable")
    return tabla


@router.post("/lotes", response_model=RespuestaEnvio)
def recibir_lotes(
    envio: EnvioLotes,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Aplica los lotes enviados por un equipo y devuelve el resultado de cada uno."""
    resultados = recepcion.recibir_lotes(db, [lote.model_dump() for lote in envio.lotes], usuario)
    return RespuestaEnvio(resultados=[r.__dict__ for r in resultados])


@router.get("/cambios", response_model=RespuestaCambios)
def obtener_cambios(
    tabla: str = Query(..., description="Nombre de la tabla"),
    desde: Optional[datetime] = Query(None, description="Solo filas modificadas desde este instante"),
    despues_de_id: Optional[UUID] = Query(None, description="Continua despues de esta fila"),
    limite: int = Query(500, ge=1, le=2000),
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Una pagina de filas modificadas, en orden, para descargar al equipo."""
    return emision.obtener_cambios(db, _tabla_descargable(tabla), desde, despues_de_id, limite)


@router.post("/filas")
def obtener_filas(
    peticion: PeticionFilas,
    db: Session = Depends(obtener_db),
    usuario: Usuario = Depends(require_role(list(PERSONAL))),
):
    """Filas concretas por id."""
    ids = [UUID(i) for i in peticion.ids]
    return {"filas": emision.obtener_filas(db, _tabla_descargable(peticion.tabla), ids)}
