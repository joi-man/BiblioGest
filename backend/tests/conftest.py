"""Fixtures compartidas por las pruebas.

Las pruebas usan SQLite en memoria para correr sin Docker. SQLite no soporta
bloqueo de filas ni el tipo JSONB, asi que se adapta lo minimo; el bloqueo
(`with_for_update`) se ignora y se valida aparte contra PostgreSQL.
"""
from datetime import datetime, timedelta

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core import reloj
from app.core.database import Base, obtener_db
from app.core.seguridad import crear_token_acceso, hashear_contrasena
from app.modelos import Categoria, Material, Usuario  # noqa: F401  (registra todos los modelos)
from app.rutas import auth, autores, categorias, dashboard, devoluciones, materiales, prestamos, reportes, solicitudes, usuarios


@compiles(JSONB, "sqlite")
def _jsonb_en_sqlite(elemento, compilador, **kw):
    """SQLite no tiene JSONB: se guarda como JSON."""
    return "JSON"


# Instante fijo para que las pruebas de plazos sean deterministas.
INSTANTE_BASE = datetime(2026, 10, 10, 12, 0, 0)


class RelojDePrueba:
    """Reloj controlable: permite avanzar el tiempo para probar vencimientos."""

    def __init__(self) -> None:
        self.actual = INSTANTE_BASE

    def avanzar(self, **kwargs) -> None:
        self.actual += timedelta(**kwargs)

    def __call__(self) -> datetime:
        return self.actual


@pytest.fixture()
def reloj_prueba(monkeypatch) -> RelojDePrueba:
    simulado = RelojDePrueba()
    monkeypatch.setattr(reloj, "ahora_utc", simulado)
    return simulado


@pytest.fixture()
def db():
    """Sesion sobre una base SQLite nueva para cada prueba."""
    motor = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(motor)
    sesion = sessionmaker(bind=motor, autoflush=False, expire_on_commit=True)()
    yield sesion
    sesion.close()
    motor.dispose()


@pytest.fixture()
def cliente(db, reloj_prueba):
    """Cliente HTTP contra una app con todas las rutas, usando la base de prueba."""
    app = FastAPI()
    for modulo in (auth, autores, categorias, dashboard, devoluciones, materiales, prestamos, reportes, solicitudes, usuarios):
        app.include_router(modulo.router)
    app.dependency_overrides[obtener_db] = lambda: db
    return TestClient(app)


def _crear_usuario(db, username: str, rol: str, documento: str) -> Usuario:
    usuario = Usuario(
        username=username,
        correo_electronico=f"{username}@prueba.com",
        contrasena_hash=hashear_contrasena("Clave12345"),
        numero_documento=documento,
        nombre=username.capitalize(),
        apellido="Prueba",
        rol=rol,
        activo=True,
    )
    db.add(usuario)
    db.commit()
    return usuario


@pytest.fixture()
def admin(db) -> Usuario:
    return _crear_usuario(db, "admin", "admin", "D-001")


@pytest.fixture()
def bibliotecario(db) -> Usuario:
    return _crear_usuario(db, "biblio", "bibliotecario", "D-002")


@pytest.fixture()
def estudiante(db) -> Usuario:
    return _crear_usuario(db, "ana", "estudiante", "D-003")


@pytest.fixture()
def otro_estudiante(db) -> Usuario:
    return _crear_usuario(db, "luis", "estudiante", "D-004")


def encabezados(usuario: Usuario) -> dict:
    """Cabecera Authorization con un token valido para el usuario."""
    token = crear_token_acceso({"sub": str(usuario.id), "rol": usuario.rol})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture()
def categoria_libros(db) -> Categoria:
    categoria = Categoria(nombre="Libros", plazo_prestamo_horas=168)
    db.add(categoria)
    db.commit()
    return categoria


@pytest.fixture()
def categoria_equipos(db) -> Categoria:
    categoria = Categoria(nombre="Equipos", plazo_prestamo_horas=4)
    db.add(categoria)
    db.commit()
    return categoria


@pytest.fixture()
def crear_material(db):
    """Fabrica de materiales: crear_material(categoria, codigo, **cambios)."""

    def _crear(categoria: Categoria, codigo: str, **cambios) -> Material:
        datos = dict(
            codigo=codigo,
            titulo=f"Material {codigo}",
            tipo_material="libro",
            categoria_id=categoria.id,
        )
        datos.update(cambios)
        # Un `estado` pedido se traduce al ejemplar (unico, salvo que se pida otra cantidad)
        # que esta en ese estado, igual que lo dejarian los prestamos reales.
        columna = {
            "reservado": "cantidad_reservada",
            "prestado": "cantidad_prestada",
            "vencido": "cantidad_vencida",
            "fuera_de_servicio": "cantidad_fuera_servicio",
        }.get(datos.get("estado"))
        if columna:
            datos[columna] = 1
        material = Material(**datos)
        db.add(material)
        db.commit()
        return material

    return _crear
