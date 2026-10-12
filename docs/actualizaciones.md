# Actualizaciones del ejecutable de Windows

El ejecutable se instala **una sola vez**. Después, cada vez que se abre, busca una versión nueva y le pide al usuario actualizar. No hace falta volver a descargar ni a ejecutar el instalador a mano, y los datos de la biblioteca no se tocan.

Aplica al ejecutable instalado (el que trae su propio backend) y a la **app de Android** (ver la sección [App de Android](#app-de-android)). La versión web se actualiza sola al publicarla, y `flutter run` en escritorio no busca actualizaciones.

## Qué ve el usuario

| Situación | Qué pasa |
|---|---|
| Hay una versión nueva y se puede seguir con la actual (**opcional**) | Aparece un aviso con las novedades y tres botones: **Actualizar ahora**, **Más tarde** y **Omitir esta versión**. También puede marcar *Instalar las próximas actualizaciones automáticamente*. Mientras no decida, puede seguir trabajando. |
| La versión instalada es anterior a la **mínima soportada** (**obligatoria**) | Se reemplaza la aplicación por una pantalla de actualización. Solo se puede **Actualizar ahora** o **Salir**. No se puede posponer ni omitir. |
| Actualización automática activada | Al abrir, descarga e instala sola y la app se reinicia. Si falla, **no lo repite en cada inicio**: la siguiente vez pregunta. |
| Sin internet | La app funciona con normalidad (salvo que ya se supiera que la versión es obligatoria, ver abajo). |

- **Más tarde** vuelve a preguntar la próxima vez que se abra la aplicación. **Omitir esta versión** no vuelve a avisar de *esa* versión, pero sí de las siguientes.
- Si el equipo ya había visto una actualización obligatoria, la sigue exigiendo aunque se abra sin conexión (se guarda el último manifiesto verificado). Para actualizar, igualmente necesita internet; los datos siguen a salvo en el equipo.
- En **Sincronización → Actualizaciones** se ve la versión instalada, se puede buscar una versión nueva a mano y activar o desactivar la instalación automática.

## Cómo funciona

```
 BiblioGest.exe (0.10.0)                    Repositorio público de releases
 ───────────────────────                    ───────────────────────────────
 1. descarga latest.json + latest.json.sig ◄── latest.json       (manifiesto)
 2. verifica la firma Ed25519                   latest.json.sig   (firma)
 3. ¿version > instalada? ¿instalada < minima? BiblioGest-Setup-0.10.1.exe
 4. descarga el instalador ────────────────────►
 5. verifica tamaño y SHA-256
 6. cierra el backend, ejecuta el instalador en modo silencioso y se cierra
 7. el instalador reemplaza los archivos y vuelve a abrir BiblioGest
```

El manifiesto (`latest.json`):

```json
{
  "version": "0.10.1",
  "minima": "0.10.0",
  "url": "https://github.com/joi-man/BiblioGest-releases/releases/download/v0.10.1/BiblioGest-Setup-0.10.1.exe",
  "sha256": "<huella del instalador>",
  "tamano": 48123456,
  "notas": "Qué cambió en esta versión.",
  "fecha": "2026-10-11"
}
```

- `version`: la última publicada.
- `minima`: la más antigua que puede seguir usándose. **Quien tenga una anterior debe actualizar.** `0.0.0` significa que la actualización nunca es obligatoria.

### Seguridad

- **Manifiesto firmado (Ed25519).** La app trae incrustada la clave pública (`frontend/lib/core/actualizaciones/clave_publica.dart`) y rechaza cualquier manifiesto que no esté firmado con la clave privada. Así, aunque alguien tomara control del lugar donde se publica, no podría hacer instalar un programa ajeno.
- **Instalador verificado.** Antes de ejecutarlo se comprueba su tamaño y su SHA-256 contra el manifiesto firmado. Si no coincide, se borra y no se instala.
- **Solo https** para descargar (se admite `http` únicamente hacia `localhost`, para pruebas).
- La descarga va a un archivo `.parcial` y solo se renombra al terminar y verificar: nunca queda un instalador a medias. Un instalador ya descargado y verificado se reutiliza.
- **Los datos no se tocan.** Viven en `%LOCALAPPDATA%\BiblioGest`, fuera de la carpeta del programa. Los cambios sin sincronizar están guardados en la base local y se envían después de actualizar.

## Publicar una versión

### Preparación (una sola vez)

1. **Repositorio público de releases.** El repositorio del código es privado, y los equipos no podrían descargar desde él. Crea un repositorio **público** vacío, por ejemplo `joi-man/BiblioGest-releases`, solo para publicar instaladores. No contiene código. Si usas otro nombre, cámbialo en `-UrlBase` y en `urlManifiestoActualizaciones` (`clave_publica.dart`), o compila con `--dart-define=URL_ACTUALIZACIONES=https://.../latest.json`.
2. **Clave de firma.** Ya se generó con `dart run tool/generar_clave_actualizaciones.dart` (desde `frontend`). La clave **privada** está en `%USERPROFILE%\.bibliogest\clave_actualizaciones.key`, fuera del repositorio.
   - **Haz una copia de seguridad** (por ejemplo, en un gestor de contraseñas). Si se pierde, los equipos ya instalados **dejan de aceptar actualizaciones** y habría que reinstalarlos a mano con una app nueva con otra clave pública.
   - **No la subas a ningún repositorio ni la compartas.** Quien la tenga puede publicar actualizaciones en tu nombre.

### Cada versión

1. Sube la versión en `frontend/pubspec.yaml` (`version: 0.10.1+2`; el número tras `+` es la compilación). El script exige que coincida.
2. Compila:

   ```powershell
   .\scripts\construir_ejecutable.ps1 -Notas "Qué cambió en esta versión."
   # Para forzar la actualización de versiones viejas:
   .\scripts\construir_ejecutable.ps1 -Minima 0.10.1 -Notas "Corrige un error grave."
   ```

   Genera en `build\instalador\`: `BiblioGest-Setup-<versión>.exe`, `BiblioGest-Setup.exe` (copia con nombre fijo, es el enlace de descarga de la web), `latest.json` y `latest.json.sig`.
3. En el repositorio de releases, crea un **Release** con la etiqueta `v<versión>` (por ejemplo `v0.10.1`) y sube **los cuatro archivos** (y los de Android, si publicas también la app móvil: ver abajo). Los equipos leen `releases/latest/download/latest.json`, así que el Release más reciente es el que se ofrece.
4. Marca el Release como *latest* (no como borrador ni pre-lanzamiento).

> **`-Minima` se arrastra.** Cada `latest.json` reemplaza al anterior. Si una versión anterior ya exigía `0.10.1` como mínima, la siguiente debe volver a indicar `-Minima 0.10.1` (o más), porque si no, dejaría de ser obligatoria.

> Cuando una versión necesite que **toda** la flota la tenga antes de seguir (por ejemplo, un cambio en la sincronización con el servidor), súbela con `-Minima` igual a esa versión.

## App de Android

La app móvil usa el **mismo mecanismo**: mismo formato de manifiesto, misma clave de firma Ed25519, mismas reglas (opcional, obligatoria, omitir, más tarde). Cambia el manifiesto y el archivo:

| | Windows | Android |
|---|---|---|
| Manifiesto | `latest.json` + `.sig` | `latest-android.json` + `.sig` |
| Archivo | `BiblioGest-Setup-<versión>.exe` | `BiblioGest-<versión>.apk` |
| Enlace fijo de descarga (web) | `BiblioGest-Setup.exe` | `BiblioGest.apk` |
| Script | `scripts/construir_ejecutable.ps1` | `scripts/construir_apk.ps1` |
| Al instalar | Inno Setup silencioso; la app se cierra y se reabre sola | Instalador de Android: pide **confirmar** (no se puede omitir) |
| Instalación automática | Sí (opcional) | No: el sistema siempre pide confirmar |

**Un solo Release por versión, con los archivos de las dos plataformas.** Ambas leen `releases/latest/download/<archivo>`, así que el Release marcado *latest* debe contener `latest.json`, `latest.json.sig`, `BiblioGest-Setup-<v>.exe`, `BiblioGest-Setup.exe`, `latest-android.json`, `latest-android.json.sig`, `BiblioGest-<v>.apk` y `BiblioGest.apk`. Si falta alguno, esa plataforma deja de encontrar actualizaciones (o el botón de descarga de la web da error 404). `-Minima` es independiente para cada plataforma.

Android solo instala la actualización si el APK está firmado con **la misma clave** que la app instalada (ver [app-movil.md](app-movil.md#construir-el-apk)). La primera vez, la app pide autorizar "instalar aplicaciones de esta fuente".

## Qué no cubre (todavía)

- **Firma de código de Windows.** Sin un certificado de pago, Windows puede mostrar el aviso de *SmartScreen* ("Windows protegió su PC") al ejecutar el instalador. La integridad la garantizan la firma del manifiesto y el SHA-256, pero SmartScreen no lo sabe. Se resuelve con un certificado de firma de código.
- **Migración de la base local.** El ejecutable crea su esquema SQLite con `create_all`. Un cambio de columnas en una versión nueva necesita una migración propia para los equipos ya instalados; si no, esa versión debe evitar cambios de esquema.
- **Reversión.** No hay vuelta atrás automática. Para retirar una versión mala, publica una nueva con número mayor.
- **Despliegue gradual.** Todos los equipos reciben la versión a la vez.
- **Descarga reanudable.** Si se corta, se vuelve a descargar entera.
- **Límites de GitHub.** La descarga desde `releases/latest/download/` no usa la API (sin el límite de peticiones), pero depende de la disponibilidad de GitHub.

## Pruebas

- `frontend/test/actualizaciones_test.dart`: versiones, validación del manifiesto, firma (incluye manifiesto alterado y otra clave), reglas de obligatoria/opcional/omitida/automática y el flujo completo con piezas falsas.
- `frontend/test/instalador_actualizaciones_test.dart`: descarga, archivo manipulado, tamaño incorrecto, reutilización y limpieza contra un servidor local.
- `frontend/test/guardia_actualizacion_test.dart`: el aviso opcional, la pantalla obligatoria, el avance y los errores.
