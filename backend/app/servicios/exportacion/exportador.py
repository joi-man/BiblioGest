"""Punto unico para exportar una tabla al formato pedido."""
from dataclasses import dataclass
from typing import Callable, Dict

from fastapi import HTTPException, status

from app.core import reloj
from app.servicios.exportacion.csv_exportador import a_csv
from app.servicios.exportacion.excel_exportador import a_excel
from app.servicios.exportacion.pdf_exportador import a_pdf
from app.servicios.exportacion.tabla_exportable import TablaExportable


@dataclass(frozen=True)
class FormatoExportacion:
    extension: str
    tipo_contenido: str
    convertir: Callable[[TablaExportable], bytes]


FORMATOS: Dict[str, FormatoExportacion] = {
    "xlsx": FormatoExportacion(
        "xlsx",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        a_excel,
    ),
    "pdf": FormatoExportacion("pdf", "application/pdf", a_pdf),
    "csv": FormatoExportacion("csv", "text/csv; charset=utf-8", a_csv),
}


@dataclass(frozen=True)
class ArchivoExportado:
    contenido: bytes
    tipo_contenido: str
    nombre: str


def exportar(tabla: TablaExportable, formato: str, nombre_base: str) -> ArchivoExportado:
    """Convierte la tabla y arma el nombre del archivo (`nombre_base_AAAAMMDD.ext`)."""
    configuracion = FORMATOS.get(formato)
    if configuracion is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Formato de exportacion no soportado: {formato}",
        )

    fecha = reloj.ahora_utc().strftime("%Y%m%d")
    return ArchivoExportado(
        contenido=configuracion.convertir(tabla),
        tipo_contenido=configuracion.tipo_contenido,
        nombre=f"{nombre_base}_{fecha}.{configuracion.extension}",
    )
