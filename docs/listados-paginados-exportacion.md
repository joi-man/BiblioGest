# Listados paginados y exportación

Las pantallas **Usuarios** y **Materiales** muestran una grilla paginada con búsqueda, filtros y exportación a Excel y PDF. Esta guía explica cómo funcionan y cómo agregar otro listado igual.

## Qué ve la persona

- **Grilla** con una fila por registro, menú de acciones por fila (editar, eliminar).
- **Búsqueda** por texto (espera 350 ms después de escribir).
- **Filtros**
  - Usuarios: rol y estado (activo/inactivo).
  - Materiales: tipo, categoría y estado.
- **Pie de la grilla**: filas por página (10, 25, 50, 100), rango visible (`11–20 de 53`) y botones primera/anterior/siguiente/última.
- **Exportar**: Excel (`.xlsx`) o PDF. Exporta **todo lo que cumple el filtro**, no solo la página visible. El PDF sale en horizontal con el encabezado repetido en cada hoja.
  - Navegador: lo descarga el navegador.
  - Escritorio: lo guarda en la carpeta Descargas (si el nombre existe agrega ` (2)`).
- Al cambiar un filtro o las filas por página se vuelve a la página 1. Si se borra el último elemento de la última página, la grilla retrocede sola.

## API

Solo `admin` y `bibliotecario`. Las rutas fijas (`/buscar`, `/exportar`) van antes de `/{id}`.

| Ruta | Parámetros | Respuesta |
|---|---|---|
| `GET /api/usuarios/buscar` | `q`, `rol`, `activo`, `pagina` (desde 1), `tamano` (1–100) | `{items, total, pagina, tamano, total_paginas}` |
| `GET /api/usuarios/exportar` | `formato` (`xlsx`\|`pdf`), `q`, `rol`, `activo` | Archivo adjunto |
| `GET /api/materiales/buscar` | `q`, `tipo`, `estado`, `categoria_id`, `pagina`, `tamano` | Igual que arriba |
| `GET /api/materiales/exportar` | `formato`, `q`, `tipo`, `estado`, `categoria_id` | Archivo adjunto |

`GET /api/usuarios/` y `GET /api/materiales/` siguen devolviendo la lista completa sin paginar: los usan el catálogo del estudiante y el selector de usuario del préstamo directo.

Límites: 100 filas por página y 5000 filas por archivo exportado (`MAX_FILAS_EXPORTACION`).

## Cómo está organizado

Una responsabilidad por archivo.

### Backend

| Archivo | Responsabilidad |
|---|---|
| `core/paginacion.py` | `paginar(db, consulta, pagina, tamano)`: filas de una página y total |
| `esquemas/paginacion.py` | `Pagina[T]`: forma de la respuesta |
| `rutas/dependencias_listados.py` | Parámetros `pagina`/`tamano`, armado de la `Pagina` y respuesta de descarga |
| `servicios/usuario_servicio.py`, `material_servicio.py` | Consulta con filtros (`_consulta_*`), lista y búsqueda paginada |
| `servicios/exportacion/tabla_exportable.py` | `TablaExportable`: título, columnas y filas, sin saber del formato |
| `servicios/exportacion/usuarios_exportacion.py`, `materiales_exportacion.py` | Qué columnas y textos lleva cada listado |
| `servicios/exportacion/excel_exportador.py`, `pdf_exportador.py` | Convierten una `TablaExportable` a `.xlsx` / PDF |
| `servicios/exportacion/exportador.py` | Elige el formato y arma el nombre `usuarios_AAAAMMDD.xlsx` |

La búsqueda y la exportación **comparten la misma consulta**, así el archivo siempre coincide con lo que se ve en pantalla.

Seguridad: en Excel todo texto se guarda como texto, así que un nombre como `=1+1` no se ejecuta como fórmula al abrir el archivo.

### Frontend

| Archivo | Responsabilidad |
|---|---|
| `core/modelos/pagina_resultado.dart` | `PaginaResultado<T>`: filas y datos de navegación |
| `core/archivos/guardar_archivo*.dart` | Guardar/descargar un archivo (versión web y versión escritorio) |
| `features/core/widgets/grilla_datos.dart` | Dibuja una grilla a partir de columnas y filas |
| `features/core/widgets/controles_paginacion.dart` | Pie con paginación |
| `features/core/widgets/boton_exportar.dart` | Menú Excel/PDF con indicador de descarga |
| `*_paginados_provider.dart`, `inventario_provider.dart` | Consulta inmutable (filtros + página) y su provider |
| `filtros_usuarios.dart`, `filtros_materiales.dart` | Controles de búsqueda y filtros |

## Agregar otro listado

1. Backend: función `_consulta_xxx(filtros)` en el servicio, `buscar_xxx` con `paginar`, y las rutas `/buscar` y `/exportar`.
2. Backend: un `xxx_exportacion.py` que convierta las filas en `TablaExportable`.
3. Frontend: una consulta inmutable + provider, un widget de filtros y una pantalla con `GrillaDatos`, `ControlesPaginacion` y `BotonExportar`.

## Pruebas

- Backend: `backend/tests/test_listados.py` (paginación, filtros, permisos, Excel con todas las filas, PDF, fórmulas).
- Frontend: `frontend/test/listados_paginados_test.dart`.
