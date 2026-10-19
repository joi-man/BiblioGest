# Préstamos, devoluciones e inventario

Cómo funciona el módulo central de BiblioGest: qué se presta, cómo se pide, quién lo gestiona y cómo se devuelve.

## Qué se presta

Cada **unidad física** es una fila del inventario (`materiales`), con su propio código. Dos proyectores iguales son dos filas, cada una con su serie, su condición y su historial. Así se sabe cuál se dañó o quién la tiene.

| Grupo | Tipos | Campos propios |
|---|---|---|
| Bibliográfico | `libro`, `revista` | autor, ISBN, editorial, año, páginas |
| Medios | `dvd`, `cd` | formato, duración |
| Equipos | `proyector`, `alargador`, `laptop`, `tablet`, `parlante`, `microfono`, `camara`, `adaptador`, `otro` | marca, modelo, número de serie, accesorios |

Campos comunes a toda unidad: `codigo`, `titulo`, `categoria`, `ubicacion`, `condicion` (`nuevo`, `bueno`, `regular`, `malo`), `valor_referencial` (para reposición si se pierde), `es_prestable` (falso = solo consulta en sala) y `plazo_prestamo_horas` (propio, opcional).

**Estados de una unidad:** `disponible` → `reservado` → `prestado` → (`vencido`) → `disponible` o `fuera_de_servicio`.

## Plazo de devolución

Cada item tiene su propia fecha y hora límite. Se calcula al entregar, en este orden:

1. Plazo propio del material (`plazo_prestamo_horas`).
2. Plazo de su categoría.
3. Plazo general (`PLAZO_PRESTAMO_HORAS_DEFECTO`, 168 h = 7 días).

Ejemplo: libros 168 h, proyectores 4 h, laptops 6 h. Un mismo préstamo puede mezclar materiales con plazos distintos.

### Fecha y hora de devolución elegidas por el personal

Por defecto se usa el plazo automático de arriba. El personal puede **fijar otra fecha y hora** de devolución (para todos los items del préstamo) en tres momentos:

- **Préstamo directo:** el campo está visible en el formulario, como parte de la confirmación (persona, materiales y fecha: tres pasos).
- **Entregar una solicitud** (pendiente o aprobada): botón «Elegir fecha de devolución» junto a «Entregar ahora». Entregar sin elegir sigue siendo un solo clic.
- **Prestar una reserva a otra persona** (cesión).

Reglas: la fecha debe ser posterior a este momento y no pasar de un año (si no, se muestra un mensaje claro y el servidor responde 400 con el mismo texto). La fecha y la hora que se eligen son **de Paraguay** aunque el dispositivo tenga otra zona horaria; se envían al servidor en UTC (`fecha_devolucion_esperada`).

## Flujo de un préstamo

```
pendiente --aprobar--> aprobado --entregar--> activo <--> vencido --> devuelto
    |                     |
 rechazar              cancelar (o expira)
 cancelar
```

| Estado | Significado | Quién lo provoca |
|---|---|---|
| `pendiente` | El estudiante solicitó; espera revisión | Estudiante (app móvil) |
| `aprobado` | Reservado; las unidades pasan a `reservado` y hay un plazo para retirarlas (`HORAS_RETIRO_RESERVA`, 24 h) | Personal |
| `rechazado` | No se concedió; guarda el motivo | Personal |
| `cancelado` | Cancelado por el usuario, el personal, o porque la reserva no se retiró a tiempo | Cualquiera / sistema |
| `activo` | Material entregado y dentro de plazo | Personal |
| `vencido` | Entregado y pasado de plazo | Sistema |
| `devuelto` | Todos los items fueron devueltos | Personal |

### Ceder una reserva a otra persona

Caso excepcional: un material **reservado** (`aprobado`) para alguien se presta a otra persona (por ejemplo, un docente lo necesita ahora para una clase). El bibliotecario usa **Prestar a otra persona** sobre la reserva e indica un **motivo** obligatorio (mínimo 10 caracteres).

En una sola transacción: la reserva original pasa a `cancelado` con ese motivo, las unidades se liberan y se entregan a la otra persona como un préstamo `activo` (con sus reglas habituales: usuario activo, sin vencidos, dentro del límite; el personal puede omitirlas con `omitir_validaciones_usuario`). Si el nuevo préstamo no es posible, nada cambia. A quien reservó se le avisa por correo y ve el motivo en su app. Queda en la bitácora (`RESERVA_CEDIDA`, `PRESTAMO_POR_CESION`). Solo se puede ceder una reserva aprobada que aún no se retiró.

### Atajos para el mostrador

- **Entregar ahora** sobre una solicitud `pendiente` la aprueba y entrega en un solo paso.
- **Préstamo directo**: el personal registra un préstamo sin solicitud previa. Puede fijar otra fecha límite o saltarse las validaciones de la persona (queda en la bitácora).

