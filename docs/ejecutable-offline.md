# Ejecutable de escritorio (offline y sincronización)

BiblioGest para Windows es casi la misma aplicación que la web, pero **no depende de internet**: guarda los datos en el propio equipo, sigue funcionando si se corta la conexión y sincroniza solo cuando vuelve. También sirve en una red privada sin internet o en un único equipo aislado.

## Modos de uso

| Modo | Para qué | Cómo se configura |
|---|---|---|
| **Solo en este equipo** | Una biblioteca con una sola computadora, sin red ni internet | Primer inicio → "Usar solo en este equipo" → se crea el administrador |
| **Con servidor (internet)** | Varios equipos + la versión web comparten los datos | Primer inicio → "Conectar con un servidor" → `https://mi-servidor` |
| **Con servidor (red privada)** | Varios equipos en una LAN sin internet | Igual, con la IP del servidor: `http://192.168.1.10:8000` |

El servidor es el mismo backend de siempre (FastAPI + PostgreSQL, ver README). En una LAN se instala en una PC con Docker y los equipos apuntan a su IP.

Un administrador puede cambiar de modo después desde **Sincronización** (menú lateral). Al unir un equipo que ya tiene datos propios a un servidor, esos datos se **reemplazan** por los del servidor (se pide confirmación).

## Cómo funciona

```
┌──────────────── Equipo (BiblioGest.exe) ───────────────┐          ┌──── Servidor central ────┐
│  Flutter  ──HTTP──>  backend local (SQLite)            │          │  FastAPI + PostgreSQL    │
│  (misma UI)          ├─ reglas de préstamos (las mismas)│  lotes   │                          │
│                      ├─ bandeja de salida (sync_lotes) ─┼────────> │  /api/sync/lotes         │
│                      └─ motor de sincronización  <──────┼───────── │  /api/sync/cambios       │
└────────────────────────────────────────────────────────┘ cambios   └──────────────────────────┘
```

- La aplicación inicia su propio backend (`backend\bibliogest-backend.exe`, el mismo código Python empaquetado) y habla con él en `127.0.0.1`. Por eso **todas las reglas** (plazos, límites, estados, multas opcionales) son idénticas a las de la web y funcionan sin conexión.
- Los datos están en `%LOCALAPPDATA%\BiblioGest\bibliogest.db` (SQLite). No se borran al desinstalar ni al actualizar.
- Si la aplicación se cierra o falla, su backend se cierra con ella.

### Sincronización

1. **Captura.** Cada transacción local se guarda como un **lote** en la bandeja de salida, en la misma transacción del cambio (si se deshace, el lote también). No hay que tocar los servicios: se engancha a SQLAlchemy (`app/sync/captura.py`).
2. **Versiones.** Las 6 tablas replicadas (usuarios, categorías, materiales, préstamos, items y devoluciones) tienen `version`, que sube con cada cambio, y `fecha_actualizacion`. Un cambio local viaja con la versión sobre la que se basó.
3. **Envío.** Cada lote se aplica en el servidor **completo o no se aplica**. Se acepta solo si todas las filas siguen en la versión esperada. Es idempotente (un reintento no duplica) y respeta los permisos por rol (por ejemplo, solo un administrador puede enviar cambios de usuarios o categorías).
4. **Descarga.** Después se bajan los cambios del servidor por `fecha_actualizacion` (con un margen de 5 min para no perder escrituras en vuelo). Una fila con cambios locales sin aceptar **no se pisa**.
5. **Cuándo.** Solo cada 30 s mientras el programa está abierto y hay alguien con sesión iniciada, o al pulsar "Sincronizar ahora". Las credenciales para hablar con el servidor son las de quien inició sesión y viven **solo en memoria**.

### Conflictos

Ejemplo: dos equipos sin conexión prestan el mismo proyector. El primero que sincroniza gana; el lote del segundo se rechaza completo ("Material cambió en el servidor…") y aparece en **Sincronización → Cambios por revisar**, con dos opciones:

- **Reintentar**: vuelve a la bandeja de salida (útil si el problema ya se arregló).
- **Descartar mis cambios**: se deshace lo hecho sin conexión (los registros que solo existían en este equipo se eliminan, el resto se reemplaza por la versión del servidor). Requiere conexión. También descarta los cambios posteriores que dependían de ese.

Los cambios automáticos del sistema (por ejemplo, marcar un préstamo como vencido) que choquen se descartan solos y se baja la versión del servidor: no hay nada que decidir.

