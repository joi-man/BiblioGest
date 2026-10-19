# Despliegue en la nube (Render, Neon y Vercel)

Cómo está publicado BiblioGest y cómo actualizarlo.

| Pieza | Servicio | Dirección | Cómo se actualiza |
|---|---|---|---|
| API (FastAPI) | **Render** (plan gratuito, Docker) | `https://bibliogest-6j8f.onrender.com` | **Automático** al subir a la rama `main` |
| Base de datos | **Neon** (PostgreSQL) | — | Migraciones con Alembic (`EJECUTAR_MIGRACIONES=1`) |
| Web (Flutter) | **Vercel** (proyecto `bibliogest`) | `https://bibliogest-dusky.vercel.app` | **Manual**: el proyecto no está conectado a Git |
| Windows y Android | **GitHub Releases** (`joi-man/BiblioGest-releases`) | — | Manual, con los scripts de `scripts/` |

## Render (API)

Se redespliega solo cada vez que se sube a `main`. La construcción y las variables están en el `Dockerfile` y en el panel de Render.

Variables de entorno principales:

| Variable | Para qué |
|---|---|
| `BASE_DATOS_URL` | Conexión a Neon |
| `SECRETO_JWT` | Firma de las sesiones (obligatoria y secreta) |
| `ORIGENES_PERMITIDOS` | Dominio de la web, para CORS |
| `EJECUTAR_MIGRACIONES` | `1` aplica Alembic al arrancar |
| `SMTP_HOST`, `SMTP_PUERTO`, `SMTP_USUARIO`, `SMTP_CLAVE`, `SMTP_REMITENTE` | Envío de correos (ver abajo) |

### Correo: el plan gratuito de Render bloquea Gmail

Render gratuito **bloquea las conexiones SMTP salientes en los puertos 25, 465 y 587**. Con Gmail el envío falla con `OSError: [Errno 101] Network is unreachable`. Se resolvió usando **Brevo** (gratis, 300 correos al día) por el **puerto 2525**:

| Variable | Valor |
|---|---|
| `SMTP_HOST` | `smtp-relay.brevo.com` |
| `SMTP_PUERTO` | `2525` |
| `SMTP_USUARIO` | el *login SMTP* de Brevo (SMTP & API → SMTP; tiene la forma `algo@smtp-brevo.com`) |
| `SMTP_CLAVE` | la clave SMTP generada en Brevo |
| `SMTP_REMITENTE` | el remitente verificado en Brevo |

Brevo muestra un aviso de DKIM para remitentes `@gmail.com`: no impide enviar, pero esos correos pueden caer en Spam. Para que lleguen siempre a la bandeja principal hace falta un dominio propio autenticado. Los logs de Render registran cada envío (`Correo enviado a ...` o `Error enviando correo a ...`).

## Neon (base de datos)

PostgreSQL administrado. Las tablas las crea `create_all` al arrancar y los cambios de columnas se aplican con Alembic (`EJECUTAR_MIGRACIONES=1`). Ver "Migraciones" en [prestamos-devoluciones.md](prestamos-devoluciones.md).

## Vercel (web)

El proyecto `bibliogest` **no se actualiza al subir a Git**: Vercel no puede compilar Flutter, y el proyecto se publica con archivos ya compilados. Para publicar una versión nueva de la web, desde la carpeta `frontend`:

```powershell
flutter build web --release --dart-define=API_URL=https://bibliogest-6j8f.onrender.com
copy web\vercel.json build\web\
cd build\web
vercel link --project bibliogest --yes     # solo la primera vez en cada equipo
vercel deploy --prod --yes
```

> **Enlaza siempre antes de publicar.** `vercel link --project bibliogest --yes` guarda el enlace dentro de `build\web`, que se borra al limpiar la compilación. Si se publica sin enlace, Vercel **crea un proyecto nuevo** (con otro nombre y otra dirección) en lugar de actualizar `bibliogest`.

Requiere la CLI de Vercel con la sesión iniciada (`vercel login`). `web/vercel.json` hace que cualquier ruta (por ejemplo `/login`) cargue la aplicación. Para automatizarlo habría que conectar el repositorio a Vercel y compilar con GitHub Actions.

## Windows y Android

Se construyen y publican a mano, en **un solo Release por versión** con los archivos de las dos plataformas:

- Windows: `scripts/construir_ejecutable.ps1` (ver [ejecutable-offline.md](ejecutable-offline.md) y [actualizaciones.md](actualizaciones.md)).
- Android: `scripts/construir_apk.ps1 -ApiUrl https://bibliogest-6j8f.onrender.com` (ver [app-movil.md](app-movil.md)).

## Orden recomendado al publicar una versión

1. Subir el código a `main` → **Render** se redespliega (esperar a "Your service is live").
2. Publicar la web en **Vercel** (comandos de arriba).
3. Construir el instalador de Windows y el APK, y subir los 8 archivos al Release `v<versión>`.

El backend va primero: la web y las apps nuevas usan rutas que el backend viejo no tiene.

## Limitaciones del plan gratuito

- **Render duerme** tras un rato sin uso: la primera petición puede tardar cerca de un minuto. La app móvil lo trata como un corte de conexión y reintenta sola.
- **Sin SMTP estándar** (puertos 25/465/587): hay que usar un servicio de correo por el 2525.
- **Neon gratuito** suspende la base tras un tiempo sin actividad; la primera consulta tarda un poco más.
