# App móvil (Android)

BiblioGest para Android es la aplicación **de los estudiantes**: consultan los libros y revistas de la biblioteca, ven su estado real y los reservan. Funciona **solo conectada al servidor de internet**, igual que la versión web; no tiene modo offline ni base de datos propia.

La app es un **complemento** del sistema: simple y rápida para lo del día a día. El personal (bibliotecarios y administradores) también puede entrar, con una versión reducida (ver [Personal en el móvil](#personal-en-el-móvil)); la gestión completa, los reportes y las exportaciones se hacen desde la web o el ejecutable de Windows.

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

## Personal en el móvil

Un bibliotecario o administrador que entra desde el teléfono ve un menú inferior con **lo esencial para atender el mostrador**:

| Sección | Qué puede hacer en el móvil |
|---|---|
| **Inicio** | Los indicadores de lo que requiere atención (solicitudes por revisar, reservas por retirar, vencidos...) |
| **Préstamos** | Aprobar, rechazar (con motivo), entregar, cancelar y **prestar una reserva a otra persona**; registrar un préstamo directo |
| **Devoluciones** | Registrar devoluciones |
| **Materiales** | **Solo consultar**: buscar por título, código, autor o marca y filtrar por estado |
| **Perfil** | Cambiar contraseña, modo oscuro, actualizaciones y cerrar sesión |

**Solo en la web o el escritorio:** usuarios, categorías, registrar/editar/eliminar materiales, **exportaciones a Excel y PDF** (reportes), grillas completas con paginación y la sincronización del ejecutable. Si alguien abre esas direcciones en el móvil, vuelve al Inicio. La decisión de qué va al móvil está en `app/shell_navegacion.dart` (`destinosPersonalMovil`) y en `app/router.dart` (`_rutasSoloEscritorio`).

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
| Menú y pantallas del personal en el móvil | `app/shell_navegacion.dart`, `app/router.dart`, `features/materials/presentation/screens/materiales_movil_screen.dart` |
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

**Funcionales**

- **El personal tiene una versión reducida.** Sin reportes ni exportaciones, sin gestión de usuarios, categorías ni materiales (el inventario es solo de consulta). Todo eso solo está en la web y el escritorio, a propósito, para que la app siga siendo simple.
- **Solo libros y revistas.** Los equipos y medios los presta el personal en el mostrador; no se pueden ver ni reservar desde la app.
- **Sin modo offline de escritura.** Sin conexión solo se consulta la copia guardada del catálogo, cuyo estado puede estar desactualizado. Reservar, cancelar y cambiar la contraseña necesitan conexión; nada se guarda "para después". Si nunca se abrió el catálogo con conexión, no hay copia que mostrar.
- **Una reserva no bloquea el material mientras está pendiente.** El material solo pasa a *Reservado* cuando el bibliotecario aprueba. Dos estudiantes pueden tener solicitudes pendientes del mismo libro; se aprueba la primera y la otra falla al aprobarse.
- **Solo se puede ceder una reserva aprobada** (no una pendiente ni un préstamo ya entregado), y la cesión cancela toda la reserva, no solo un item.
- **Solo Android.** No hay versión para iPhone.
- **Sesión de 60 minutos.** Al vencer hay que iniciar sesión otra vez (`EXPIRACION_TOKEN_MINUTOS`).

**Avisos**

- **Solo por correo; sin notificaciones push.** Con la app cerrada, el estudiante se entera por el correo. Dentro de la app, el aviso aparece al refrescarse (cada 30 s o al volver a abrirla).
- **Depende del servidor de correo.** Sin `SMTP_CLAVE` en el servidor no sale ningún correo. **El plan gratuito de Render bloquea el SMTP de Gmail** (puertos 25, 465 y 587): hay que usar un servicio con el puerto 2525 (ver [RECUPERACION_CONTRASENA.md](../RECUPERACION_CONTRASENA.md)). Si el envío falla, la operación del bibliotecario igual se completa (solo queda el error en el registro del servidor) y no se reintenta.
- **No se envían correos si el bibliotecario trabaja desde el ejecutable sin conexión** y sincroniza después: el cambio llega al servidor, pero el correo se genera al ejecutar la acción en el servidor, no al sincronizar. El estudiante igual lo ve en la app.
- Las horas de los correos van en UTC.

**Conexión**

- **Escrituras con tiempo agotado no se reintentan** (pudieron llegar al servidor); se muestra el error y la persona decide.
- **El servidor gratuito de Render duerme** tras un rato sin uso: la primera petición puede tardar cerca de un minuto, y la app lo trata como un corte de conexión (franja de "Reconectando").

**Instalación y actualizaciones**

- **El APK no está en Google Play.** Hay que permitir "instalar apps de esta fuente" (una vez), y algunos teléfonos de empresa bloquean las fuentes desconocidas. Algunos teléfonos muestran el aviso de Play Protect al instalar un APK de fuera de la tienda.
- **Cada actualización pide confirmar** en el instalador de Android; no hay actualización automática ni se puede omitir ese paso.
- **La clave de firma no se puede recuperar.** Si se pierde `bibliogest-release.jks` o su contraseña, los teléfonos instalados no podrán actualizar y habrá que desinstalar e instalar otra vez.
- **Un solo Release por versión con los archivos de Windows y de Android.** Si falta alguno, esa plataforma deja de encontrar actualizaciones o su botón de descarga da error 404. Los enlaces fijos de la web (`BiblioGest.apk`, `BiblioGest-Setup.exe`) solo funcionan desde el primer Release que los incluya.
- **Reversión:** no hay vuelta atrás automática; Android además no deja instalar una versión menor sobre una mayor. Para retirar una versión mala, publica una nueva con número mayor.

**Compilación**

- **Espacio en disco:** Gradle descarga el NDK y otras piezas; hacen falta unos 10 GB libres, y la compilación falla con "Espacio en disco insuficiente" si no los hay.
- **Aviso de Gradle:** al compilar aparece un aviso de que el plugin `shared_preferences_android` aplica el plugin de Kotlin (KGP). No impide compilar; versiones futuras de Flutter podrían exigir actualizar ese plugin.
- **Iconos:** salen de un dibujo de 96 px, así que los grandes se ven algo suaves (ver [iconos.md](iconos.md)).

## Pruebas

- Backend: `backend/tests/test_app_movil.py` (catálogo del estudiante, estados, reservas, rechazo y nueva reserva, correos, cesión y su reversión, cambio de contraseña).
- Frontend: `test/app_movil_estudiante_test.dart` (estados que ve el estudiante, avisos de respuesta, copia del catálogo, franja de conexión), `test/reintento_conexion_test.dart` (reintentos y reconexión), `test/cambiar_contrasena_test.dart`, `test/actualizaciones_test.dart` (manifiesto del APK).
