"""Devolucion con la fecha y hora reales en que se recibio el material."""
from datetime import timedelta

from sqlalchemy import select

from app.modelos import BitacoraAccion, PrestamoCabecera
from tests.conftest import INSTANTE_BASE, encabezados
from tests.test_devoluciones_y_vencimientos import prestar_directo

MOTIVO = "Lo trajo ayer por la tarde y no estaba el bibliotecario"


def devolver_con(cliente, personal, prestamo, fecha=None, motivo=None, condicion="bueno"):
    cuerpo = {"items": [{"prestamo_detalle_id": prestamo["detalles"][0]["id"], "condicion": condicion}]}
    if fecha is not None:
        cuerpo["fecha_devolucion"] = fecha.isoformat() + "Z"
    if motivo is not None:
        cuerpo["motivo_fecha"] = motivo
    return cliente.post(f"/api/devoluciones/{prestamo['id']}", json=cuerpo, headers=encabezados(personal))


def devolucion_de(respuesta):
    return respuesta.json()["detalles"][0]["devolucion"]


def test_sin_fecha_se_anota_el_momento_del_registro_y_no_pide_motivo(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(hours=2)

    respuesta = devolver_con(cliente, bibliotecario, prestamo)

    assert respuesta.status_code == 200
    assert devolucion_de(respuesta)["fecha_devolucion"] == (INSTANTE_BASE + timedelta(hours=2)).isoformat() + "Z"


def test_con_fecha_anterior_y_motivo_se_anota_esa_fecha_y_el_retraso_se_calcula_con_ella(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    # Plazo de 7 dias; se registra a los 10, pero el material llego al dia 6: sin retraso.
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=10)
    recibido = INSTANTE_BASE + timedelta(days=6)

    respuesta = devolver_con(cliente, bibliotecario, prestamo, fecha=recibido, motivo=MOTIVO)

    assert respuesta.status_code == 200
    devolucion = devolucion_de(respuesta)
    assert devolucion["fecha_devolucion"] == recibido.isoformat() + "Z"
    assert devolucion["dias_retraso"] == 0
    assert respuesta.json()["estado"] == "devuelto"


def test_sin_fecha_el_mismo_caso_si_cuenta_el_retraso(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=10)

    assert devolucion_de(devolver_con(cliente, bibliotecario, prestamo))["dias_retraso"] == 3


def test_la_fecha_real_queda_en_el_prestamo_completado(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=3)
    recibido = INSTANTE_BASE + timedelta(days=2)

    devolver_con(cliente, bibliotecario, prestamo, fecha=recibido, motivo=MOTIVO)

    guardado = db.execute(select(PrestamoCabecera)).scalar_one()
    assert guardado.fecha_devolucion_real == recibido


def test_otra_fecha_sin_motivo_se_rechaza_con_un_mensaje_claro(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=1)

    for motivo in (None, "", "corto"):
        respuesta = devolver_con(
            cliente, bibliotecario, prestamo, fecha=INSTANTE_BASE + timedelta(hours=5), motivo=motivo
        )
        assert respuesta.status_code == 400
        assert "Explica por que" in respuesta.json()["detail"]


def test_una_fecha_futura_se_rechaza(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(hours=1)

    respuesta = devolver_con(
        cliente, bibliotecario, prestamo, fecha=INSTANTE_BASE + timedelta(hours=5), motivo=MOTIVO
    )

    assert respuesta.status_code == 400
    assert "posterior a este momento" in respuesta.json()["detail"]


def test_una_fecha_anterior_a_la_entrega_se_rechaza(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=1)

    respuesta = devolver_con(
        cliente, bibliotecario, prestamo, fecha=INSTANTE_BASE - timedelta(hours=1), motivo=MOTIVO
    )

    assert respuesta.status_code == 400
    assert "anterior a la entrega" in respuesta.json()["detail"]


def test_no_se_acepta_una_fecha_de_hace_mas_de_treinta_dias(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=45)

    respuesta = devolver_con(
        cliente, bibliotecario, prestamo, fecha=INSTANTE_BASE + timedelta(days=2), motivo=MOTIVO
    )

    assert respuesta.status_code == 400
    assert "mas de 30 dias" in respuesta.json()["detail"]


def test_un_pequeno_adelanto_del_reloj_del_equipo_no_cuenta_como_futuro(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(hours=1)

    respuesta = devolver_con(
        cliente, bibliotecario, prestamo, fecha=reloj_prueba() + timedelta(seconds=30), motivo=MOTIVO
    )

    assert respuesta.status_code == 200
    assert devolucion_de(respuesta)["fecha_devolucion"] == reloj_prueba().isoformat() + "Z"


def test_la_bitacora_guarda_quien_cuando_y_por_que_se_anoto_otra_fecha(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material, reloj_prueba
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    reloj_prueba.avanzar(days=4)
    recibido = INSTANTE_BASE + timedelta(days=3)

    devolver_con(cliente, bibliotecario, prestamo, fecha=recibido, motivo=MOTIVO)

    registro = db.execute(
        select(BitacoraAccion).where(BitacoraAccion.accion == "DEVOLUCION_REGISTRADA")
    ).scalar_one()
    assert registro.usuario_id == bibliotecario.id
    assert registro.detalles["motivo_fecha"] == MOTIVO
    assert registro.detalles["fecha_devolucion_indicada"] == recibido.isoformat()
    assert registro.detalles["registrado_en"] == reloj_prueba().isoformat()


def test_una_devolucion_normal_no_agrega_datos_de_fecha_a_la_bitacora(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))

    devolver_con(cliente, bibliotecario, prestamo)

    registro = db.execute(
        select(BitacoraAccion).where(BitacoraAccion.accion == "DEVOLUCION_REGISTRADA")
    ).scalar_one()
    assert "motivo_fecha" not in registro.detalles