### Devoluciones

Solo las registra el personal, desde la pantalla **Devoluciones** (separada de Préstamos). Se devuelve por item, así que una devolución puede ser parcial. Cada item se recibe con una condición:

| Condición | Efecto en la unidad |
|---|---|
| `bueno` | Vuelve a `disponible` |
| `dano_menor` | `disponible`, condición pasa a `regular` |
| `dano_mayor` | `fuera_de_servicio`, condición `malo` |
| `perdido` | `fuera_de_servicio`, condición `malo` |

### Fecha y hora reales de la devolución

Lo normal es registrar la devolución en el momento: no hay nada que elegir (se anota «ahora»). Si el material se recibió **antes** de anotarlo (por ejemplo, lo trajo ayer y no estaba el bibliotecario), en el diálogo de devolución se puede elegir la fecha y hora reales (hora de Paraguay). Como cambia datos que se auditan (días de retraso, multa, vencimientos), tiene condiciones:

- **Motivo obligatorio** (mínimo 10 caracteres).
- **No puede ser futura**, ni **anterior a la entrega** del préstamo, ni de **hace más de 30 días**.
- Los **días de retraso y la multa se calculan con esa fecha**, y el préstamo completo guarda como devolución real la fecha indicada.
- La **bitácora** (`DEVOLUCION_REGISTRADA`) guarda quién lo hizo, la fecha indicada, el motivo y la hora en que realmente se registró.

API: `POST /api/devoluciones/{id}` acepta `fecha_devolucion` (UTC) y `motivo_fecha` además de `items`; los errores responden 400 con un mensaje claro.

El préstamo pasa a `devuelto` cuando ya no quedan items pendientes. Los días de retraso se cuentan como días completos: cualquier fracción pasada del plazo cuenta como un día.

## Reglas

Se validan al solicitar o registrar un préstamo directo (configurables, ver abajo):

- La persona debe estar activa.
- No puede tener préstamos vencidos (`BLOQUEAR_SI_HAY_VENCIDOS`).
- No puede superar `MAX_PRESTAMOS_ACTIVOS` items entre pendientes, reservados y entregados.
- Cada material debe ser prestable y estar disponible.

**Un estudiante solo puede solicitar libros y revistas.** El catálogo (`GET /api/materiales/`) le devuelve solo esos tipos y sin las unidades fuera de servicio, y `POST /api/solicitudes/` rechaza con 403 cualquier otro. Los equipos y medios los presta el personal (solicitud a su nombre o préstamo directo).

Dos personas no pueden reservar la misma unidad: al aprobar se bloquea la fila del material (en PostgreSQL) y se verifica que siga disponible.

## Multas (opcionales)

Están **desactivadas por defecto** (`MULTAS_HABILITADAS=False`). Con ellas apagadas el sistema nunca calcula ni muestra multas. Si se activan, cada devolución suma:

- `MULTA_POR_DIA_RETRASO` × días de retraso.
- `MULTA_DANO_MENOR` o `MULTA_DANO_MAYOR` según la condición.
- El `valor_referencial` del material si se perdió.

## Reportes

Reportes de préstamos, **préstamos vencidos por rango de fechas** (RFC-G1) y devoluciones, con exportación a CSV, Excel y PDF. Detalle en [reportes.md](reportes.md).

## Avisos por correo

Al **aprobar**, **rechazar** o **ceder** una reserva, el servidor le envía un correo al estudiante (con los materiales y, si aplica, el motivo). Se envían en segundo plano después de responder, así que un SMTP lento o caído nunca retrasa ni rompe la operación. Requieren `SMTP_CLAVE` en el servidor (ver [RECUPERACION_CONTRASENA.md](../RECUPERACION_CONTRASENA.md)). En el ejecutable de Windows sin clave de correo no se envían.

## Configuración

Variables de entorno (en `backend/.env`):

| Variable | Defecto | Descripción |
|---|---|---|
| `PLAZO_PRESTAMO_HORAS_DEFECTO` | `168` | Plazo si ni material ni categoría lo definen |
| `MAX_PRESTAMOS_ACTIVOS` | `3` | Items simultáneos por persona |
| `BLOQUEAR_SI_HAY_VENCIDOS` | `True` | Impide nuevas solicitudes con préstamos vencidos |
| `HORAS_RETIRO_RESERVA` | `24` | Tiempo para retirar una reserva aprobada |
| `MULTAS_HABILITADAS` | `False` | Activa el cálculo de multas |
| `MULTA_POR_DIA_RETRASO` | `0` | Tarifa por día de retraso |
| `MULTA_DANO_MENOR` / `MULTA_DANO_MAYOR` | `0` | Cargo fijo por daño |

