"""Devoluciones (completas y parciales), multas opcionales y vencimientos."""
import pytest

from app.core.config import configuracion
from tests.conftest import encabezados


def prestar_directo(cliente, personal, usuario, *materiales):
    respuesta = cliente.post(
        "/api/prestamos/directo",
        json={"usuario_id": str(usuario.id), "material_ids": [str(m.id) for m in materiales]},
        headers=encabezados(personal),
    )
    assert respuesta.status_code == 201, respuesta.text
    return respuesta.json()


def devolver(cliente, personal, prestamo, *items):
    """items: tuplas (indice_del_detalle, condicion)."""
    return cliente.post(
        f"/api/devoluciones/{prestamo['id']}",
        json={
            "items": [
                {"prestamo_detalle_id": prestamo["detalles"][i]["id"], "condicion": c}
                for i, c in items
            ]
        },
        headers=encabezados(personal),
    )


def test_devolver_todo_cierra_el_prestamo_y_libera_las_unidades(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, libro)

    respuesta = devolver(cliente, bibliotecario, prestamo, (0, "bueno"))

    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "devuelto"
    assert cuerpo["fecha_devolucion_real"] is not None
    assert cuerpo["detalles"][0]["devuelto"] is True
    assert cuerpo["detalles"][0]["devolucion"]["dias_retraso"] == 0
    db.refresh(libro)
    assert libro.estado == "disponible"


def test_devolucion_parcial_mantiene_activo_el_resto(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro_a = crear_material(categoria_libros, "L-1")
    libro_b = crear_material(categoria_libros, "L-2")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, libro_a, libro_b)

    cuerpo = devolver(cliente, bibliotecario, prestamo, (0, "bueno")).json()

    assert cuerpo["estado"] == "activo"
    devueltos = [d["devuelto"] for d in cuerpo["detalles"]]
    assert sorted(devueltos) == [False, True]


def test_no_se_puede_devolver_dos_veces_el_mismo_item(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro_a = crear_material(categoria_libros, "L-1")
    libro_b = crear_material(categoria_libros, "L-2")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, libro_a, libro_b)
    devolver(cliente, bibliotecario, prestamo, (0, "bueno"))

    repetida = devolver(cliente, bibliotecario, prestamo, (0, "bueno"))

    assert repetida.status_code == 409


@pytest.mark.parametrize(
    "condicion, estado_final, condicion_material",
    [
        ("bueno", "disponible", "bueno"),
        ("dano_menor", "disponible", "regular"),
        ("dano_mayor", "fuera_de_servicio", "malo"),
        ("perdido", "fuera_de_servicio", "malo"),
    ],
)
def test_la_condicion_al_devolver_define_el_estado_de_la_unidad(
    cliente, db, estudiante, bibliotecario, categoria_equipos, crear_material,
    condicion, estado_final, condicion_material,
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, proyector)

    devolver(cliente, bibliotecario, prestamo, (0, condicion))

    db.refresh(proyector)
    assert proyector.estado == estado_final
    assert proyector.condicion == condicion_material


