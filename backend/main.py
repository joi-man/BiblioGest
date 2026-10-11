from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.rutas import (
    auth,
    categorias,
    dashboard,
    devoluciones,
    materiales,
    prestamos,
    solicitudes,
    usuarios,
)

# Crear tablas en la base de datos
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="BiblioGest API",
    description="API REST para el Sistema Multiplataforma de Gestion Bibliotecaria BiblioGest",
    version="1.0.0",
)

# Configuracion CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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


@app.get("/", tags=["Salud"])
async def root():
    return {
        "estado": "online",
        "sistema": "BiblioGest API",
        "version": "1.0.0",
    }


@app.get("/health", tags=["Salud"])
async def health_check():
    return {"estado": "ok"}
