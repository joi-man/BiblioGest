# App móvil (Android)

BiblioGest para Android es la aplicación **de los estudiantes**: consultan los libros y revistas de la biblioteca, ven su estado real y los reservan. Funciona **solo conectada al servidor de internet**, igual que la versión web; no tiene modo offline ni base de datos propia.

El personal (bibliotecarios y administradores) sigue usando la web o el ejecutable de Windows. En la v1 la app móvil es **solo para estudiantes**.

## Qué puede hacer el estudiante

| Sección | Qué hace |
|---|---|
| **Catálogo** | Busca **libros y revistas** por título, autor o código. Filtra por tipo y por "solo disponibles". Ve el estado de cada uno y elige uno o varios para **reservar**. |
| **Mis reservas** | Ve todas sus reservas con su estado y la respuesta del bibliotecario. Puede cancelar una reserva pendiente o aprobada, y **volver a reservar** una rechazada o cancelada. |
| **Perfil** | Sus datos, modo oscuro, **cambiar contraseña**, buscar e instalar **actualizaciones** y cerrar sesión. |

Los equipos (proyectores, laptops...) y los medios (DVD, CD) **no aparecen** en la app: los presta el personal en el mostrador. El servidor lo impone: un estudiante no recibe esos materiales en el catálogo y no puede reservarlos aunque llame a la API a mano.

### Estado de cada material

El estudiante ve siempre el estado real, con textos pensados para él:

| Ve | Significa | ¿Se puede reservar? |
|---|---|---|
| **Disponible** | Está en la biblioteca | Sí |
| **Reservado** | Ya se aprobó a otra persona y espera que lo retire (24 h). Si no lo retira, vuelve a estar disponible | No |
| **En uso** | Alguien lo tiene en préstamo (incluye los vencidos: eso no le incumbe) | No |
| **Fuera de servicio** | No se presta por ahora | No |

En el detalle de cada material se explica por qué no se puede reservar.

## Reservas: de principio a fin

```
Estudiante reserva ──► [pendiente] ──► Bibliotecario la ve en Préstamos → Solicitudes
                                         │
                       ┌─────────────────┼──────────────────┐
                    aprueba           rechaza (con motivo)  
                       │                 │
                  [aprobado]        [rechazado] ──► el estudiante puede volver a reservar
              (material "reservado")
                       │
        retira / cancela / no retira a tiempo / el bibliotecario la cede a otra persona
```

El detalle de estados y reglas (límite de items, vencidos, plazos) está en [prestamos-devoluciones.md](prestamos-devoluciones.md).

### Cómo se entera el estudiante

1. **Dentro de la app:** la lista de reservas se actualiza sola cada 30 segundos y al volver a abrir la app. Cuando el bibliotecario responde, aparece un aviso ("Tu reserva de «X» fue aprobada. Pasa a retirarla.", o rechazada con su motivo).
2. **Por correo:** al aprobar, rechazar o ceder su reserva se le envía un correo con el detalle y el motivo. (De momento los avisos son solo por correo; no hay notificaciones push.)

Los correos salen del **servidor central** (SMTP, ver [RECUPERACION_CONTRASENA.md](../RECUPERACION_CONTRASENA.md) para configurarlo). Se envían en segundo plano: si el correo falla, la operación del bibliotecario igual se completa y el error queda en el registro del servidor.

> **Ejecutable de Windows con servidor:** si un bibliotecario aprueba o rechaza desde el ejecutable *sin conexión* y luego sincroniza, el cambio llega al servidor pero **no se envía el correo** (los avisos se generan al ejecutar la acción en el servidor, no al sincronizar). El estudiante igual lo ve en la app.

### Ceder una reserva a otra persona (solo casos importantes)

Un bibliotecario puede prestar a **otra persona** un material que está reservado para alguien más, por ejemplo cuando un docente lo necesita para una clase ahora mismo.

- En **Préstamos → Por retirar**, la reserva tiene el botón **Prestar a otra persona**.
- Debe elegir a la persona y escribir un **motivo** (mínimo 10 caracteres). Es obligatorio porque se le muestra a quien había reservado.
- Todo ocurre en un solo paso: se cancela la reserva original, el material se entrega a la otra persona y a quien reservó se le avisa. Si el nuevo préstamo no es posible (la persona tiene vencidos, supera el máximo de items...), **no cambia nada** y la reserva original queda como estaba.
- Quien había reservado ve en **Mis reservas**: *"Cancelado: <motivo>"*, recibe un correo con el motivo y puede volver a reservar.
- Queda en la bitácora (`RESERVA_CEDIDA` y `PRESTAMO_POR_CESION`).

## Si se va el internet

La app **no se cierra ni se detiene**:

1. Una petición que falla por la red se reintenta sola con esperas crecientes (2, 4, 6, 10 y 15 s). Mientras tanto aparece una franja discreta: *"Se perdió la conexión. Reconectando… (intento 2 de 5)"*.
2. Si tras varios intentos no hay conexión, la franja pasa a un aviso claro: *"No pudimos conectar con el servidor. Revisa tu conexión a internet; seguimos intentando"*, con el botón **Reintentar ahora**.
3. La app **sigue intentando en segundo plano** (cada 10 s) aunque ya haya avisado. Al volver la conexión, el aviso desaparece y las pantallas vuelven a pedir sus datos solas: no hay que hacer nada.

Qué se reintenta, para no duplicar nada:

| Falla | Lecturas (consultas) | Escrituras (reservar, cancelar...) |
|---|---|---|
| No se pudo conectar (no salió la petición) | Se reintenta | Se reintenta |
| Se agotó el tiempo esperando respuesta | Se reintenta | **No** (pudo haber llegado: se avisa el error) |
| El servidor respondió 502/503/504 (despertando) | Se reintenta | No |
| Error normal (404, 409, 422...) | No: se muestra el motivo | No: se muestra el motivo |

> Mientras el servidor gratuito de Render "duerme", la primera petición puede tardar un minuto. Los reintentos cubren ese caso.

### Catálogo sin conexión (solo consulta)

Cada vez que el catálogo se descarga completo, la app guarda una copia en el teléfono. Si no hay conexión, se muestra esa **copia guardada** al instante, con un aviso con su fecha ("Sin conexión. Estás viendo el catálogo guardado el 12 oct 2026, 15:40; el estado de los materiales puede haber cambiado"). La búsqueda y los filtros funcionan sobre la copia. **Reservar necesita conexión**; nada de lo que se haga sin conexión se guarda para después.

## Cuenta

- **Cambiar contraseña** (todas las plataformas y todos los roles): pide la contraseña actual y la nueva dos veces. Está en **Perfil** (móvil), en el menú lateral (escritorio y web) y en el encabezado de **Inicio**. El servidor comprueba la contraseña actual, exige que la nueva sea distinta y de al menos 6 caracteres, y limita los intentos (10 por 15 minutos). Queda en la bitácora (`PASSWORD_CHANGE`). Detalle de la API en [RECUPERACION_CONTRASENA.md](../RECUPERACION_CONTRASENA.md).
- **Olvidé mi contraseña:** igual que en la web, con un código de 6 dígitos por correo.
- La sesión dura 60 minutos (`EXPIRACION_TOKEN_MINUTOS`); al vencer, la app vuelve al inicio de sesión con un aviso.

## Dónde se descarga

- **Página de inicio de sesión de la versión web:** tiene los botones **Windows** y **Android** con la última versión.
- Enlaces fijos (apuntan siempre a la última versión publicada):
  - `https://github.com/joi-man/BiblioGest-releases/releases/latest/download/BiblioGest.apk`
  - `https://github.com/joi-man/BiblioGest-releases/releases/latest/download/BiblioGest-Setup.exe`
- La app **no se publica en Google Play**. Para instalar el APK, Android pide permitir "instalar apps de esta fuente" (una vez) al abrir el archivo descargado.

## Actualizaciones desde la app

Al abrir, la app busca una versión nueva (`latest-android.json`) y funciona como el ejecutable de Windows (ver [actualizaciones.md](actualizaciones.md)):

- **Opcional:** aviso con las novedades y los botones *Actualizar ahora*, *Más tarde* y *Omitir esta versión*.
- **Obligatoria** (la instalada es anterior a la mínima): pantalla que solo permite actualizar o salir.
- En **Perfil → Actualizaciones** se ve la versión instalada y se puede buscar a mano.

Al pulsar *Actualizar ahora*: descarga el APK, verifica su tamaño y SHA-256 contra el manifiesto firmado (Ed25519) y abre el instalador de Android, que pide **confirmar**. Es una confirmación del sistema que no se puede omitir, por eso en Android **no existe** la opción de instalar automáticamente. La primera vez, Android pide además autorizar a BiblioGest a instalar apps; la app abre esa pantalla de Ajustes y pide volver a pulsar *Actualizar*.

> **Android solo acepta la actualización si el APK está firmado con la misma clave que la app instalada.** Por eso la clave de firma se crea una vez y se guarda para siempre (ver abajo). Con otra clave, el teléfono rechaza la instalación y hay que desinstalar e instalar de nuevo.

## Cómo está hecho