def test_pasado_el_plazo_el_prestamo_y_la_unidad_pasan_a_vencido(
    cliente, db, reloj_prueba, estudiante, bibliotecario, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestar_directo(cliente, bibliotecario, estudiante, proyector)

    reloj_prueba.avanzar(hours=5)
    listado = cliente.get(
        "/api/prestamos/", params={"estado": "vencido"}, headers=encabezados(bibliotecario)
    ).json()

    assert len(listado) == 1
    db.refresh(proyector)
    assert proyector.estado == "vencido"


def test_devolver_con_retraso_registra_los_dias(
    cliente, reloj_prueba, estudiante, bibliotecario, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, proyector)

    reloj_prueba.avanzar(hours=4, days=2, minutes=1)  # 2 dias y un minuto despues del limite
    cuerpo = devolver(cliente, bibliotecario, prestamo, (0, "bueno")).json()

    assert cuerpo["estado"] == "devuelto"
    assert cuerpo["detalles"][0]["devolucion"]["dias_retraso"] == 3  # la fraccion cuenta como dia


def test_una_reserva_sin_retirar_expira_y_libera_la_unidad(
    cliente, db, reloj_prueba, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = cliente.post(
        "/api/solicitudes/",
        json={"material_ids": [str(libro.id)]},
        headers=encabezados(estudiante),
    ).json()["id"]
    cliente.post(f"/api/prestamos/{prestamo_id}/aprobar", headers=encabezados(bibliotecario))

    reloj_prueba.avanzar(hours=25)
    cuerpo = cliente.get(
        f"/api/prestamos/{prestamo_id}", headers=encabezados(bibliotecario)
    ).json()

    assert cuerpo["estado"] == "cancelado"
    assert "no se retiro" in cuerpo["motivo_rechazo"]
    db.refresh(libro)
    assert libro.estado == "disponible"


def test_las_multas_estan_desactivadas_por_defecto(
    cliente, reloj_prueba, estudiante, bibliotecario, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, proyector)
    reloj_prueba.avanzar(days=3)

    cuerpo = devolver(cliente, bibliotecario, prestamo, (0, "dano_mayor")).json()

    assert cuerpo["detalles"][0]["devolucion"]["multa_monto"] is None


def test_con_multas_habilitadas_se_suman_retraso_y_dano(
    monkeypatch, cliente, reloj_prueba, estudiante, bibliotecario, categoria_equipos,
    crear_material,
):
    monkeypatch.setattr(configuracion, "MULTAS_HABILITADAS", True)
    monkeypatch.setattr(configuracion, "MULTA_POR_DIA_RETRASO", 2.5)
    monkeypatch.setattr(configuracion, "MULTA_DANO_MENOR", 10.0)
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, proyector)
    reloj_prueba.avanzar(hours=4, days=1, minutes=1)  # 2 dias de retraso

    cuerpo = devolver(cliente, bibliotecario, prestamo, (0, "dano_menor")).json()

    assert cuerpo["detalles"][0]["devolucion"]["multa_monto"] == 15.0  # 2 x 2.5 + 10


def test_con_multas_habilitadas_un_material_perdido_cobra_su_valor(
    monkeypatch, cliente, estudiante, bibliotecario, categoria_equipos, crear_material
):
    monkeypatch.setattr(configuracion, "MULTAS_HABILITADAS", True)
    proyector = crear_material(
        categoria_equipos, "P-1", tipo_material="proyector", valor_referencial=450
    )
    prestamo = prestar_directo(cliente, bibliotecario, estudiante, proyector)

    cuerpo = devolver(cliente, bibliotecario, prestamo, (0, "perdido")).json()

    assert cuerpo["detalles"][0]["devolucion"]["multa_monto"] == 450.0


def test_pendientes_de_devolucion_muestra_los_mas_urgentes_primero(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_equipos, categoria_libros,
    crear_material,
):
    libro = crear_material(categoria_libros, "L-1")
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestar_directo(cliente, bibliotecario, estudiante, libro)
    prestar_directo(cliente, bibliotecario, otro_estudiante, proyector)

    cuerpo = cliente.get(
        "/api/devoluciones/pendientes", headers=encabezados(bibliotecario)
    ).json()

    assert [p["usuario"]["username"] for p in cuerpo] == ["luis", "ana"]  # proyector vence antes


def test_buscar_pendientes_por_nombre_o_codigo(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    prestar_directo(
        cliente, bibliotecario, otro_estudiante, crear_material(categoria_libros, "XYZ-9")
    )

    por_codigo = cliente.get(
        "/api/devoluciones/pendientes", params={"q": "XYZ"}, headers=encabezados(bibliotecario)
    ).json()
    por_nombre = cliente.get(
        "/api/devoluciones/pendientes", params={"q": "ana"}, headers=encabezados(bibliotecario)
    ).json()

    assert [p["usuario"]["username"] for p in por_codigo] == ["luis"]
    assert [p["usuario"]["username"] for p in por_nombre] == ["ana"]


def test_dashboard_cuenta_materiales_y_prestamos(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    prestar_directo(cliente, bibliotecario, estudiante, crear_material(categoria_libros, "L-1"))
    crear_material(categoria_libros, "L-2")
    cliente.post(
        "/api/solicitudes/",
        json={"material_ids": [str(crear_material(categoria_libros, "L-3").id)]},
        headers=encabezados(otro_estudiante),
    )

    resumen = cliente.get("/api/dashboard/resumen", headers=encabezados(bibliotecario)).json()

    assert resumen["materiales"]["total"] == 3
    assert resumen["materiales"]["prestados"] == 1
    assert resumen["materiales"]["disponibles"] == 2
    assert resumen["prestamos"]["activos"] == 1
    assert resumen["prestamos"]["solicitudes_pendientes"] == 1
    assert resumen["prestamos"]["entregados_hoy"] == 1
