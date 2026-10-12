import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import configuracion
from app.core.database import SesionLocal, engine, Base, es_modo_local
from app.rutas import (
    auth,
    categorias,
    dashboard,
    devoluciones,
    local,
    materiales,
    prestamos,
    solicitudes,
    sync,
    usuarios,
)

# Los registros INFO de la aplicacion (por ejemplo, correos enviados) deben verse en los
# logs del servidor; por defecto Python solo muestra los de nivel WARNING.
logging.getLogger("app").setLevel(logging.INFO)
if not logging.getLogger().handlers:
    logging.basicConfig(format="%(levelname)s:     %(name)s - %(message)s")

# Crear tablas en la base de datos
Base.metadata.create_all(bind=engine)


@asynccontextmanager
async def ciclo_de_vida(_app: FastAPI):
    """En el ejecutable de escritorio, sincroniza solo mientras el programa esta abierto."""
    detener = None
    if es_modo_local():
        from app.sync.bucle import iniciar_bucle
        from app.sync.instancia import motor

        detener = iniciar_bucle(motor, SesionLocal)
    yield
    if detener is not None:
        detener.set()


app = FastAPI(
    title="BiblioGest API",
    description="API REST para el Sistema Multiplataforma de Gestion Bibliotecaria BiblioGest",
    version="1.0.0",
    lifespan=ciclo_de_vida,
)

# Configuracion CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in configuracion.ORIGENES_PERMITIDOS.split(",") if o.strip()],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registrar rutas
app.include_router(auth.router)
app.include_router(usuarios.router)
app.include_router(materiales.router)
app.include_router(categorias.router)
app.include_router(solicitudes.router)
app.include_router(prestamos.router)
app.include_router(devoluciones.router)
app.include_router(dashboard.router)
app.include_router(sync.router)

# Solo el ejecutable de escritorio tiene configuracion y sincronizacion propias.
if es_modo_local():
    app.include_router(local.router)


@app.get("/", tags=["Salud"])
async def root():
    return {
        "estado": "online",
        "sistema": "BiblioGest API",
        "version": "1.0.0",
        "modo": "local" if es_modo_local() else "central",
    }


@app.get("/health", tags=["Salud"])
async def health_check():
    return {"estado": "ok"}