| Pieza | Dónde |
|---|---|
| Pantallas del estudiante | `frontend/lib/features/student/presentation/screens/` (`shell_estudiante`, `catalogo_screen`, `mis_solicitudes_screen`, `perfil_screen`) |
| Estado del material para el estudiante | `student/presentation/widgets/chip_estado_estudiante.dart` |
| Catálogo + copia guardada | `student/presentation/providers/catalogo_provider.dart`, `student/data/catalogo_cache.dart` |
| Avisos de respuesta del bibliotecario | `student/presentation/providers/novedades_solicitudes.dart` |
| Reintentos y estado de la conexión | `core/network/reintento_interceptor.dart`, `estado_conexion.dart`, `reconector_conexion.dart`; franja en `student/presentation/widgets/aviso_conexion.dart` |
| Actualizador (instalador de Android) | `core/actualizaciones/instalador_actualizaciones_io.dart` + `android/app/src/main/kotlin/com/bibliogest/app/MainActivity.kt` |
| Cesión de reservas | `backend/app/servicios/prestamos/cesion_servicio.py`, ruta `POST /api/prestamos/{id}/ceder` |
| Avisos por correo | `backend/app/servicios/prestamos/aviso_prestamo_servicio.py` |

El backend es el mismo de siempre: las reglas (plazos, límites, estados) no se duplican en la app.

## Construir el APK

Requisitos, **una sola vez**:

1. **Android SDK** (viene con Android Studio) y licencias aceptadas: `flutter doctor --android-licenses`. Gradle descarga además el NDK y otras piezas (varios GB): conviene tener **al menos 10 GB libres** en el disco.
2. **Clave de firma de la app** (esto es lo que hace posible actualizar):

   ```powershell
   .\scripts\crear_keystore.ps1
   ```

   Crea `%USERPROFILE%\.bibliogest\bibliogest-release.jks` y `frontend\android\key.properties` (ignorado por git).
   - **Haz una copia de seguridad** de la carpeta `%USERPROFILE%\.bibliogest` y guarda la contraseña (por ejemplo, en un gestor de contraseñas). Si se pierde, los teléfonos ya instalados **no podrán actualizar**.
   - No la subas a ningún repositorio.
3. La **clave de firma de actualizaciones** (Ed25519) es la misma del ejecutable de Windows (ver [actualizaciones.md](actualizaciones.md)).

Cada versión:

```powershell
.\scripts\construir_apk.ps1 -ApiUrl https://tu-api.onrender.com -Notas "Qué cambió en esta versión."
# Para forzar la actualización de versiones viejas:
.\scripts\construir_apk.ps1 -ApiUrl https://tu-api.onrender.com -Minima 0.11.0 -Notas "Corrige un error grave."
```

Genera en `build\apk\`: `BiblioGest-<versión>.apk`, `BiblioGest.apk` (nombre fijo, es el enlace de la web), `latest-android.json` y `latest-android.json.sig`. La versión sale de `frontend/pubspec.yaml`; el script exige que coincida.

**Publicar:** súbelos al **mismo Release** `v<versión>` del repositorio de releases donde están los archivos de Windows (`BiblioGest-Setup-<versión>.exe`, `BiblioGest-Setup.exe`, `latest.json`, `latest.json.sig`). Debe ser un solo Release por versión: las dos aplicaciones leen `releases/latest/download/...`, y si el último Release no tuviera los archivos de una de ellas, esa dejaría de encontrar actualizaciones y su botón de descarga fallaría.

Sin `android\key.properties`, el script se niega a compilar (salvo `-SinFirmaDeRelease`, solo para pruebas: ese APK usa la clave de depuración y no se puede publicar).

### Desarrollo

```powershell
cd frontend
flutter run -d <dispositivo>                                    # contra http://localhost:8000
flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:8000   # emulador -> tu PC
flutter run -d <telefono> --dart-define=API_URL=https://tu-api.onrender.com
```

En el emulador, `localhost` es el propio emulador: tu PC es `10.0.2.2`. Las compilaciones de depuración permiten `http`; las de release solo `https`.

## Identidad e iconos

- Nombre visible: **BiblioGest** (Android, web y Windows). Paquete de Android: `com.bibliogest.app`.
- Los iconos de todas las plataformas salen de un solo dibujo. Ver [iconos.md](iconos.md).

## Limitaciones conocidas

- **Solo estudiantes.** El personal no tiene una vista pensada para el móvil (la web funciona en pantallas angostas, pero no está optimizada).
- **Sin notificaciones push.** Los avisos son por correo y por la app abierta. Con la app cerrada, el estudiante se entera por el correo.
- **Sin modo offline de escritura.** Sin conexión solo se consulta la copia del catálogo.
- **Solo Android.** No hay versión para iPhone.
- **Sesión de 60 minutos:** al vencer hay que iniciar sesión otra vez.
- **El APK no se puede instalar si el teléfono bloquea fuentes desconocidas** (algunos teléfonos de empresa).

## Pruebas

- Backend: `backend/tests/test_app_movil.py` (catálogo del estudiante, estados, reservas, rechazo y nueva reserva, correos, cesión y su reversión, cambio de contraseña).
- Frontend: `test/app_movil_estudiante_test.dart` (estados que ve el estudiante, avisos de respuesta, copia del catálogo, franja de conexión), `test/reintento_conexion_test.dart` (reintentos y reconexión), `test/cambiar_contrasena_test.dart`, `test/actualizaciones_test.dart` (manifiesto del APK).
