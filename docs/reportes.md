# Reportes

Tres reportes para el personal de la biblioteca, con filtros por fechas y exportación a **CSV, Excel y PDF**. Están en el menú **Reportes** de la web y del ejecutable de Windows. **No existen en la app de Android**: el móvil es un complemento sin reportes (ver [app-movil.md](app-movil.md)).

| Reporte | Qué muestra | Filtros |
|---|---|---|
| **Préstamos** | Todas las solicitudes y préstamos: persona, materiales, estado y fechas (solicitud, entrega, límite, devolución) | Rango de fecha de solicitud, estado, texto |
| **Vencidos** (RFC-G1) | Préstamos vencidos con los materiales pendientes, los datos de contacto de la persona y los **días de atraso** | Rango de **fecha límite de devolución**, texto |
| **Devoluciones** | Cada devolución registrada: fecha, persona, material, condición, días de retraso, (multa, si está activada) y quién la recibió | Rango de fecha de devolución, condición, texto |

El texto busca en el nombre, apellido, usuario o documento de la persona y en el título o código del material.

## RFC-G1: vencidos por rango de fechas con exportación a CSV

La solicitud de cambio pedía filtrar los préstamos vencidos por rango de fechas y exportar el resultado a CSV. Está resuelta con el reporte **Vencidos**:

- El rango se aplica a la **fecha límite** de devolución. Un préstamo con varios items usa la más próxima entre los que aún no se devolvieron.
- `desde` incluye el día completo desde las 00:00 y `hasta` incluye todo ese día.
- Solo aparecen los préstamos en estado `vencido`; el estado se pone al día antes de cada consulta (ver "Vencimientos perezosos" en [prestamos-devoluciones.md](prestamos-devoluciones.md)).
- **Días de atraso:** cualquier fracción pasada del plazo cuenta como un día, igual que el cálculo de multas.
- La exportación trae **todas** las filas que cumplen el filtro (hasta 5 000), no solo la página que se ve.

## Formatos de exportación

| Formato | Detalle |
|---|---|
| **CSV** | Una fila de encabezados y luego los datos, sin título. UTF-8 con BOM (Excel respeta las tildes) y **punto y coma** como separador, que es lo que Excel en español espera; con coma abriría todo en una sola columna |
| **Excel (.xlsx)** | Título, filtros aplicados, encabezado destacado y columnas autoajustadas |
| **PDF** | Horizontal, con título, filtros, encabezado repetido en cada página y numeración |

Los archivos se llaman `reporte_<tipo>_AAAAMMDD.<extensión>` (por ejemplo `reporte_vencidos_20261012.csv`). Todas las **horas van en UTC** (hora del servidor); la descripción de cada archivo lo recuerda.

## API

Solo `admin` y `bibliotecario`. Un estudiante recibe 403.

| Método y ruta | Qué hace |
|---|---|
| `GET /api/reportes/{tipo}` | Una página del reporte: `titulo`, `descripcion`, `columnas`, `filas` (texto), `total`, `pagina`, `tamano`, `total_paginas`. `tipo` es `prestamos`, `vencidos` o `devoluciones` |
| `GET /api/reportes/{tipo}/exportar?formato=csv\|xlsx\|pdf` | Descarga todo el reporte que cumple el filtro |

Parámetros de filtro (todos opcionales): `desde` y `hasta` (`AAAA-MM-DD`), `estado` (repetible; solo `prestamos`), `condicion` (`bueno`, `dano_menor`, `dano_mayor`, `perdido`; solo `devoluciones`), `q`, y `pagina` / `tamano` para la consulta. Respuestas de error: `400` si `desde` es posterior a `hasta` o el formato no existe, `404` si el reporte no existe, `422` si un estado o condición no es válido.

## Cómo está hecho

| Pieza | Dónde |
|---|---|
| Consultas (filtros, orden) | `backend/app/servicios/reportes/consultas.py` |
| Filas en texto y descripción de filtros | `backend/app/servicios/reportes/tablas.py` |
| Rutas | `backend/app/rutas/reportes.py` |
| Exportadores | `backend/app/servicios/exportacion/` (`csv_exportador.py`, `excel_exportador.py`, `pdf_exportador.py`) |
| Pantalla | `frontend/lib/features/reports/` |

El backend devuelve cada reporte como una **tabla de texto** (columnas y filas), así que la pantalla es genérica: una misma grilla dibuja cualquier reporte y agregar uno nuevo no exige tocar el frontend.

## Limitaciones

- Solo web y escritorio; el móvil no tiene reportes.
- Tope de 5 000 filas por archivo exportado.
- Las horas se muestran en UTC; no hay selector de zona horaria.
- No hay todavía un reporte de **historial de préstamos por material** ni reportes del inventario por categoría o autor; sí se exportan Materiales y Usuarios desde sus pantallas.
- En el ejecutable de Windows los reportes leen la base **local**: incluyen lo sincronizado hasta el último momento en que hubo conexión.

## Pruebas

`backend/tests/test_reportes.py` (filtros por estado, fechas, texto y paginación; vencidos con días de atraso y rango; CSV con BOM, separador y encabezados; Excel y PDF; devoluciones por condición; permisos y parámetros inválidos) y `frontend/test/reportes_test.dart` (pestañas, tabla, parámetros enviados y menú de exportación).
