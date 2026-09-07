# BiblioGest - Frontend Flutter Multiplataforma

Aplicación cliente para **Web, Windows Desktop y Android Mobile**.

## Stack
- **Flutter SDK:** 3.27.x
- **Gestión de Estado:** `flutter_riverpod` (2.6.1)
- **Navegación:** `go_router` (14.7.0)
- **Cliente HTTP:** `dio` (5.7.0)

## Arquitectura (Feature-First)
```
lib/
├── app/                  # Configuraciones globales, rutas y temas
├── core/                 # Componentes reutilizables, utilidades y red
└── features/             # Módulos del sistema
    ├── auth/             # Login y gestión de usuarios
    ├── materials/        # Registro y catálogo de libros/materiales
    ├── loans/            # Registro de préstamos y devoluciones
    └── dashboard/        # Indicadores y métricas
```
