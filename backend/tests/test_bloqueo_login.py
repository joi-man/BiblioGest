"""Bloqueo temporal de la cuenta tras varios intentos fallidos de inicio de sesion."""
import pytest

from app.rutas import auth
from app.servicios.limitador import BloqueoPorIntentos


class Segundos:
    """Reloj manual para avanzar el tiempo sin esperar."""

    def __init__(self) -> None:
        self.ahora = 1000.0

    def __call__(self) -> float:
        return self.ahora


@pytest.fixture()
def tiempo(monkeypatch) -> Segundos:
    reloj = Segundos()
    monkeypatch.setattr(auth, "_bloqueo_login", BloqueoPorIntentos(5, 15, reloj=reloj))
    return reloj


def entrar(cliente, usuario, contrasena):
    return cliente.post(
        "/api/auth/login", json={"correo_o_usuario": usuario.username, "contrasena": contrasena}
    )


def fallar_cinco_veces(cliente, usuario):
    return [entrar(cliente, usuario, "incorrecta") for _ in range(5)]


def test_cada_fallo_avisa_cuantos_intentos_quedan(cliente, estudiante, tiempo):
    respuesta = entrar(cliente, estudiante, "incorrecta")

    assert respuesta.status_code == 401
    assert "Te quedan 4 intentos" in respuesta.json()["detail"]


def test_el_quinto_fallo_bloquea_la_cuenta_e_informa_el_tiempo(cliente, estudiante, tiempo):
    respuestas = fallar_cinco_veces(cliente, estudiante)

    assert [r.status_code for r in respuestas] == [401, 401, 401, 401, 429]
    detalle = respuestas[-1].json()["detail"]
    assert "bloqueado" in detalle and "15 minutos" in detalle
    assert respuestas[-1].headers["Retry-After"] == "900"


def test_con_la_cuenta_bloqueada_ni_la_contrasena_correcta_entra(cliente, estudiante, tiempo):
    fallar_cinco_veces(cliente, estudiante)

    respuesta = entrar(cliente, estudiante, "Clave12345")

    assert respuesta.status_code == 429
    assert "access_token" not in respuesta.json()


def test_pasado_el_bloqueo_se_puede_volver_a_entrar(cliente, estudiante, tiempo):
    fallar_cinco_veces(cliente, estudiante)

    tiempo.ahora += 15 * 60 + 1

    assert entrar(cliente, estudiante, "Clave12345").status_code == 200


def test_pasado_el_bloqueo_se_vuelven_a_tener_todos_los_intentos(cliente, estudiante, tiempo):
    fallar_cinco_veces(cliente, estudiante)
    tiempo.ahora += 15 * 60 + 1

    respuesta = entrar(cliente, estudiante, "incorrecta")

    assert respuesta.status_code == 401
    assert "Te quedan 4 intentos" in respuesta.json()["detail"]


def test_un_acierto_borra_los_fallos_anteriores(cliente, estudiante, tiempo):
    for _ in range(4):
        entrar(cliente, estudiante, "incorrecta")
    assert entrar(cliente, estudiante, "Clave12345").status_code == 200

    respuesta = entrar(cliente, estudiante, "incorrecta")

    assert "Te quedan 4 intentos" in respuesta.json()["detail"]


def test_el_bloqueo_de_una_cuenta_no_afecta_a_otra(cliente, estudiante, bibliotecario, tiempo):
    fallar_cinco_veces(cliente, estudiante)

    assert entrar(cliente, bibliotecario, "Clave12345").status_code == 200


def test_un_usuario_inexistente_tambien_se_bloquea_sin_revelar_que_no_existe(cliente, tiempo):
    respuestas = [
        cliente.post(
            "/api/auth/login", json={"correo_o_usuario": "nadie", "contrasena": "x"}
        )
        for _ in range(5)
    ]

    assert [r.status_code for r in respuestas] == [401, 401, 401, 401, 429]


def test_el_bloqueo_no_distingue_mayusculas_en_el_usuario(cliente, estudiante, tiempo):
    for _ in range(5):
        cliente.post(
            "/api/auth/login",
            json={"correo_o_usuario": estudiante.username.upper(), "contrasena": "x"},
        )

    assert entrar(cliente, estudiante, "Clave12345").status_code == 429
