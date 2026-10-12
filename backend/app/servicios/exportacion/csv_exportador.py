"""Convierte una TablaExportable en un archivo CSV."""
import csv
from io import StringIO

from app.servicios.exportacion.tabla_exportable import TablaExportable

# Excel en espanol separa las columnas con punto y coma; con coma abre todo en una sola columna.
SEPARADOR = ";"


def a_csv(tabla: TablaExportable) -> bytes:
    """Genera el CSV: una fila de encabezados y luego los datos, sin titulo ni filtros.

    Va en UTF-8 con BOM para que Excel respete tildes y la letra n con tilde.
    """
    salida = StringIO(newline="")
    escritor = csv.writer(salida, delimiter=SEPARADOR, lineterminator="\r\n")
    escritor.writerow(tabla.columnas)
    escritor.writerows(tabla.filas)
    return salida.getvalue().encode("utf-8-sig")
