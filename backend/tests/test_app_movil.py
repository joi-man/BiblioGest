"""Lo que necesita la app movil: catalogo del estudiante, cesion de reservas,
avisos por correo y cambio de contrasena."""
from tests.conftest import encabezados
from tests.test_flujo_prestamos import accion, solicitar


def listar_catalogo(cliente, usuario, **params):
    return cliente.get("/api/materiales/", params=params, headers=encabezados(usuario)).json()


# ---------------------------------------------------------------------------
# Catalogo: el estudiante solo ve libros y revistas
# ---------------------------------------------------------------------------
def test_el_estudiante_solo_ve_libros_y_revistas_y_ningun_equipo(
    cliente, estudiante, bibliotecario, categoria_libros, categoria_equipos, crear_material
):
    crear_material(categoria_libros, "L-1")
    crear_material(categoria_libros, "R-1", tipo_material="revista")
    crear_material(categoria_equipos, "P-1", tipo_material="proyector")
    crear_material(categoria_libros, "L-2", estado="fuera_de_servicio")

    del_estudiante = {m["codigo"] for m in listar_catalogo(cliente, estudiante)}
    del_personal = {m["codigo"] for m in listar_catalogo(cliente, bibliotecario)}

    assert del_estudiante == {"L-1", "R-1"}
    assert del_personal == {"L-1", "R-1", "P-1", "L-2"}


def test_el_catalogo_muestra_el_estado_real_de_cada_material(
    cliente, estudiante, categoria_libros, crear_material
):
    crear_material(categoria_libros, "L-1")
    crear_material(categoria_libros, "L-2", estado="reservado")
    crear_material(categoria_libros, "L-3", estado="prestado")
    crear_material(categoria_libros, "L-4", estado="vencido")

    estados = {m["codigo"]: m["estado"] for m in listar_catalogo(cliente, estudiante)}

    assert estados == {
        "L-1": "disponible", "L-2": "reservado", "L-3": "prestado", "L-4": "vencido",
    }


def test_el_estudiante_no_puede_ver_el_detalle_de_un_equipo(
    cliente, estudiante, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")

    respuesta = cliente.get(f"/api/materiales/{proyector.id}", headers=encabezados(estudiante))

    assert respuesta.status_code == 404


def test_el_estudiante_no_puede_solicitar_un_equipo(
    cliente, db, estudiante, categoria_equipos, crear_material
):
    proyector = crear_material(categoria_equipos, "P-1", tipo_material="proyector")

    respuesta = solicitar(cliente, estudiante, proyector)

    assert respuesta.status_code == 403
    db.refresh(proyector)
    assert proyector.estado == "disponible"


# ---------------------------------------------------------------------------
# Solicitudes: respuesta del bibliotecario y nueva solicitud tras un rechazo
# ---------------------------------------------------------------------------
def test_el_estudiante_ve_el_motivo_del_rechazo_y_puede_volver_a_solicitar(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    primera = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, primera, "rechazar", motivo="Falta devolver otro libro")

    mias = cliente.get("/api/solicitudes/mias", headers=encabezados(estudiante)).json()
    assert mias[0]["estado"] == "rechazado"
    assert mias[0]["motivo_rechazo"] == "Falta devolver otro libro"

    segunda = solicitar(cliente, estudiante, libro)
    assert segunda.status_code == 201
    assert segunda.json()["estado"] == "pendiente"


def test_aprobar_y_rechazar_envian_un_correo_al_estudiante(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, monkeypatch
):
    enviados = []
    monkeypatch.setattr(
        "app.servicios.email_servicio.enviar_correo",
        lambda destino, asunto, cuerpo: enviados.append((destino, asunto, cuerpo)) or True,
    )
    libro_a = crear_material(categoria_libros, "L-1", titulo="Cien anos de soledad")
    libro_b = crear_material(categoria_libros, "L-2", titulo="El Aleph")
    aprobada = solicitar(cliente, estudiante, libro_a).json()["id"]
    rechazada = solicitar(cliente, estudiante, libro_b).json()["id"]

    accion(cliente, bibliotecario, aprobada, "aprobar")
    accion(cliente, bibliotecario, rechazada, "rechazar", motivo="Libro en revision")

    assert [d for d, _, _ in enviados] == ["ana@prueba.com", "ana@prueba.com"]
    asunto_aprobado, cuerpo_aprobado = enviados[0][1], enviados[0][2]
    assert "aprobada" in asunto_aprobado and "Cien anos de soledad" in cuerpo_aprobado
    assert "no fue aprobada" in enviados[1][1] and "Libro en revision" in enviados[1][2]


def test_un_correo_que_falla_no_rompe_la_aprobacion(
    cliente, estudiante, bibliotecario, categoria_libros, crear_material, monkeypatch
):
    def fallar(*args):
        raise RuntimeError("SMTP caido")

    monkeypatch.setattr("app.servicios.email_servicio.enviar_correo", fallar)
    libro = crear_material(categoria_libros, "L-1")
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]

    respuesta = accion(cliente, bibliotecario, prestamo_id, "aprobar")

    assert respuesta.status_code == 200
    assert respuesta.json()["estado"] == "aprobado"


