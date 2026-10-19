"""Entorno de pruebas de sincronizacion: un servidor central y uno o mas equipos locales.

Cada uno tiene su propia base SQLite en un archivo temporal, como en la realidad.
El equipo habla con el servidor mediante un cliente HTTP conectado a una app en memoria.
"""
from dataclasses import dataclass, field
from typing import Callable, Optional

from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core import compatibilidad_sqlite
from app.core.database import CLAVE_MODO_LOCAL, Base, obtener_db
from app.core.seguridad import crear_token_acceso, hashear_contrasena
from app.modelos import Usuario
from app.rutas import (
    auth,
    autores,
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
from app.sync.cliente_central import ClienteCentral
from app.sync.instancia import obtener_motor
from app.sync.motor import CredencialesCentrales, MotorSincronizacion

CLAVE_ADMIN = "Clave12345"


def crear_sesiones(ruta_archivo, modo_local: bool) -> sessionmaker:
    """Base SQLite en archivo, con las mismas opciones que usa la aplicacion."""
    motor = create_engine(f"sqlite:///{ruta_archivo}", connect_args={"check_same_thread": False})
    compatibilidad_sqlite.preparar_conexiones_sqlite(motor)
    Base.metadata.create_all(motor)
    return sessionmaker(
        bind=motor, autoflush=False, expire_on_commit=True, info={CLAVE_MODO_LOCAL: modo_local}
    )


def crear_app(sesiones: sessionmaker, *routers, motor=None) -> TestClient:
    app = FastAPI()
    if motor is not None:
        app.dependency_overrides[obtener_motor] = lambda: motor
    for router in routers:
        app.include_router(router.router)

    def _db():
        sesion = sesiones()
        try:
            yield sesion
        finally:
            sesion.close()

    app.dependency_overrides[obtener_db] = _db
    return TestClient(app)


def crear_usuario(db: Session, username: str, rol: str, documento: str) -> Usuario:
    usuario = Usuario(
        username=username,
        correo_electronico=f"{username}@prueba.com",
        contrasena_hash=hashear_contrasena(CLAVE_ADMIN),
        numero_documento=documento,
        nombre=username.capitalize(),
        apellido="Prueba",
        rol=rol,
        activo=True,
    )
    db.add(usuario)
    db.commit()
    return usuario


def cabeceras(usuario: Usuario) -> dict:
    token = crear_token_acceso({"sub": str(usuario.id), "rol": usuario.rol})
    return {"Authorization": f"Bearer {token}"}


@dataclass
class Servidor:
    sesiones: sessionmaker
    http: TestClient

    def sesion(self) -> Session:
        return self.sesiones()


@dataclass
class Equipo:
    """Un ejecutable de escritorio: base local, API local y motor de sincronizacion."""

    sesiones: sessionmaker
    http: TestClient
    motor: MotorSincronizacion
    credenciales: CredencialesCentrales = field(default_factory=CredencialesCentrales)

    def sesion(self) -> Session:
        return self.sesiones()


def crear_servidor(tmp_path) -> Servidor:
    sesiones = crear_sesiones(tmp_path / "central.db", modo_local=False)
    return Servidor(sesiones, crear_app(sesiones, auth, sync, materiales, usuarios, categorias, prestamos, solicitudes, devoluciones, dashboard))


def crear_equipo(tmp_path, nombre: str, servidor: Servidor, url: Optional[str] = "http://central") -> Equipo:
    from app.sync import estado_local

    sesiones = crear_sesiones(tmp_path / f"{nombre}.db", modo_local=True)
    credenciales = CredencialesCentrales()
    fabrica: Callable[[str], ClienteCentral] = lambda _url: ClienteCentral(_url, http=servidor.http)
    motor = MotorSincronizacion(sesiones, credenciales, fabrica)
    http = crear_app(
        sesiones, auth, local, materiales, usuarios, categorias, prestamos, solicitudes, devoluciones, dashboard,
        motor=motor,
    )
    if url is not None:
        with sesiones() as db:
            estado_local.escribir(db, estado_local.CLAVE_SERVIDOR_URL, url)
    return Equipo(sesiones, http, motor, credenciales)