### Seguridad

- El backend local escucha solo en `127.0.0.1` y sus sesiones se firman con un secreto propio del equipo (`secreto.txt`, generado en el primer inicio).
- Al equipo solo se replican las contraseñas (hash) del **personal**; las de los estudiantes no salen del servidor. Los estudiantes no usan el ejecutable.
- La base local contiene datos de la biblioteca sin cifrar: conviene proteger la cuenta de Windows (o cifrar el disco con BitLocker).
- Enviar cambios por sincronización salta las reglas de las rutas, por eso el servidor repite las de permisos (`app/sync/tablas.py`).

## Construir el instalador

Requisitos, **una sola vez**:

1. **Modo desarrollador de Windows** activado: `start ms-settings:developers` (Flutter lo necesita para enlazar los plugins).
2. **Visual Studio Build Tools** con la carga de trabajo *Desarrollo para el escritorio con C++* (Visual Studio Installer → Modificar). Se comprueba con `flutter doctor`.
   - **Visual Studio 2026 necesita Flutter 3.4x o más nuevo.** Con Flutter 3.32 falla con `Generator Visual Studio 16 2019 could not find any instance of Visual Studio`. Solución sin tocar tu Flutter global: `git clone --depth 1 -b stable https://github.com/flutter/flutter.git C:lutter_bibliogest` y pasar `-Flutter C:lutter_bibliogestinlutter.bat` al script. Si el error `Does not match the generator used previously` aparece, borra `frontenduild\windows`.
3. **Inno Setup 6**: `winget install JRSoftware.InnoSetup`.
4. Entorno del backend: `cd backend; python -m venv .venv; .\.venv\Scripts\pip install -r requirements.txt`.

Luego:

```powershell
.\scripts\construir_ejecutable.ps1 -Version 0.9.0 [-Flutter C:lutter_bibliogestinlutter.bat]
# -> build\instalador\BiblioGest-Setup-0.9.0.exe
```

El script empaqueta el backend con PyInstaller, compila Flutter para Windows, copia el backend dentro de la aplicación y genera el instalador (`instalador\bibliogest.iss`). El instalador no pide permisos de administrador: instala en `%LOCALAPPDATA%\Programs\BiblioGest`.

Para probar el backend empaquetado sin compilar Flutter: `.\scripts\construir_ejecutable.ps1 -SoloBackend`.

### Desarrollo

- `flutter run -d windows` **sin** `backend\bibliogest-backend.exe` usa el servidor de `ApiConstants.baseUrl`, como la web.
- Para usar el backend empaquetado: `--dart-define=BACKEND_LOCAL_EXE=C:\ruta\bibliogest-backend.exe`.
- Backend local a mano: `cd backend; python local_main.py --datos C:\temp\datos --puerto 8766 --sin-vigilar-padre`.

## Servidor central

Después de actualizar el código del servidor:

```bash
docker compose up -d --build backend
docker compose exec backend python -m alembic upgrade head   # agrega version/fecha_actualizacion
```

## Limitaciones conocidas

- **Esquema SQLite:** el ejecutable crea sus tablas con `create_all`. Un cambio futuro de columnas necesitará una migración propia para los equipos ya instalados (las migraciones de Alembic actuales son de PostgreSQL).
- **Recuperación de contraseña por correo** necesita internet y servidor; en el ejecutable no está disponible.
- **Un lote se pierde** solo si el equipo se apaga justo entre confirmar un cambio y guardarlo en la bandeja; es la misma transacción, así que en la práctica no ocurre.
- **Reglas entre equipos:** el servidor impide que dos equipos presten la *misma unidad*, pero no compara reglas globales como "máximo 3 préstamos por persona" entre lotes de equipos distintos.
- **Estudiantes:** siguen usando solo la app móvil; no pueden iniciar sesión en el ejecutable.
- El ejecutable usa el ícono por defecto de Flutter hasta que se diseñe uno propio.

## Pruebas

- Backend: `backend/tests/test_sincronizacion.py` (captura, envío, descarga, conflictos, permisos, idempotencia, sin conexión) y `test_equipo_local.py` (configuración, conexión a un servidor, modo solo local).
- Frontend: `frontend/test/modo_local_test.dart`; `backend_local_test.dart` prueba el arranque del backend real si se define `BACKEND_LOCAL_EXE`.
- Verificado a mano contra PostgreSQL real: edición y préstamo con el servidor detenido, y sincronización al volver.
