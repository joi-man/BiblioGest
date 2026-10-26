"""Recuperacion de cuentas: el codigo verifica la identidad, vence y es de un solo uso."""
from datetime import datetime, timedelta

from sqlalchemy import select

from app.modelos.codigo_recuperacion import CodigoRecuperacion
from app.servicios import recuperacion_servicio as recuperacion


def pedir(db, usuario):
    _, codigo = recuperacion.solicitar_codigo(db, usuario.correo_electronico)
    return codigo


def restablecer(db, usuario, codigo, clave="NuevaClave1"):
    return recuperacion.restablecer_contrasena(db, usuario.correo_electronico, codigo, clave)


def test_el_codigo_tiene_seis_digitos_y_no_se_guarda_en_claro(db, estudiante):
    codigo = pedir(db, estudiante)

    assert len(codigo) == 6 and codigo.isdigit()
    registro = db.execute(select(CodigoRecuperacion)).scalar_one()
    assert registro.codigo_hash != codigo


def test_con_el_codigo_correcto_se_cambia_la_contrasena(cliente, db, estudiante):
    codigo = pedir(db, estudiante)

    assert restablecer(db, estudiante, codigo) is True

    entrar = cliente.post(
        "/api/auth/login", json={"correo_o_usuario": estudiante.username, "contrasena": "NuevaClave1"}
    )
    assert entrar.status_code == 200


def test_un_codigo_incorrecto_no_cambia_nada(db, estudiante):
    pedir(db, estudiante)

    assert restablecer(db, estudiante, "000000x") is False


def test_el_codigo_es_de_un_solo_uso(db, estudiante):
    codigo = pedir(db, estudiante)
    assert restablecer(db, estudiante, codigo) is True

    assert restablecer(db, estudiante, codigo, "OtraClave22") is False


def test_el_codigo_vence_a_los_15_minutos(db, estudiante):
    codigo = pedir(db, estudiante)
    registro = db.execute(select(CodigoRecuperacion)).scalar_one()
    assert registro.expira_en - datetime.utcnow() <= timedelta(minutes=15)

    registro.expira_en = datetime.utcnow() - timedelta(seconds=1)
    db.commit()

    assert restablecer(db, estudiante, codigo) is False


def test_tras_cinco_intentos_fallidos_el_codigo_deja_de_servir(db, estudiante):
    codigo = pedir(db, estudiante)
    for _ in range(5):
        assert restablecer(db, estudiante, "abcdef") is False

    assert restablecer(db, estudiante, codigo) is False


def test_un_codigo_nuevo_invalida_el_anterior(db, estudiante):
    viejo = pedir(db, estudiante)
    nuevo = pedir(db, estudiante)

    assert restablecer(db, estudiante, viejo) is False
    assert restablecer(db, estudiante, nuevo) is True


def test_una_cuenta_suspendida_no_recibe_codigo(db, estudiante):
    estudiante.activo = False
    db.commit()

    assert recuperacion.solicitar_codigo(db, estudiante.correo_electronico) is None
