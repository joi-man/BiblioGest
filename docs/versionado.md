# Versionado y flujo de Git

Cómo se ramifica, se nombra y se publica el trabajo en GitHub (`joi-man/BiblioGest`).

## Ramas

| Rama | Para qué | Quién escribe en ella |
|---|---|---|
| `develop` | Integración. Es la rama **por defecto** del repositorio: todos los Pull Requests apuntan aquí. | Solo por Pull Request |
| `main` | Producción. **Render se redespliega solo** cada vez que cambia (ver [despliegue.md](despliegue.md)). | Solo desde `develop`, al publicar una versión |
| `feature/*` | Funcionalidad nueva (`feature/reportes`). | Quien la desarrolla |
| `fix/*` | Corrección de un error (`fix/log-correo`). | Quien la corrige |
| `docs/*` | Cambios solo de documentación (`docs/smtp-render`). | Quien la escribe |

Las ramas salen de `develop` y vuelven a `develop`. Se borran después de fusionarse.

## Flujo de un cambio

1. `git switch develop && git pull` y crear la rama: `git switch -c feature/<nombre>`.
2. Commits pequeños con el formato de abajo.
3. Subir la rama y abrir un Pull Request **hacia `develop`**.
4. Fusionar con *merge commit* (así se conserva el historial `Merge pull request #N`).

## Mensajes de commit

`tipo: descripción en español`, en minúsculas y sin punto final. Tipos: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`. Con alcance opcional: `fix(backend): ...`. El commit que sube la versión lleva `(vX.Y.Z)` al final.

## Numeración de versiones (SemVer)

`MAYOR.MENOR.PARCHE`, por ejemplo `0.13.0`:

- **PARCHE** (`0.13.1`): correcciones sin funcionalidad nueva.
- **MENOR** (`0.14.0`): funcionalidad nueva compatible.
- **MAYOR**: cambio incompatible (el proyecto sigue en `0.x`, antes de la `1.0.0`).

**Fuente de verdad:** `version:` en `frontend/pubspec.yaml` (`0.13.0+11`: el número tras `+` es el código de compilación de Android y **sube en 1 con cada versión**). El backend no tiene número propio. Los scripts de instalador y APK reciben la misma versión (`-Version`).

La versión se sube **en el mismo Pull Request** que trae el cambio, no después.

## Publicar una versión

1. Con `develop` al día y probado, subir `pubspec.yaml` y anotarlo en [progreso.md](progreso.md).
2. Llevar `develop` a `main`: `git switch main && git merge --ff-only develop && git push`. Render se redespliega.
3. Etiquetar ese commit y subir la etiqueta:
   ```bash
   git tag -a v0.13.0 -m "BiblioGest 0.13.0"
   git push origin v0.13.0
   ```
4. Seguir el orden de [despliegue.md](despliegue.md) (web en Vercel, instalador y APK en el Release `v<versión>` del repositorio `BiblioGest-releases`).

La etiqueta `v<versión>` es la misma en este repositorio y en el de releases.

## Versiones publicadas

Cada etiqueta apunta al commit que mejor representa esa versión. Hasta la 0.9 el código no llevaba número de versión (`pubspec.yaml` decía `1.0.0+1`), por eso las etiquetas de los hitos se asignaron a posteriori.

| Etiqueta | Commit | Fecha | Contenido |
|---|---|---|---|
| `v0.1.0` | `edaf055` | 2026-09-14 | Línea base: repositorio, API, base de datos y prototipo Flutter con inicio de sesión |
| `v0.5.0` | `389819f` | 2026-10-11 | MVP: usuarios, materiales, préstamos, devoluciones, búsqueda y filtros |
| `v0.9.0` | `5b471dd` | 2026-10-11 | Ejecutable de Windows con modo sin conexión y sincronización |
| `v0.10.0` | `61b468f` | 2026-10-11 | Actualizaciones desde la propia aplicación |
| `v0.10.1` a `v0.10.5` | `ea92398`, `46749da`, `3a1eed4`, `31ec49d`, `0dee923` | 2026-10-11 | Ajustes del ejecutable (cierre de sesión, recuperación de contraseña, arranque) |
| `v0.11.0` | `5ba9855` | 2026-10-12 | App móvil de Android para estudiantes |
| `v0.11.1` | `4c0f8b4` | 2026-10-12 | Versión móvil reducida para el personal |
| `v0.12.0` | `28f700a` | 2026-10-12 | Reportes y despliegue en la nube |
| `v0.12.1` | `82c6ccb` | 2026-10-12 | El personal ve solicitudes nuevas sin cerrar sesión |
| `v0.13.0` | `07ecaa1` | 2026-10-12 | Sesión en el navegador, suspensión de usuarios y hora de Paraguay |
| `v0.14.0` | `d6843a7` | 2026-10-19 | Autores, ejemplares por material, tomos y búsqueda mejorada |
| `v0.15.0` | `8876ab9` | 2026-10-19 | Fecha y hora de devolución elegibles al prestar, entregar y ceder |
| `v0.16.0` | `b126d61` | 2026-10-19 | Fecha y hora reales de la devolución, con motivo y auditoría |
| `v0.17.0` | (al publicar) | 2026-10-19 | Fecha y hora de retiro que propone el estudiante al reservar |

## Qué no se versiona

`backend/.env`, `credenciales.txt`, `frontend/android/key.properties`, el keystore y la clave privada de actualizaciones. Ver `.gitignore`.
