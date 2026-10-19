"""Mensaje claro cuando se escribe la direccion de la pagina web en lugar de la del servidor."""
import httpx
import pytest

from app.sync.cliente_central import (
    ClienteCentral,
    ErrorDireccionIncorrecta,
    ErrorServidor,
)


def cliente_con(manejador) -> ClienteCentral:
    http = httpx.Client(base_url="http://central", transport=httpx.MockTransport(manejador))
    return ClienteCentral("http://central", http=http)


def test_la_pagina_web_responde_405_y_se_explica_que_no_es_el_servidor():
    # Vercel (la pagina web) no tiene API: un POST a /api/auth/login da 405 sin JSON.
    cliente = cliente_con(lambda _: httpx.Response(405, text="Method Not Allowed"))

    with pytest.raises(ErrorDireccionIncorrecta) as error:
        cliente.iniciar_sesion("admin", "clave")

    mensaje = str(error.value)
    assert "405" in mensaje
    assert "no parece ser el servidor" in mensaje
    assert "pagina web" in mensaje


def test_una_pagina_que_devuelve_html_con_404_tambien_se_reconoce():
    cliente = cliente_con(lambda _: httpx.Response(404, html="<html>no encontrado</html>"))

    with pytest.raises(ErrorDireccionIncorrecta):
        cliente.iniciar_sesion("admin", "clave")


def test_un_error_de_la_propia_api_no_se_confunde_con_una_direccion_equivocada():
    cliente = cliente_con(lambda _: httpx.Response(404, json={"detail": "Material no encontrado"}))

    with pytest.raises(ErrorServidor) as error:
        cliente.obtener_filas("materiales", ["x"])

    assert not isinstance(error.value, ErrorDireccionIncorrecta)
    assert "Material no encontrado" in str(error.value)


def test_el_servidor_de_bibliogest_que_rechaza_las_credenciales_sigue_igual():
    from app.sync.cliente_central import ErrorCredenciales

    cliente = cliente_con(lambda _: httpx.Response(401, json={"detail": "Credenciales invalidas"}))

    with pytest.raises(ErrorCredenciales):
        cliente.iniciar_sesion("admin", "mala")


def test_la_comprobacion_de_conexion_no_da_por_bueno_el_html_de_la_pagina_web():
    pagina = cliente_con(lambda _: httpx.Response(200, html="<html>BiblioGest</html>"))
    servidor = cliente_con(lambda _: httpx.Response(200, json={"estado": "ok"}))

    assert pagina.hay_conexion() is False
    assert servidor.hay_conexion() is True
