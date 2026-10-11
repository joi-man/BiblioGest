# 📚 BiblioGest - Sistema Multiplataforma de Gestión Bibliotecaria

Sistema multiplataforma (**Web, Windows Desktop y Android Mobile**) desarrollado para la gestión eficiente de materiales, usuarios, préstamos, devoluciones y control de disponibilidad en instituciones educativas.

---

## 🚀 Repositorio y Arquitectura

- **Repositorio GitHub:** [https://github.com/joi-man/BiblioGest](https://github.com/joi-man/BiblioGest)
- **Ramas Git:**
  - `main`: Entregables estables y producción.
  - `develop`: Rama principal de integración.
  - `feature/*`: Ramas de desarrollo por módulos.

---

## 🛠️ Stack Tecnológico

### Backend API & Base de Datos
- **Lenguaje:** Python `3.12.8`
- **Framework Web:** FastAPI `0.115.6`
- **Servidor ASGI:** Uvicorn `0.34.0`
- **ORM & Migraciones:** SQLAlchemy `2.0.36` / Alembic `1.14.0`
- **Base de Datos:** PostgreSQL `16.6`

### Frontend Multiplataforma
- **Framework:** Flutter SDK `3.27.x` (Web, Windows, Android)
- **Gestión de Estado:** `flutter_riverpod` `2.6.1`
- **Navegación:** `go_router` `14.7.0`
- **Cliente HTTP:** `dio` `5.7.0`

### Despliegue
- **Frontend Web:** Vercel (`flutter build web`)
- **Backend & BD:** Railway (FastAPI Docker + PostgreSQL Administrado)

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
python -m pytest                      # 70 pruebas, no necesitan base de datos
```

### 4. Frontend

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # modelos Freezed
flutter run -d chrome                 # personal de la biblioteca (web)
flutter test                          # 35 pruebas
```

Los estudiantes solo usan la app móvil. Para probar su vista en el navegador:
`flutter run -d chrome --dart-define=PERMITIR_ESTUDIANTE_EN_ESCRITORIO=true`.

---

## 📖 Documentación

| Documento | Contenido |
|---|---|
| [docs/prestamos-devoluciones.md](docs/prestamos-devoluciones.md) | Inventario, flujo de préstamos, devoluciones, reglas, multas y API |
| [docs/listados-paginados-exportacion.md](docs/listados-paginados-exportacion.md) | Grillas paginadas con búsqueda, filtros y exportación a Excel/PDF |
| [docs/diseno-sistema.md](docs/diseno-sistema.md) | Sistema de diseño (paleta, tipografía, modo oscuro, componentes) |
| [RECUPERACION_CONTRASENA.md](RECUPERACION_CONTRASENA.md) | Recuperación de contraseña por correo |

## 🏗️ Principios de código

- **Responsabilidad única:** cada archivo, clase y función hace una sola cosa (por ejemplo, `backend/app/servicios/prestamos/` tiene un módulo por tarea).
- **Comentarios y documentación en español**, y nombres que se entienden sin explicación.
- **Migraciones de base de datos con Alembic** para todo cambio de esquema.
