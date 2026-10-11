"""Codigos de recuperacion: el ejecutable los pide al servidor central para enviarlos por correo."""
import pytest

from app.core.config import configuracion
from app.rutas import auth
from app.servicios import email_servicio
from app.servicios.limitador import LimitadorPorClave


@pytest.fixture()
def correos(monkeypatch):
    enviados = []
    monkeypatch.setattr(
        email_servicio, "enviar_correo", lambda destino, asunto, cuerpo: enviados.append((destino, cuerpo)) or True
    )
    monkeypatch.setattr(auth, "_limite_por_correo", LimitadorPorClave(3, 900))
    monkeypatch.setattr(auth, "_limite_global", LimitadorPorClave(60, 3600))
    return enviados


class ServidorFalso:
    """Sustituye a `ClienteCentral`: guarda lo que el equipo le pide enviar."""

    hay_red = True
    pedidos: list = []

    def __init__(self, url):
        self.url = url

    def hay_conexion(self):
        return self.hay_red

    def enviar_codigo_recuperacion(self, correo, codigo):
        self.pedidos.append((self.url, correo, codigo))

    def cerrar(self):
        pass


@pytest.fixture()
def equipo(monkeypatch, correos):
    monkeypatch.setattr(configuracion, "MODO_APLICACION", "local")
    monkeypatch.setattr(configuracion, "SMTP_CLAVE", "")
    monkeypatch.setattr(auth.estado_local, "servidor_url", lambda db: "https://central.test")
    monkeypatch.setattr(auth, "ClienteCentral", ServidorFalso)
    ServidorFalso.hay_red = True
    ServidorFalso.pedidos = []
    return ServidorFalso


# ------------------------------------------------------------------ servidor central
def test_el_servidor_envia_el_codigo_pedido_por_un_equipo(cliente, admin, correos):
    r = cliente.post("/api/auth/codigo-externo", json={"correo": admin.correo_electronico, "codigo": "123456"})

    assert r.status_code == 200
    assert len(correos) == 1
    destino, cuerpo = correos[0]
    assert destino == admin.correo_electronico
    assert "123456" in cuerpo


def test_el_servidor_no_revela_si_el_correo_existe(cliente, correos):
    r = cliente.post("/api/auth/codigo-externo", json={"correo": "nadie@prueba.com", "codigo": "123456"})

    assert r.status_code == 200
    assert correos == []


def test_el_servidor_no_escribe_a_cuentas_desactivadas(cliente, admin, db, correos):
    admin.activo = False
    db.commit()

    cliente.post("/api/auth/codigo-externo", json={"correo": admin.correo_electronico, "codigo": "123456"})

    assert correos == []


def test_el_servidor_limita_los_envios_por_correo(cliente, admin, correos):
    datos = {"correo": admin.correo_electronico, "codigo": "123456"}
    estados = [cliente.post("/api/auth/codigo-externo", json=datos).status_code for _ in range(4)]

    assert estados == [200, 200, 200, 429]
    assert len(correos) == 3


def test_el_servidor_rechaza_codigos_mal_formados(cliente, admin, correos):
    r = cliente.post("/api/auth/codigo-externo", json={"correo": admin.correo_electronico, "codigo": "abc"})

    assert r.status_code == 422
    assert correos == []


def test_un_equipo_local_no_ofrece_el_envio_externo(cliente, admin, correos, monkeypatch):
    monkeypatch.setattr(configuracion, "MODO_APLICACION", "local")

    r = cliente.post("/api/auth/codigo-externo", json={"correo": admin.correo_electronico, "codigo": "123456"})

    assert r.status_code == 404
    assert correos == []


# ------------------------------------------------------------------ equipo con el ejecutable
def test_el_equipo_pide_al_servidor_que_envie_el_codigo(cliente, admin, equipo, correos):
    r = cliente.post("/api/auth/olvide-contrasena", json={"correo": admin.correo_electronico})

    assert r.status_code == 200
    assert correos == []  # el equipo no envía nada por sí mismo
    assert len(equipo.pedidos) == 1
    url, correo, codigo = equipo.pedidos[0]
    assert (url, correo) == ("https://central.test", admin.correo_electronico)

    # El código enviado es el que vale en este equipo.
    r = cliente.post(
        "/api/auth/restablecer-contrasena",
        json={"correo": admin.correo_electronico, "codigo": codigo, "nueva_contrasena": "NuevaClave1"},
    )
    assert r.status_code == 200


def test_sin_conexion_el_equipo_avisa_en_lugar_de_callar(cliente, admin, equipo):
    equipo.hay_red = False

    r = cliente.post("/api/auth/olvide-contrasena", json={"correo": admin.correo_electronico})

    assert r.status_code == 503
    assert "internet" in r.json()["detail"]
    assert equipo.pedidos == []


def test_el_aviso_de_falta_de_conexion_no_depende_de_que_el_correo_exista(cliente, equipo):
    equipo.hay_red = False

    r = cliente.post("/api/auth/olvide-contrasena", json={"correo": "nadie@prueba.com"})

    assert r.status_code == 503


def test_un_equipo_con_su_propia_clave_envia_el_correo_directamente(cliente, admin, equipo, correos, monkeypatch):
    monkeypatch.setattr(configuracion, "SMTP_CLAVE", "clave-propia")
    equipo.hay_red = False

    r = cliente.post("/api/auth/olvide-contrasena", json={"correo": admin.correo_electronico})

    assert r.status_code == 200
    assert len(correos) == 1
    assert equipo.pedidos == []


def test_el_servidor_central_sigue_enviando_el_correo_por_si_mismo(cliente, admin, correos):
    r = cliente.post("/api/auth/olvide-contrasena", json={"correo": admin.correo_electronico})

    assert r.status_code == 200
    assert len(correos) == 1
