# Recuperación de contraseña por correo

Permite que un usuario restablezca su contraseña recibiendo un **código de 6 dígitos** en su correo. El envío usa **Gmail SMTP** (gratis, sin dependencias nuevas: solo `smtplib` de la biblioteca estándar).

## Flujo

1. En el login, el usuario pulsa **¿Olvidaste tu contrasena?** (`/forgot-password`) e ingresa su correo.
2. El backend genera un código de 6 dígitos y lo envía por correo.
3. La app pasa a `/reset-password`: el usuario ingresa correo, código y nueva contraseña.
4. El backend valida el código y actualiza la contraseña. El usuario vuelve al login.

## API

| Método | Ruta | Cuerpo | Respuesta |
|---|---|---|---|
| POST | `/api/auth/olvide-contrasena` | `{ "correo": "..." }` | `200` siempre, con el mismo mensaje |
| POST | `/api/auth/restablecer-contrasena` | `{ "correo", "codigo", "nueva_contrasena" }` | `200` si es correcto, `400` "Codigo invalido o expirado" |

Validaciones: `codigo` son exactamente 6 dígitos; `nueva_contrasena` mínimo 6 caracteres.

## Reglas de seguridad

- **No revela qué correos existen:** `olvide-contrasena` responde igual exista o no la cuenta (si no existe, simplemente no envía nada).
- El código se guarda **hasheado** (bcrypt, igual que las contraseñas), nunca en texto plano.
- **Vence a los 15 minutos** (`CODIGO_RESET_EXPIRACION_MINUTOS`).
- **Un solo uso:** al restablecer queda marcado como usado.
- **Máximo 5 intentos fallidos** (`CODIGO_RESET_MAX_INTENTOS`); después el código deja de servir.
- Pedir un código nuevo **invalida los anteriores**.
- Solo aplica a usuarios activos y no eliminados.
- Se registra en la bitácora: `PASSWORD_RESET_REQUEST` y `PASSWORD_RESET`.
- El correo se envía en segundo plano (`BackgroundTasks`) para no bloquear la respuesta.

## Configuración

Variables en `backend/.env` (hay una plantilla en `backend/.env.example`):

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `SMTP_HOST` | `smtp.gmail.com` | Servidor SMTP |
| `SMTP_PUERTO` | `587` | Puerto (STARTTLS) |
| `SMTP_USUARIO` | — | Cuenta Gmail que envía |
| `SMTP_CLAVE` | — | **Contraseña de aplicación** de Gmail (no la contraseña normal) |
| `SMTP_REMITENTE` | `SMTP_USUARIO` | Dirección que aparece como remitente |
| `CODIGO_RESET_EXPIRACION_MINUTOS` | `15` | Vigencia del código |
| `CODIGO_RESET_MAX_INTENTOS` | `5` | Intentos permitidos |

### Obtener la contraseña de aplicación de Gmail

1. Activar la verificación en 2 pasos en la cuenta de Google.
2. Crear una contraseña de aplicación en <https://myaccount.google.com/apppasswords>.
3. Pegar los 16 caracteres en `SMTP_CLAVE` de `backend/.env`.

> **Nunca** subir `backend/.env` a git. `backend/.env.example` sí se versiona, así que debe contener solo valores de ejemplo, nunca credenciales reales. Si una clave se expone, revócala y crea otra.

Gmail gratuito permite unos 500 correos por día, suficiente para este uso.

## Base de datos

Tabla nueva `codigos_recuperacion`:

| Columna | Tipo | Nota |
|---|---|---|
| `id` | UUID | PK |
| `usuario_id` | UUID | FK → `usuarios.id`, indexado |
| `codigo_hash` | String(255) | Hash del código |
| `expira_en` | DateTime | UTC |
| `usado` | Boolean | |
| `intentos` | Integer | Fallos acumulados |
| `fecha_creacion` | DateTime | |

Migración: `backend/alembic/versions/2026_10_10_1200_add_codigos_recuperacion.py` (revisión `b2c3d4e5f6a7`, viene de `a1b2c3d4e5f6`).

`main.py` ejecuta `create_all` al arrancar, así que la tabla puede crearse sola. En ese caso la migración falla con "relation already exists"; ejecuta `alembic stamp head` para marcarla como aplicada.

## Archivos

**Backend** (`backend/`)
- `app/core/config.py` — variables SMTP y de recuperación.
- `app/modelos/codigo_recuperacion.py` — modelo (exportado en `app/modelos/__init__.py`).
- `app/servicios/email_servicio.py` — `enviar_correo(destino, asunto, cuerpo)`.
- `app/servicios/recuperacion_servicio.py` — `solicitar_codigo` y `restablecer_contrasena`.
- `app/esquemas/auth.py` — `OlvidoContrasenaRequest`, `RestablecerContrasenaRequest`, `MensajeRespuesta`.
- `app/rutas/auth.py` — los dos endpoints.

**Frontend** (`frontend/lib/`)
- `features/auth/presentation/screens/forgot_password_screen.dart` y `reset_password_screen.dart`.
- `features/auth/presentation/screens/login_screen.dart` — enlace "¿Olvidaste tu contrasena?".
- `features/auth/data/repositories/auth_repository.dart` — `solicitarRecuperacion` y `restablecerContrasena`.
- `app/router.dart` — rutas `/forgot-password` y `/reset-password`, públicas (sin sesión).
- `core/constants/api_constants.dart` — constantes de los endpoints.

**Infraestructura**
- `docker-compose.yml` — el servicio `backend` carga `./backend/.env` con `env_file`.
- `.gitignore` — excepción `!.env.example`.

## Cómo probarlo

1. Tener un usuario cuyo correo sea una bandeja a la que puedas acceder.
2. Desde la app: login → **¿Olvidaste tu contrasena?** → ingresar el correo → revisar la bandeja (y spam) → ingresar código y nueva contraseña.
3. O por API:

```bash
curl -X POST http://localhost:8000/api/auth/olvide-contrasena \
  -H "Content-Type: application/json" -d '{"correo":"usuario@ejemplo.com"}'

curl -X POST http://localhost:8000/api/auth/restablecer-contrasena \
  -H "Content-Type: application/json" \
  -d '{"correo":"usuario@ejemplo.com","codigo":"123456","nueva_contrasena":"NuevaClave456"}'
```

## Solución de problemas

- **No llega el correo:** si el correo no pertenece a ningún usuario activo, el backend responde 200 pero no envía nada (es intencional). Verifica también `SMTP_USUARIO`/`SMTP_CLAVE` y revisa `docker compose logs backend` en busca de errores de SMTP.
- **`localhost:5433` rechaza la clave:** otro PostgreSQL (por ejemplo, uno instalado en Windows) puede estar escuchando en el mismo puerto que Docker. Cambia el puerto publicado en `docker-compose.yml` o detén el otro servicio.
- **Aviso `error reading bcrypt version` en el log:** es un mensaje conocido de `passlib` con `bcrypt` 4.x; no afecta el funcionamiento.

## Pendiente

- No hay tests automatizados de pytest para este flujo (los modelos usan tipos de PostgreSQL, así que requieren una base real).
- Mejora posible: limitar la frecuencia de solicitudes por correo/IP para evitar spam de correos.
