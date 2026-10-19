# 📚 BiblioGest - Sistema Multiplataforma de Gestión Bibliotecaria

Sistema multiplataforma (**Web, Windows Desktop y Android Mobile**) desarrollado para la gestión eficiente de materiales, usuarios, préstamos, devoluciones y control de disponibilidad en instituciones educativas.

---

## 🚀 Repositorio y Arquitectura

- **Repositorio GitHub:** [https://github.com/joi-man/BiblioGest](https://github.com/joi-man/BiblioGest)
- **Ramas Git:**
  - `main`: Producción (Render se redespliega al cambiar). Solo recibe versiones desde `develop`.
  - `develop`: Rama por defecto e integración; los Pull Requests apuntan aquí.
  - `feature/*`, `fix/*`, `docs/*`: Ramas de trabajo que salen de `develop`.
  - Versiones `vX.Y.Z` etiquetadas en `main`. Ver [docs/versionado.md](docs/versionado.md).
- **Versión actual:** 0.17.0

---

## 🛠️ Stack Tecnológico

### Backend API & Base de Datos
- **Lenguaje:** Python `3.12.8`
- **Framework Web:** FastAPI `0.115.6`
- **Servidor ASGI:** Uvicorn `0.34.0`
- **ORM & Migraciones:** SQLAlchemy `2.0.36` / Alembic `1.14.0`
- **Base de Datos:** PostgreSQL `16.6`

### Frontend Multiplataforma
- **Framework:** Flutter SDK `3.47.x` (Web, Windows, Android)
- **Gestión de Estado:** `flutter_riverpod` `2.6.1`
- **Navegación:** `go_router` `14.7.0`
- **Cliente HTTP:** `dio` `5.7.0`

### Despliegue
- **Frontend Web:** Vercel (`flutter build web`)
- **Backend:** Render (FastAPI Docker) · **BD:** Neon (PostgreSQL administrado). Ver [docs/despliegue.md](docs/despliegue.md)

---

## 👥 Equipo y Distribución de Roles (6 Integrantes)

1. **Arquitecto de Software:** Definición de arquitectura, patrones de diseño y flujo Git.
2. **Desarrollador Backend & BD:** API REST en FastAPI y modelo E-R en PostgreSQL.
3. **Desarrollador Frontend:** Interfaz de usuario adaptativa en Flutter para Web, Windows y Android.
4. **Diseñador UX/UI:** Sistema de diseño (Material 3), prototipado y experiencia multiplataforma.
5. **Documentador:** Mantenimiento de especificaciones técnicas, diccionario de datos y guías.
6. **Tester (QA):** Plan de pruebas, criterios de aceptación y calidad de software.

---

## 📌 Módulos Iniciales

- **Inicio de Sesión y Usuarios:** Autenticación por roles.
- **Registro de Libros/Materiales:** Código, título, autor, categoría y estado.
- **Registro de Préstamos:** Usuario, fecha de préstamo y fecha estimada de devolución.
- **Estados:** `Disponible`, `Prestado`, `Vencido` y `Fuera de servicio`.
- **Registro de Devolución:** Control de fechas y actualización de estados.
- **Búsqueda y Filtros:** Por título, categoría, estado o usuario.
- **Historial:** Traza de préstamos por material.
- **Dashboard:** Métricas e indicadores globales.

---

## 💻 Inicio Rápido

### 1. Configuración

```bash
cp backend/.env.example backend/.env    # luego edita backend/.env con tus valores
```

`backend/.env` **nunca se sube a git**. Para el envío de correos (recuperación de contraseña) se necesita una cuenta Gmail con una *contraseña de aplicación*; ver [RECUPERACION_CONTRASENA.md](RECUPERACION_CONTRASENA.md).

### 2. Backend y base de datos (Docker)

```bash
docker compose up -d --build          # PostgreSQL, pgAdmin y API en http://localhost:8000
docker compose exec backend python -m alembic upgrade head   # aplica las migraciones
python backend/scripts/crear_datos_prueba.py                 # categorías, libros y equipos de ejemplo
```

La documentación interactiva de la API está en <http://localhost:8000/docs>.

> **Puerto 5433:** PostgreSQL de Docker se publica en el puerto `5433`. Si tienes otro PostgreSQL instalado en Windows que use ese mismo puerto, las herramientas que se conecten a `localhost:5433` hablarán con *ese* servidor y rechazarán la clave. Cambia el puerto publicado en `docker-compose.yml` (por ejemplo `5434:5432`) o detén el otro servicio.

> **Migraciones:** el backend ejecuta `create_all` al arrancar, que crea tablas nuevas pero **no** agrega columnas a tablas existentes. Tras actualizar el código ejecuta siempre `alembic upgrade head`. Si Alembic dice que una tabla ya existe, márcala como aplicada con `alembic stamp head`.

### 3. Backend sin Docker (solo desarrollo y pruebas)

```bash
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1          # Windows PowerShell
pip install -r requirements.txt
python -m pytest                      # pruebas sin base de datos (SQLite en memoria)
```

### 4. Frontend

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # modelos Freezed (ver nota abajo si se cuelga)
flutter run -d chrome                 # personal de la biblioteca (web)
flutter test
```

> **`build_runner` se cuelga con Flutter 3.47:** el analizador (`analyzer 7.6.0`) no lee el código fuente de ese Flutter. Los archivos generados (`*.freezed.dart`, `*.g.dart`) están versionados, así que solo hace falta regenerarlos al cambiar un modelo. Para hacerlo, usa un Flutter anterior (por ejemplo 3.35.x: `git clone -b 3.35.7 https://github.com/flutter/flutter C:lutter_3_35`) en una copia temporal del proyecto, ejecuta allí `dart run build_runner build --delete-conflicting-outputs` y copia de vuelta solo los archivos generados de los modelos que cambiaste. Subir `build_runner` y `freezed` a sus versiones actuales exige reescribir todos los modelos (freezed 3 y 4 cambian la sintaxis).

Los estudiantes solo usan la app móvil. Para probar su vista en el navegador:
`flutter run -d chrome --dart-define=PERMITIR_ESTUDIANTE_EN_ESCRITORIO=true`.

### 5. Ejecutable de Windows

```powershell
.\scripts\construir_ejecutable.ps1 -Version 0.9.0    # -> build\instalador\BiblioGest-Setup-0.9.0.exe
```

Funciona sin internet, solo en el equipo o conectado a un servidor (internet o red privada). Requisitos y funcionamiento en [docs/ejecutable-offline.md](docs/ejecutable-offline.md).

### 6. App de Android

```powershell
.\scripts\crear_keystore.ps1                                          # una sola vez: clave de firma
.\scripts\construir_apk.ps1 -ApiUrl https://tu-api.onrender.com      # -> build\apk\BiblioGest-<version>.apk
```

Es la app de los estudiantes (catálogo de libros y revistas, reservas): funciona conectada al servidor, se actualiza desde la propia app y se descarga desde la página de inicio de sesión de la web. Requisitos y funcionamiento en [docs/app-movil.md](docs/app-movil.md).

---

## 📖 Documentación

| Documento | Contenido |
|---|---|
| [docs/prestamos-devoluciones.md](docs/prestamos-devoluciones.md) | Inventario, flujo de préstamos, devoluciones, reglas, multas y API |
| [docs/autores-y-ejemplares.md](docs/autores-y-ejemplares.md) | Autores (varios por libro y viceversa), cantidad de ejemplares y reservas coherentes, tomos y búsqueda por palabras |
| [docs/listados-paginados-exportacion.md](docs/listados-paginados-exportacion.md) | Grillas paginadas con búsqueda, filtros y exportación a Excel/PDF |
| [docs/ejecutable-offline.md](docs/ejecutable-offline.md) | Ejecutable de Windows: modo offline, sincronización, red privada e instalador |
| [docs/reportes.md](docs/reportes.md) | Reportes de préstamos, vencidos por rango de fechas (RFC-G1) y devoluciones, con exportación a CSV, Excel y PDF |
| [docs/despliegue.md](docs/despliegue.md) | Render, Neon y Vercel: cómo se publica, correo con Brevo y orden de despliegue |
| [docs/app-movil.md](docs/app-movil.md) | App de Android para estudiantes: reservas, cesión, avisos, reconexión, catálogo sin conexión, firma y distribución |
| [docs/actualizaciones.md](docs/actualizaciones.md) | Actualizaciones desde la propia app (Windows y Android) y cómo publicar una versión |
| [docs/versionado.md](docs/versionado.md) | Ramas, commits, numeración de versiones, etiquetas y cómo publicar una versión |
| [docs/iconos.md](docs/iconos.md) | Iconos de todas las plataformas y cómo regenerarlos |
| [docs/diseno-sistema.md](docs/diseno-sistema.md) | Sistema de diseño (paleta, tipografía, modo oscuro, componentes) |
| [RECUPERACION_CONTRASENA.md](RECUPERACION_CONTRASENA.md) | Recuperación de contraseña por correo |

## 🏗️ Principios de código

- **Responsabilidad única:** cada archivo, clase y función hace una sola cosa (por ejemplo, `backend/app/servicios/prestamos/` tiene un módulo por tarea).
- **Comentarios y documentación en español**, y nombres que se entienden sin explicación.
- **Migraciones de base de datos con Alembic** para todo cambio de esquema.
