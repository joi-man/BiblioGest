# Autores, ejemplares y tomos (versión 0.14.0)

Cómo se manejan los autores de los libros, la cantidad de ejemplares de cada material y las obras de varios tomos, y cómo se mantienen coherentes las reservas y los préstamos.

## Autores

Un autor puede tener varios libros y un libro puede tener varios autores (relación muchos a muchos, tablas `autores` y `materiales_autores`).

Se pueden cargar de dos formas, a elección de quien trabaja:

- **Sección «Autores»** (web y escritorio): lista paginada con búsqueda, cuántos materiales tiene cada autor, crear, renombrar y eliminar. Al renombrar un autor se actualizan sus libros. No se puede eliminar un autor que aún tiene materiales.
- **Dentro del propio material**: el formulario de material tiene un selector de autores con autocompletado. Se eligen los existentes y, si falta alguno, se escribe y se crea ahí mismo («Crear autor …»), sin salir de la pantalla de materiales.

Los nombres se comparan sin tildes ni mayúsculas: «gabriel garcia marquez» y «Gabriel García Márquez» son el mismo autor y no se duplican.

### API

| Ruta | Para qué |
|---|---|
| `GET /api/autores/?q=&limite=` | Autores que coinciden (para el autocompletado) |
| `GET /api/autores/buscar?q=&pagina=&tamano=` | Lista paginada con `cantidad_materiales` |
| `POST /api/autores/`, `PUT /api/autores/{id}`, `DELETE /api/autores/{id}` | Alta, edición y baja lógica (personal) |
| `POST/PUT /api/materiales/` con `autores_ids` y/o `autores_nuevos` | Asigna autores al material; los nuevos se crean en el mismo paso |

Al enviar `autores_ids` o `autores_nuevos` el material queda con **exactamente** esos autores. El campo `autor` (texto) se sigue devolviendo con el resumen «A, B» y, por compatibilidad con aplicaciones anteriores, también se acepta al crear o editar (se separa en autores por `;`, `/`, `&` o «y»; la coma no separa porque «Apellido, Nombre» es un solo autor).

## Búsqueda mejorada

`q` busca por **palabras**: todas deben aparecer, en cualquier orden, en el título, los autores, el código, el ISBN, la editorial, el tomo, la marca, el modelo o la serie, sin importar tildes ni mayúsculas (`garcia marquez`, `borges aleph`, `anos soledad`).

También se puede filtrar por autor con `autor_id` (listado, búsqueda paginada y exportación). Para esto cada material guarda `texto_busqueda`, un texto normalizado que se recalcula al cambiar el material o el nombre de un autor.

## Ejemplares (cantidad disponible)

Cada material tiene `cantidad_total` ejemplares. Se calculan a partir de los préstamos:

| Campo | Significado |
|---|---|
| `cantidad_reservada` | Ejemplares de solicitudes **aprobadas** que aún no se retiraron |
| `cantidad_prestada` | Ejemplares entregados dentro de plazo |
| `cantidad_vencida` | Ejemplares entregados y pasados de plazo |
| `cantidad_fuera_servicio` | Ejemplares dañados o perdidos (los fija el personal o una devolución con daños mayores o pérdida) |
| `cantidad_disponible` | `total − reservados − prestados − vencidos − fuera de servicio` |

Reglas:

- Se puede solicitar, aprobar o prestar mientras `cantidad_disponible ≥ 1`. Una solicitud **pendiente** no reserva; el ejemplar se reserva al aprobar. Si dos personas piden el último ejemplar, la segunda aprobación se rechaza (409).
- Cada solicitud usa **un ejemplar por material**; el límite de ítems simultáneos por persona sigue vigente.
- Cancelar una reserva, que expire sin retirarse, o devolver un ejemplar lo deja disponible de nuevo. Una devolución con daños mayores o pérdida lo pasa a «fuera de servicio».
- Reservados, prestados y vencidos **no son contadores que suben y bajan**: se **recalculan** contando los ítems de préstamo vigentes después de cada operación (`material_estado_servicio.recalcular`). Así no se desajustan.
- `estado` se deriva: «disponible» mientras quede un ejemplar libre; si no, vencido, prestado, reservado o fuera de servicio, en ese orden de urgencia.
- No se puede dejar `cantidad_total` por debajo de lo reservado, prestado, vencido y fuera de servicio (400).
- El panel de inicio cuenta **ejemplares**, no títulos.
- Con varios ejemplares, la condición física general del material no cambia por una devolución; con un solo ejemplar se comporta como antes.

## Tomos

Una obra de varios tomos se carga como **un material por tomo**, con su propio código, `tomo` (por ejemplo «2» o «II») y `total_tomos` (por ejemplo 5). Cada tomo tiene su cantidad y se reserva o presta por separado. Se muestra como «Título (Tomo 2 de 5)» y se encuentra buscando «tomo 2».

## Actualización de una base existente

`app/core/migracion_autores.py` (la usa la migración de Alembic `a7b8c9d0e1f2` y también el arranque de la API y del ejecutable de escritorio) es **repetible** y:

1. Crea las tablas de autores y agrega las columnas nuevas de `materiales`.
2. Convierte el texto de `autor` en autores, sin duplicados.
3. Las unidades que estaban reservadas, prestadas, vencidas o fuera de servicio pasan a contar como un ejemplar en ese estado.
4. Calcula el texto de búsqueda.

Los autores reciben un ID calculado a partir del nombre, de modo que el servidor y cada equipo que migran por separado llegan a los mismos IDs y al sincronizar no aparecen duplicados.

## Sincronización

Los autores y sus vínculos se replican como el resto de las tablas (ver [ejecutable-offline.md](ejecutable-offline.md)). Los contadores de ejemplares viajan con el material, así que dos equipos que prestan el mismo material sin conexión pueden quedar en conflicto al sincronizar, igual que antes con el estado.

## Limitaciones

- Una solicitud pide un ejemplar de cada material (no varias copias del mismo).
- Las aplicaciones anteriores a la 0.14.0 siguen funcionando (los campos nuevos se agregaron sin quitar los anteriores), pero no muestran autores múltiples ni cantidades.