## API

Todas las rutas requieren sesión. Las de personal exigen rol `admin` o `bibliotecario`.

| Método y ruta | Quién | Qué hace |
|---|---|---|
| `POST /api/solicitudes/` | Cualquier usuario | Solicita uno o varios materiales |
| `GET /api/solicitudes/mias` | Cualquier usuario | Sus solicitudes y préstamos |
| `POST /api/solicitudes/{id}/cancelar` | Dueño o personal | Cancela una solicitud pendiente o reserva |
| `GET /api/prestamos/` | Personal | Lista con filtros: `estado` (repetible), `usuario_id`, `q`, `mas_antiguos_primero` |
| `GET /api/prestamos/{id}` | Personal | Detalle |
| `POST /api/prestamos/directo` | Personal | Préstamo en mostrador, ya entregado |
| `POST /api/prestamos/{id}/aprobar` | Personal | Aprueba y reserva |
| `POST /api/prestamos/{id}/rechazar` | Personal | Rechaza con `motivo` |
| `POST /api/prestamos/{id}/ceder` | Personal | Cancela una reserva aprobada (con `motivo`) y presta el material a `usuario_id` |
| `POST /api/prestamos/{id}/entregar` | Personal | Entrega (aprueba antes si estaba pendiente) |
| `POST /api/prestamos/{id}/cancelar` | Personal | Cancela |
| `GET /api/devoluciones/pendientes` | Personal | Préstamos con material por recibir (`q` opcional) |
| `GET /api/reportes/{tipo}` y `/exportar` | Personal | Reportes `prestamos`, `vencidos` y `devoluciones` con filtros y exportación (ver [reportes.md](reportes.md)) |
| `POST /api/devoluciones/{prestamo_id}` | Personal | Registra la devolución de uno o más items |
| `GET /api/dashboard/resumen` | Personal | Métricas del inicio |
| `GET /api/materiales/` | Cualquier usuario | Inventario: `q`, `tipo`, `estado`, `disponible`. Al estudiante solo le devuelve libros y revistas |
| `POST /api/auth/cambiar-contrasena` | Cualquier usuario | Cambia la contraseña de la sesión (ver [RECUPERACION_CONTRASENA.md](../RECUPERACION_CONTRASENA.md)) |

La documentación interactiva está en `http://localhost:8000/docs`.

## Pantallas

**Personal (web y escritorio):** Inicio (métricas), Materiales, **Préstamos** (Solicitudes · Por retirar · En préstamo · Historial), **Devoluciones**, **Reportes**, Usuarios y Categorías. En el teléfono el personal tiene solo lo esencial (ver [app-movil.md](app-movil.md)).

**Estudiante (solo móvil):** Catálogo de libros y revistas con búsqueda, filtros, estado real y selección de varios materiales; Mis reservas (con cancelación y "volver a reservar"); Perfil con modo oscuro, cambio de contraseña y actualizaciones. Detalle en [app-movil.md](app-movil.md). En web o escritorio un estudiante ve un aviso para usar la app móvil. Para probar su vista en el navegador durante el desarrollo:

```bash
flutter run -d chrome --dart-define=PERMITIR_ESTUDIANTE_EN_ESCRITORIO=true
```

## Decisiones de diseño

- **Un solo agregado con máquina de estados.** Una solicitud y un préstamo son el mismo registro (`prestamos_cabecera`) en distintos estados; las transiciones válidas están en `servicios/prestamos/maquina_estados.py`.
- **Vencimientos perezosos.** No hay tareas programadas: antes de cada consulta de préstamos se expiran las reservas y se marcan los vencidos (`vencimiento_servicio`). El estado siempre está al día cuando alguien lo mira.
- **Una transacción por operación.** El cambio de datos y su registro en la bitácora se confirman juntos.
- **Hora de Paraguay.** La base guarda UTC sin zona y la API entrega las fechas con sufijo `Z`; las pantallas, los reportes, los correos y el contador «hoy» del Inicio usan la **hora de Paraguay (UTC-3)**, igual en cualquier dispositivo. Paraguay no cambia de horario desde octubre de 2024, por eso basta un desfase fijo (`backend/app/core/hora_paraguay.py`).
- **Una responsabilidad por módulo.** `servicios/prestamos/` tiene un archivo por tarea (solicitud, aprobación, entrega, devolución, vencimiento, multas, reglas, plazos, consultas).

## Pruebas

```bash
cd backend && .venv\Scripts\python -m pytest      # 56 pruebas, sin Docker (SQLite en memoria)
cd frontend && flutter test                        # 25 pruebas
```

Las pruebas del backend usan SQLite, que no soporta el bloqueo de filas; ese comportamiento solo se verifica contra PostgreSQL.
