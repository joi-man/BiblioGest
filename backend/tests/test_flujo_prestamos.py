"""Flujo principal: solicitud -> aprobacion -> entrega, rechazo y cancelacion."""
from datetime import timedelta

from tests.conftest import INSTANTE_BASE, encabezados


def solicitar(cliente, usuario, *materiales):
    return cliente.post(
        "/api/solicitudes/",
        json={"material_ids": [str(m.id) for m in materiales]},
        headers=encabezados(usuario),
    )


def accion(cliente, personal, prestamo_id, nombre, **json):
    return cliente.post(
        f"/api/prestamos/{prestamo_id}/{nombre}",
        json=json or None,
        headers=encabezados(personal),
    )


def test_solicitud_queda_pendiente_y_no_reserva_la_unidad(
    cliente, db, estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    respuesta = solicitar(cliente, estudiante, libro)

    assert respuesta.status_code == 201
    assert respuesta.json()["estado"] == "pendiente"
    db.refresh(libro)
    assert libro.estado == "disponible"


def test_aprobar_reserva_la_unidad_y_fija_plazo_de_retiro(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    respuesta = accion(cliente, bibliotecario, prestamo_id, "aprobar")

    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "aprobado"
    assert cuerpo["aprobado_por"]["username"] == "biblio"
    # 24 h de plazo de retiro por defecto, y la fecha sale en UTC con 'Z'
    esperado = (INSTANTE_BASE + timedelta(hours=24)).isoformat() + "Z"
    assert cuerpo["fecha_retiro_limite"] == esperado
    db.refresh(libro)
    assert libro.estado == "reservado"


def test_entregar_una_reserva_deja_el_prestamo_activo_con_plazo_de_la_categoria(
    cliente, db, estudiante, bibliotecario, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    prestamo_id = solicitar(cliente, estudiante, proyector).json()["id"]
    accion(cliente, bibliotecario, prestamo_id, "aprobar")

    respuesta = accion(cliente, bibliotecario, prestamo_id, "entregar")

    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "activo"
    assert cuerpo["entregado_por"]["username"] == "biblio"
    # La categoria Equipos define 4 horas de plazo
    limite = (INSTANTE_BASE + timedelta(hours=4)).isoformat() + "Z"
    assert cuerpo["detalles"][0]["fecha_devolucion_esperada"] == limite
    db.refresh(proyector)
    assert proyector.estado == "prestado"


def test_el_plazo_propio_del_material_tiene_prioridad_sobre_la_categoria(
    cliente, estudiante, bibliotecario, categoria_equipos, crear_material
):
    alargador = crear_material(
        categoria_equipos, "A-1", tipo_material="alargador", plazo_prestamo_horas=48
    )
    prestamo_id = solicitar(cliente, estudiante, alargador).json()["id"]

    cuerpo = accion(cliente, bibliotecario, prestamo_id, "entregar").json()

    limite = (INSTANTE_BASE + timedelta(hours=48)).isoformat() + "Z"
    assert cuerpo["detalles"][0]["fecha_devolucion_esperada"] == limite


def test_entregar_una_solicitud_pendiente_la_aprueba_y_entrega_en_un_paso(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    cuerpo = accion(cliente, bibliotecario, prestamo_id, "entregar").json()

    assert cuerpo["estado"] == "activo"
    assert cuerpo["aprobado_por"]["username"] == "biblio"
    db.refresh(libro)
    assert libro.estado == "prestado"


def test_rechazar_guarda_el_motivo_y_la_unidad_sigue_disponible(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    respuesta = accion(cliente, bibliotecario, prestamo_id, "rechazar", motivo="Sin cupo")

    assert respuesta.json()["estado"] == "rechazado"
    assert respuesta.json()["motivo_rechazo"] == "Sin cupo"
    db.refresh(libro)
    assert libro.estado == "disponible"


def test_cancelar_una_reserva_aprobada_libera_la_unidad(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo_id, "aprobar")

    respuesta = cliente.post(
        f"/api/solicitudes/{prestamo_id}/cancelar", headers=encabezados(estudiante)
    )

    assert respuesta.json()["estado"] == "cancelado"
    db.refresh(libro)
    assert libro.estado == "disponible"


def test_un_estudiante_no_puede_cancelar_la_solicitud_de_otro(
    cliente, estudiante, otro_estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    respuesta = cliente.post(
        f"/api/solicitudes/{prestamo_id}/cancelar", headers=encabezados(otro_estudiante)
    )

    assert respuesta.status_code == 403


def test_un_estudiante_no_puede_aprobar_ni_ver_el_listado_del_personal(
    cliente, estudiante, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    assert accion(cliente, estudiante, prestamo_id, "aprobar").status_code == 403
    assert (
        cliente.get("/api/prestamos/", headers=encabezados(estudiante)).status_code == 403
    )


def test_mis_solicitudes_solo_devuelve_las_propias(
    cliente, estudiante, otro_estudiante, categoria_libros, crear_material
):
    solicitar(cliente, estudiante, crear_material(categoria_libros, "L-1"))
    solicitar(cliente, otro_estudiante, crear_material(categoria_libros, "L-2"))

    mias = cliente.get("/api/solicitudes/mias", headers=encabezados(estudiante)).json()

    assert len(mias) == 1
    assert mias[0]["usuario"]["username"] == "ana"


def test_no_se_puede_aprobar_dos_veces_la_misma_unidad(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    primera = solicitar(cliente, estudiante, libro).json()["id"]
    segunda = solicitar(cliente, otro_estudiante, libro).json()["id"]

    assert accion(cliente, bibliotecario, primera, "aprobar").status_code == 200
    conflicto = accion(cliente, bibliotecario, segunda, "aprobar")

    assert conflicto.status_code == 409
    assert "no esta disponible" in conflicto.json()["detail"]


def test_un_material_solo_de_sala_no_se_puede_solicitar(
    cliente, estudiante, categoria_libros, crear_material
):
    referencia = crear_material(categoria_libros, "R-1", es_prestable=False)

    respuesta = solicitar(cliente, estudiante, referencia)

    assert respuesta.status_code == 409
    assert "solo para consulta en sala" in respuesta.json()["detail"]


def test_prestamo_directo_nace_activo_y_entregado(
    cliente, db, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    respuesta = cliente.post(
        "/api/prestamos/directo",
        json={"usuario_id": str(estudiante.id), "material_ids": [str(libro.id)]},
        headers=encabezados(bibliotecario),
    )

    assert respuesta.status_code == 201
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "activo"
    assert cuerpo["usuario"]["username"] == "ana"
    db.refresh(libro)
    assert libro.estado == "prestado"


def test_el_personal_puede_fijar_la_fecha_de_devolucion_con_zona_horaria(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    # 18:00 en UTC-3 equivale a 21:00 UTC
    respuesta = cliente.post(
        "/api/prestamos/directo",
        json={
            "usuario_id": str(estudiante.id),
            "material_ids": [str(libro.id)],
            "fecha_devolucion_esperada": "2026-10-11T18:00:00-03:00",
        },
        headers=encabezados(bibliotecario),
    )

    limite = respuesta.json()["detalles"][0]["fecha_devolucion_esperada"]
    assert limite == "2026-10-11T21:00:00Z"


def test_una_fecha_de_devolucion_en_el_pasado_se_rechaza(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")

    respuesta = cliente.post(
        "/api/prestamos/directo",
        json={
            "usuario_id": str(estudiante.id),
            "material_ids": [str(libro.id)],
            "fecha_devolucion_esperada": "2026-10-01T12:00:00Z",
        },
        headers=encabezados(bibliotecario),
    )

    assert respuesta.status_code == 400
