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

## 💻 Inicio Rápido Backend

```bash
cd backend
python -m venv .venv
# En Windows PowerShell:
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --reload
```