# ---------------------------------------------------------------------------
# Cesion de una reserva a otra persona
# ---------------------------------------------------------------------------
def reservar(cliente, estudiante, bibliotecario, libro):
    prestamo_id = solicitar(cliente, estudiante, libro).json()["id"]
    accion(cliente, bibliotecario, prestamo_id, "aprobar")
    return prestamo_id


def test_ceder_una_reserva_la_cancela_con_motivo_y_presta_a_la_otra_persona(
    cliente, db, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    reserva_id = reservar(cliente, estudiante, bibliotecario, libro)

    respuesta = accion(
        cliente, bibliotecario, reserva_id, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="Lo necesita un docente para clase",
    )

    assert respuesta.status_code == 200
    nuevo = respuesta.json()
    assert nuevo["estado"] == "activo"
    assert nuevo["usuario"]["username"] == "luis"
    db.refresh(libro)
    assert libro.estado == "prestado"

    # Quien reservo ve su reserva cancelada y el motivo.
    mias = cliente.get("/api/solicitudes/mias", headers=encabezados(estudiante)).json()
    assert mias[0]["estado"] == "cancelado"
    assert mias[0]["motivo_rechazo"] == "Lo necesita un docente para clase"


def test_ceder_avisa_por_correo_a_quien_reservo(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material, monkeypatch
):
    enviados = []
    monkeypatch.setattr(
        "app.servicios.email_servicio.enviar_correo",
        lambda destino, asunto, cuerpo: enviados.append((destino, asunto, cuerpo)) or True,
    )
    libro = crear_material(categoria_libros, "L-1")
    reserva_id = reservar(cliente, estudiante, bibliotecario, libro)
    enviados.clear()

    accion(
        cliente, bibliotecario, reserva_id, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="Lo necesita un docente para clase",
    )

    assert len(enviados) == 1
    destino, asunto, cuerpo = enviados[0]
    assert destino == "ana@prueba.com"
    assert "cedida" in asunto
    assert "Lo necesita un docente para clase" in cuerpo


def test_ceder_exige_un_motivo_de_verdad(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    reserva_id = reservar(cliente, estudiante, bibliotecario, libro)

    respuesta = accion(
        cliente, bibliotecario, reserva_id, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="porque si",
    )

    assert respuesta.status_code == 422


def test_ceder_solo_funciona_con_reservas_aprobadas(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    pendiente = solicitar(cliente, estudiante, libro).json()["id"]

    respuesta = accion(
        cliente, bibliotecario, pendiente, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="Motivo suficientemente largo",
    )

    assert respuesta.status_code == 409


def test_si_la_cesion_no_es_posible_la_reserva_original_queda_intacta(
    cliente, db, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    reserva_id = reservar(cliente, estudiante, bibliotecario, libro)
    otro_estudiante.activo = False
    db.commit()

    respuesta = accion(
        cliente, bibliotecario, reserva_id, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="Motivo suficientemente largo",
    )

    assert respuesta.status_code == 409
    db.refresh(libro)
    assert libro.estado == "reservado"
    mias = cliente.get("/api/solicitudes/mias", headers=encabezados(estudiante)).json()
    assert mias[0]["estado"] == "aprobado"


def test_un_estudiante_no_puede_ceder_reservas(
    cliente, estudiante, otro_estudiante, bibliotecario, categoria_libros, crear_material
):
    libro = crear_material(categoria_libros, "L-1")
    reserva_id = reservar(cliente, estudiante, bibliotecario, libro)

    respuesta = accion(
        cliente, estudiante, reserva_id, "ceder",
        usuario_id=str(otro_estudiante.id), motivo="Motivo suficientemente largo",
    )

    assert respuesta.status_code == 403


# ---------------------------------------------------------------------------
# Cambio de contrasena
# ---------------------------------------------------------------------------
def cambiar(cliente, usuario, actual, nueva):
    return cliente.post(
        "/api/auth/cambiar-contrasena",
        json={"contrasena_actual": actual, "nueva_contrasena": nueva},
        headers=encabezados(usuario),
    )


def iniciar_sesion(cliente, usuario, contrasena):
    return cliente.post(
        "/api/auth/login",
        json={"correo_o_usuario": usuario.username, "contrasena": contrasena},
    )


def test_cambiar_la_contrasena_permite_entrar_con_la_nueva_y_no_con_la_vieja(
    cliente, estudiante
):
    assert cambiar(cliente, estudiante, "Clave12345", "NuevaClave99").status_code == 200

    assert iniciar_sesion(cliente, estudiante, "NuevaClave99").status_code == 200
    assert iniciar_sesion(cliente, estudiante, "Clave12345").status_code == 401


def test_cambiar_la_contrasena_con_la_actual_incorrecta_falla(cliente, estudiante):
    respuesta = cambiar(cliente, estudiante, "no-es-esta", "NuevaClave99")

    assert respuesta.status_code == 400
    assert iniciar_sesion(cliente, estudiante, "Clave12345").status_code == 200


def test_la_nueva_contrasena_debe_ser_distinta_y_tener_al_menos_6_caracteres(
    cliente, estudiante
):
    assert cambiar(cliente, estudiante, "Clave12345", "Clave12345").status_code == 400
    assert cambiar(cliente, estudiante, "Clave12345", "abc").status_code == 422


def test_cambiar_la_contrasena_exige_sesion(cliente):
    respuesta = cliente.post(
        "/api/auth/cambiar-contrasena",
        json={"contrasena_actual": "a", "nueva_contrasena": "abcdef"},
    )

    assert respuesta.status_code in (401, 403)


# ---------------------------------------------------------------------------
# El correo no distingue mayusculas (los teclados del telefono las ponen solos)
# ---------------------------------------------------------------------------
def test_recuperar_la_contrasena_funciona_aunque_el_correo_se_escriba_con_mayusculas(
    cliente, estudiante, monkeypatch
):
    enviados = []
    monkeypatch.setattr(
        "app.servicios.email_servicio.enviar_correo",
        lambda destino, asunto, cuerpo: enviados.append((destino, cuerpo)) or True,
    )

    respuesta = cliente.post("/api/auth/olvide-contrasena", json={"correo": "Ana@prueba.com"})

    assert respuesta.status_code == 200
    assert [d for d, _ in enviados] == ["ana@prueba.com"]
    assert "codigo de recuperacion es" in enviados[0][1]


def test_iniciar_sesion_con_el_correo_en_mayusculas(cliente, estudiante):
    respuesta = cliente.post(
        "/api/auth/login",
        json={"correo_o_usuario": "ANA@Prueba.com", "contrasena": "Clave12345"},
    )

    assert respuesta.status_code == 200
