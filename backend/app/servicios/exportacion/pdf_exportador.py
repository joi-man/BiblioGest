"""Convierte una TablaExportable en un documento PDF horizontal."""
from io import BytesIO
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from app.servicios.exportacion.tabla_exportable import TablaExportable

_COLOR_ENCABEZADO = colors.HexColor("#3B2F2A")
_COLOR_FILA_ALTERNA = colors.HexColor("#F5EFE6")
_COLOR_LINEA = colors.HexColor("#D9CFC1")


def a_pdf(tabla: TablaExportable) -> bytes:
    """Genera el PDF. El encabezado de la tabla se repite en cada pagina."""
    salida = BytesIO()
    documento = SimpleDocTemplate(
        salida,
        pagesize=landscape(A4),
        leftMargin=1.2 * cm,
        rightMargin=1.2 * cm,
        topMargin=1.2 * cm,
        bottomMargin=1.2 * cm,
        title=tabla.titulo,
    )
    estilos = getSampleStyleSheet()
    estilo_celda = ParagraphStyle("celda", parent=estilos["BodyText"], fontSize=8, leading=10)
    estilo_encabezado = ParagraphStyle(
        "encabezado", parent=estilo_celda, textColor=colors.white, fontName="Helvetica-Bold"
    )

    elementos = [Paragraph(escape(tabla.titulo), estilos["Title"])]
    if tabla.descripcion:
        elementos.append(Paragraph(escape(tabla.descripcion), estilos["Normal"]))
    elementos.append(Spacer(1, 0.4 * cm))

    # Cada celda es un Paragraph para que el texto largo se ajuste a la columna.
    datos = [[Paragraph(escape(c), estilo_encabezado) for c in tabla.columnas]]
    for fila in tabla.filas:
        datos.append([Paragraph(escape(str(valor)), estilo_celda) for valor in fila])

    grilla = Table(datos, repeatRows=1)
    grilla.setStyle(_estilo_tabla(len(datos)))
    elementos.append(grilla)

    documento.build(elementos, onFirstPage=_numerar_pagina, onLaterPages=_numerar_pagina)
    return salida.getvalue()


def _estilo_tabla(cantidad_filas: int) -> TableStyle:
    """Encabezado oscuro, filas alternas y lineas suaves."""
    comandos = [
        ("BACKGROUND", (0, 0), (-1, 0), _COLOR_ENCABEZADO),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.25, _COLOR_LINEA),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
    for fila in range(2, cantidad_filas, 2):
        comandos.append(("BACKGROUND", (0, fila), (-1, fila), _COLOR_FILA_ALTERNA))
    return TableStyle(comandos)


def _numerar_pagina(lienzo, documento) -> None:
    """Pie de pagina con el numero de pagina."""
    lienzo.saveState()
    lienzo.setFont("Helvetica", 8)
    lienzo.drawRightString(documento.pagesize[0] - 1.2 * cm, 0.7 * cm, f"Pagina {documento.page}")
    lienzo.restoreState()
