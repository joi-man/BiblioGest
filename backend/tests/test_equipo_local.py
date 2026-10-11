"""API propia del ejecutable: configuracion inicial, conexion a un servidor y conflictos."""
import pytest
from sqlalchemy import select

from app.core.config import configuracion
from app.modelos import Categoria, Material, Usuario
from tests.ayudas_sync import CLAVE_ADMIN, cabeceras, crear_equipo, crear_servidor, crear_usuario

DATOS_ADMIN = {
    "username": "bibliotecaria",
    "correo_electronico": "bib@escuela.edu",
    "numero_documento": "1234567",
    "nombre": "Marta",
    "apellido": "Gomez",
    "contrasena": "Segura123",
}


@pytest.fixture()
def servidor(tmp_path):
    servidor = crear_servidor(tmp_path)
    with servidor.sesion() as db:
        crear_usuario(db, "admin", "admin", "D-1")
        crear_usuario(db, "ana", "estudiante", "D-3")
        categoria = Categoria(nombre="Equipos")
        db.add(categoria)
        db.commit()
        db.add(Material(codigo="PROY-1", titulo="Proyector", tipo_material="proyector", categoria_id=categoria.id))
        db.commit()
    return servidor


@pytest.fixture()
def equipo_nuevo(tmp_path, servidor):
    """Un ejecutable recien instalado: base vacia y sin servidor."""
    return crear_equipo(tmp_path, "nuevo", servidor, url=None)


def _conectar(equipo, usuario="admin", clave=CLAVE_ADMIN, reemplazar=False, headers=None):
    return equipo.http.post(
        "/api/local/conectar",
        json={
            "servidor_url": "http://central",
            "usuario": usuario,
            "contrasena": clave,
            "reemplazar_datos_locales": reemplazar,
        },
        headers=headers or {},
    )


def _entrar_como_bibliotecaria(equipo):
    token = equipo.http.post(
        "/api/auth/login", json={"correo_o_usuario": "bibliotecaria", "contrasena": "Segura123"}
    ).json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_un_equipo_nuevo_pide_configuracion(equipo_nuevo):
    estado = equipo_nuevo.http.get("/api/local/estado").json()

    assert estado["configurado"] is False
    assert estado["servidor_url"] is None
    assert estado["modo"] == "local"


def test_modo_solo_local_crea_el_administrador_y_permite_entrar(equipo_nuevo):
    r = equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)
    assert r.status_code == 200 and r.json()["configurado"] is True

    login = equipo_nuevo.http.post(
        "/api/auth/login", json={"correo_o_usuario": "bibliotecaria", "contrasena": "Segura123"}
    )
    assert login.status_code == 200 and login.json()["usuario"]["rol"] == "admin"


def test_sin_servidor_no_se_acumulan_cambios_por_enviar(equipo_nuevo):
    equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)
    sesion = _entrar_como_bibliotecaria(equipo_nuevo)
    equipo_nuevo.http.post("/api/categorias/", json={"nombre": "Mapas"}, headers=sesion)

    assert equipo_nuevo.http.get("/api/local/estado").json()["pendientes"] == 0


def test_no_se_puede_configurar_dos_veces(equipo_nuevo):
    equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)

    segundo = equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)

    assert segundo.status_code == 409


def test_conectar_a_un_servidor_descarga_los_datos(equipo_nuevo):
    r = _conectar(equipo_nuevo)

    assert r.status_code == 200
    estado = r.json()
    assert estado["configurado"] is True and estado["conectado"] is True
    assert estado["servidor_url"] == "http://central"
    assert estado["ultima_sincronizacion"] is not None
    with equipo_nuevo.sesion() as db:
        assert db.execute(select(Material)).scalar_one().codigo == "PROY-1"


def test_conectar_con_clave_incorrecta_se_rechaza(equipo_nuevo):
    r = _conectar(equipo_nuevo, clave="incorrecta")

    assert r.status_code == 400
    assert equipo_nuevo.http.get("/api/local/estado").json()["configurado"] is False


def test_un_estudiante_no_puede_unir_un_equipo(equipo_nuevo):
    assert _conectar(equipo_nuevo, usuario="ana").status_code == 403


def test_conectar_un_equipo_con_datos_exige_confirmar_el_reemplazo(equipo_nuevo):
    equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)
    sesion = _entrar_como_bibliotecaria(equipo_nuevo)

    sin_confirmar = _conectar(equipo_nuevo, headers=sesion)
    confirmado = _conectar(equipo_nuevo, reemplazar=True, headers=sesion)

    assert sin_confirmar.status_code == 409
    assert confirmado.status_code == 200
    with equipo_nuevo.sesion() as db:
        nombres = {u.username for u in db.execute(select(Usuario)).scalars()}
    assert nombres == {"admin", "ana"}  # los datos propios se reemplazaron


def test_un_equipo_ya_configurado_solo_deja_conectar_a_un_administrador(equipo_nuevo):
    equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)

    assert _conectar(equipo_nuevo, reemplazar=True).status_code == 403  # sin sesion


def test_iniciar_sesion_recuerda_las_credenciales_para_sincronizar(equipo_nuevo, monkeypatch):
    _conectar(equipo_nuevo)
    equipo_nuevo.credenciales.olvidar()
    monkeypatch.setattr(configuracion, "MODO_APLICACION", "local")
    assert equipo_nuevo.http.get("/api/local/estado").json()["requiere_inicio_de_sesion"] is True

    equipo_nuevo.http.post("/api/auth/login", json={"correo_o_usuario": "admin", "contrasena": CLAVE_ADMIN})

    assert equipo_nuevo.credenciales.obtener() == ("admin", CLAVE_ADMIN)
    assert equipo_nuevo.http.get("/api/local/estado").json()["requiere_inicio_de_sesion"] is False


def test_sincronizar_sin_sesion_responde_409(equipo_nuevo):
    equipo_nuevo.http.post("/api/local/configurar-solo-local", json=DATOS_ADMIN)
    sesion = _entrar_como_bibliotecaria(equipo_nuevo)

    r = equipo_nuevo.http.post("/api/local/sincronizar", headers=sesion)

    assert r.status_code == 409


def test_desconectar_deja_el_equipo_en_modo_solo_local(equipo_nuevo):
    _conectar(equipo_nuevo)
    with equipo_nuevo.sesion() as db:
        admin = db.execute(select(Usuario).where(Usuario.username == "admin")).scalar_one()

    r = equipo_nuevo.http.post("/api/local/desconectar", headers=cabeceras(admin))

    assert r.status_code == 200 and r.json()["servidor_url"] is None
