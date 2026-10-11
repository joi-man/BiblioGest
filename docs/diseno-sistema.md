# Sistema de diseño de BiblioGest

Estilo **editorial cálido**: superficies planas, filetes finos en lugar de sombras, esquinas poco redondeadas (4 px), un único color de acento y tipografía con carácter. Incluye **modo oscuro** que se recuerda entre sesiones.

## Principios

- **Un solo acento** (terracota) para la acción principal y el elemento seleccionado. El resto es tinta y papel.
- **Sin sombras ni tarjetas gigantes**: la jerarquía la dan los filetes, el espacio y la tipografía.
- **Los colores nunca se escriben en las pantallas.** Se leen del tema con `context.colores`, así el modo oscuro funciona solo.
- **Los estados tienen un único color** en toda la app (ver `ColoresEstado`).

## Paleta (`lib/core/theme/colores_app.dart`)

| Token | Claro | Oscuro | Uso |
|---|---|---|---|
| `papel` | `#F4EEE3` | `#1B1815` | Fondo general |
| `superficie` | `#FBF8F2` | `#24201C` | Paneles, tarjetas, diálogos |
| `superficieElevada` | `#FFFFFF` | `#2E2924` | Campos, menús |
| `linea` | `#D9CFBD` | `#3F382F` | Bordes y divisores |
| `tinta` | `#231F1A` | `#EDE5D6` | Texto principal |
| `tintaSuave` | `#6B6256` | `#A89F90` | Texto secundario |
| `acento` | `#B4472A` | `#E08A66` | Acción principal |
| `acentoSuave` | `#F0DCCF` | `#3A2A22` | Fondo de selección |

Estados: `disponible` (verde bosque), `prestado` (azul pizarra), `reservado` y `pendiente` (ocre), `vencido` (rojo ladrillo), `fueraDeServicio` (gris cálido).

## Tipografía (`lib/core/theme/tipografia_app.dart`)

Familias **IBM Plex** (licencia OFL, empaquetadas en `assets/fonts/`, sin depender de internet):

- **IBM Plex Serif**: títulos y encabezados (carácter editorial).
- **IBM Plex Sans**: texto, tablas y formularios.
- **IBM Plex Mono**: códigos de inventario y números de serie (`TipografiaApp.codigo`).

## Estructura del código

| Archivo | Responsabilidad |
|---|---|
| `core/theme/colores_app.dart` | Paletas clara/oscura como `ThemeExtension` y `context.colores` |
| `core/theme/colores_estado.dart` | Estado (texto del backend) → color y etiqueta en español |
| `core/theme/tipografia_app.dart` | Escala tipográfica |
| `core/theme/tema_app.dart` | `ThemeData` claro y oscuro (componentes) |
| `core/theme/almacen_modo_tema.dart` | Persistencia del modo en el dispositivo |
| `core/theme/modo_tema_provider.dart` | Estado del modo y acción `alternar()` |
| `app/shell_navegacion.dart` | Menú lateral (escritorio) y barra inferior (móvil) |
| `features/auth/presentation/widgets/panel_autenticacion.dart` | Plantilla de login y recuperación |

Componentes compartidos en `features/core/widgets/`: `ChipEstado`, `EncabezadoPagina`, `EstadoVacio`, `BarraBusqueda`, `BotonModoTema`, `alertas.dart`, `confirmacion.dart`.

## Cómo usarlo

```dart
final colores = context.colores;            // paleta del modo actual
ChipEstado(estado: 'vencido');              // etiqueta de estado
EncabezadoPagina(titulo: 'Préstamos', acciones: [...]);
Text('INV-0042', style: TipografiaApp.codigo(colores.tinta));
```

## Estado de la migración

- Migrado al nuevo diseño: login, recuperación de contraseña, navegación principal, avisos y confirmaciones.
- Pendiente (se hace al tocar cada módulo): dashboard, materiales, usuarios y categorías todavía usan colores fijos en parte de su código.
