"""Reportes de prestamos, prestamos vencidos y devoluciones (solo personal)."""
from dataclasses import dataclass
from datetime import date
from typing import Callable, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy.sql import Select

from app.core.constantes_prestamo import CONDICIONES_DEVOLUCION, ESTADOS_PRESTAMO
from app.core.database import obtener_db
from app.core.paginacion import total_de_paginas
from app.esquemas.reporte import ReportePagina
from app.modelos.usuario import Usuario
from app.rutas.dependencias_listados import (
    ParametrosPagina,
    parametros_pagina,
    respuesta_de_descarga,
)
from app.rutas.dependencias_prestamos import personal_requerido, vencimientos_al_dia
from app.servicios.exportacion.exportador import FORMATOS, exportar
from app.servicios.exportacion.tabla_exportable import MAX_FILAS_EXPORTACION, TablaExportable
from app.servicios.reportes import consultas, tablas
from app.servicios.reportes.consultas import FiltrosReporte

# Los reportes leen prestamos: se ponen al dia los vencimientos antes de armarlos.
router = APIRouter(
    prefix="/api/reportes",
    tags=["Reportes"],
    dependencies=[Depends(vencimientos_al_dia)],
)


@dataclass(frozen=True)
class Reporte:
    """Como se consulta un reporte, como se convierte en tabla y como se llama su archivo."""

    consulta: Callable[[FiltrosReporte], Select]
    tabla: Callable[[list, FiltrosReporte, int], TablaExportable]
    nombre_archivo: str


REPORTES = {
    "prestamos": Reporte(consultas.consulta_prestamos, tablas.tabla_de_prestamos, "prestamos"),
    # RFC-G1: prestamos vencidos filtrados por rango de fechas, exportables a CSV.
    "vencidos": Reporte(consultas.consulta_vencidos, tablas.tabla_de_vencidos, "prestamos_vencidos"),
    "devoluciones": Reporte(consultas.consulta_devoluciones, tablas.tabla_de_devoluciones, "devoluciones"),
}


def _reporte(tipo: str) -> Reporte:
    reporte = REPORTES.get(tipo)
    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No existe el reporte '{tipo}'. Disponibles: {', '.join(REPORTES)}",
        )
    return reporte


def filtros_reporte(
    desde: Optional[date] = Query(None, description="Desde este dia (AAAA-MM-DD), incluido"),
    hasta: Optional[date] = Query(None, description="Hasta este dia (AAAA-MM-DD), incluido"),
    estado: Optional[List[str]] = Query(None, description="Estados del prestamo (solo reporte de prestamos)"),
    condicion: Optional[str] = Query(None, description="Condicion al devolver (solo reporte de devoluciones)"),
    q: Optional[str] = Query(None, description="Texto en persona, documento o material"),
) -> FiltrosReporte:
    if desde and hasta and desde > hasta:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha 'desde' no puede ser posterior a 'hasta'",
        )
    invalidos = [e for e in (estado or []) if e not in ESTADOS_PRESTAMO]
    if invalidos:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Estado no valido: {invalidos[0]}"
        )
    if condicion and condicion not in CONDICIONES_DEVOLUCION:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Condicion no valida: {condicion}"
        )
    return FiltrosReporte(
        desde=desde, hasta=hasta, estados=tuple(estado or ()), condicion=condicion, texto=q
    )


@router.get("/{tipo}", response_model=ReportePagina)
def ver_reporte(
    tipo: str,
    filtros: FiltrosReporte = Depends(filtros_reporte),
    paginacion: ParametrosPagina = Depends(parametros_pagina),
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Una pagina del reporte con los filtros indicados."""
    reporte = _reporte(tipo)
    filas, total = consultas.una_pagina(db, reporte.consulta(filtros), paginacion.pagina, paginacion.tamano)
    tabla = reporte.tabla(filas, filtros, total)
    return ReportePagina(
        titulo=tabla.titulo,
        descripcion=tabla.descripcion,
        columnas=tabla.columnas,
        filas=tabla.filas,
        total=total,
        pagina=paginacion.pagina,
        tamano=paginacion.tamano,
        total_paginas=total_de_paginas(total, paginacion.tamano),
    )


@router.get("/{tipo}/exportar")
def exportar_reporte(
    tipo: str,
    formato: str = Query("csv", description="csv, xlsx o pdf"),
    filtros: FiltrosReporte = Depends(filtros_reporte),
    db: Session = Depends(obtener_db),
    personal: Usuario = Depends(personal_requerido),
):
    """Descarga todo el reporte que cumple el filtro (hasta el tope de filas), no solo una pagina."""
    reporte = _reporte(tipo)
    filas = consultas.todas(db, reporte.consulta(filtros), MAX_FILAS_EXPORTACION)
    tabla = reporte.tabla(filas, filtros, len(filas))
    return respuesta_de_descarga(exportar(tabla, formato, reporte.nombre_archivo))
