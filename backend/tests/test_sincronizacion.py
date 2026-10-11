"""Sincronizacion entre el servidor central y los equipos con el ejecutable."""
import pytest
from sqlalchemy import select

from app.modelos import Categoria, Material, PrestamoCabecera, SyncLote, Usuario
from app.modelos.sincronizacion import LOTE_CONFLICTO, LOTE_PENDIENTE
from app.sync import conflictos
from app.sync.cliente_central import ClienteCentral, ErrorSinConexion
from app.sync.motor import SinSesionCentral
from tests.ayudas_sync import (
    CLAVE_ADMIN,
    cabeceras,
    crear_equipo,
    crear_servidor,
    crear_usuario,
)


@pytest.fixture()
def servidor(tmp_path):
    """Servidor central con personal, un estudiante, una categoria y dos materiales."""
    servidor = crear_servidor(tmp_path)
    with servidor.sesion() as db:
        crear_usuario(db, "admin", "admin", "D-1")
        crear_usuario(db, "biblio", "bibliotecario", "D-2")
        crear_usuario(db, "ana", "estudiante", "D-3")
        categoria = Categoria(nombre="Equipos", plazo_prestamo_horas=4)
        db.add(categoria)
        db.commit()
        for codigo in ("PROY-1", "PROY-2"):
            db.add(Material(codigo=codigo, titulo=f"Proyector {codigo}", tipo_material="proyector", categoria_id=categoria.id))
        db.commit()
    return servidor


def _equipo_sincronizado(tmp_path, nombre, servidor, usuario="admin"):
    """Un equipo que ya descargo los datos del servidor."""
    equipo = crear_equipo(tmp_path, nombre, servidor)
    equipo.credenciales.recordar(usuario, CLAVE_ADMIN)
    equipo.motor.sincronizar()
    return equipo


def _por_nombre(db, modelo, campo, valor):
    return db.execute(select(modelo).where(getattr(modelo, campo) == valor)).scalar_one()


def _lotes(db, estado=None):
    consulta = select(SyncLote)
    if estado:
        consulta = consulta.where(SyncLote.estado == estado)
    return list(db.execute(consulta.order_by(SyncLote.creado_en)).scalars().all())


# ------------------------------------------------------------- descarga inicial
def test_primera_sincronizacion_descarga_todo_sin_crear_lotes(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    with equipo.sesion() as db:
        assert len(list(db.execute(select(Usuario)).scalars())) == 3
        assert len(list(db.execute(select(Material)).scalars())) == 2
        assert _lotes(db) == []  # lo descargado no vuelve a subirse


def test_la_contrasena_solo_viaja_para_el_personal(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    with equipo.sesion() as db:
        assert _por_nombre(db, Usuario, "username", "admin").contrasena_hash.startswith("$2")
        assert _por_nombre(db, Usuario, "username", "ana").contrasena_hash == "!"


def test_un_estudiante_con_hash_no_replicado_no_rompe_el_login(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    respuesta = equipo.http.post(
        "/api/auth/login", json={"correo_o_usuario": "ana", "contrasena": CLAVE_ADMIN}
    )

    assert respuesta.status_code == 401


def test_el_personal_inicia_sesion_sin_conexion_con_datos_replicados(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    respuesta = equipo.http.post(
        "/api/auth/login", json={"correo_o_usuario": "biblio", "contrasena": CLAVE_ADMIN}
    )

    assert respuesta.status_code == 200


# --------------------------------------------------------------------- captura
def test_un_cambio_local_queda_pendiente_y_se_envia(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        admin = _por_nombre(db, Usuario, "username", "admin")
        categoria_id = db.execute(select(Categoria.id)).scalar_one()

    respuesta = equipo.http.post(
        "/api/materiales/",
        json={"codigo": "LIB-9", "titulo": "Rayuela", "tipo_material": "libro", "categoria_id": str(categoria_id)},
        headers=cabeceras(admin),
    )
    assert respuesta.status_code == 201

    with equipo.sesion() as db:
        pendientes = _lotes(db, LOTE_PENDIENTE)
        assert len(pendientes) >= 1
        assert "LIB-9" in " ".join(p.descripcion for p in pendientes)

    resumen = equipo.motor.sincronizar()

    assert resumen.enviados >= 1 and resumen.conflictos == 0
    with servidor.sesion() as db:
        creado = _por_nombre(db, Material, "codigo", "LIB-9")
        assert creado.version == 1
    with equipo.sesion() as db:
        assert _lotes(db) == []
        assert _por_nombre(db, Material, "codigo", "LIB-9").version == 1


def test_editar_sube_la_version_en_ambos_lados(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        admin = _por_nombre(db, Usuario, "username", "admin")
        material = _por_nombre(db, Material, "codigo", "PROY-1")
        material_id = str(material.id)

    equipo.http.put(f"/api/materiales/{material_id}", json={"titulo": "Epson X49"}, headers=cabeceras(admin))
    equipo.motor.sincronizar()

    with servidor.sesion() as db:
        central = _por_nombre(db, Material, "codigo", "PROY-1")
        assert central.titulo == "Epson X49" and central.version == 2
    with equipo.sesion() as db:
        local = _por_nombre(db, Material, "codigo", "PROY-1")
        assert local.titulo == "Epson X49" and local.version == 2


def test_una_transaccion_es_un_solo_lote_y_un_rollback_no_deja_nada(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    with equipo.sesion() as db:
        db.add(Categoria(nombre="Temporal"))
        db.rollback()
        assert _lotes(db) == []

        db.add(Categoria(nombre="Revistas"))
        db.add(Categoria(nombre="Mapas"))
        db.commit()
        assert len(_lotes(db)) == 1  # las dos categorias viajan juntas


def test_los_inicios_de_sesion_no_generan_lotes(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)

    equipo.http.post("/api/auth/login", json={"correo_o_usuario": "admin", "contrasena": CLAVE_ADMIN})
    equipo.http.post("/api/auth/login", json={"correo_o_usuario": "admin", "contrasena": "mala"})

    with equipo.sesion() as db:
        assert _lotes(db) == []


# ---------------------------------------------------------------- descarga
def test_un_cambio_hecho_en_el_servidor_llega_al_equipo(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with servidor.sesion() as db:
        material = _por_nombre(db, Material, "codigo", "PROY-2")
        material.titulo = "Cambiado en el servidor"
        db.commit()

    resumen = equipo.motor.sincronizar()

    assert resumen.recibidos >= 1
    with equipo.sesion() as db:
        assert _por_nombre(db, Material, "codigo", "PROY-2").titulo == "Cambiado en el servidor"


def test_la_descarga_no_pisa_cambios_locales_sin_enviar(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        admin = _por_nombre(db, Usuario, "username", "admin")
        material_id = str(_por_nombre(db, Material, "codigo", "PROY-1").id)
    equipo.http.put(f"/api/materiales/{material_id}", json={"titulo": "Mi version"}, headers=cabeceras(admin))
    with servidor.sesion() as db:
        material = _por_nombre(db, Material, "codigo", "PROY-1")
        material.titulo = "Version del servidor"
        db.commit()

    resumen = equipo.motor.sincronizar()

    assert resumen.conflictos == 1
    with equipo.sesion() as db:
        assert _por_nombre(db, Material, "codigo", "PROY-1").titulo == "Mi version"
        assert len(_lotes(db, LOTE_CONFLICTO)) == 1


# --------------------------------------------------------------- conflictos
def _prestamo_directo(equipo, estudiante_id, material_id, admin):
    return equipo.http.post(
        "/api/prestamos/directo",
        json={"usuario_id": estudiante_id, "material_ids": [material_id]},
        headers=cabeceras(admin),
    )


def _datos_para_prestar(equipo):
    with equipo.sesion() as db:
        admin = _por_nombre(db, Usuario, "username", "admin")
        ana_id = str(_por_nombre(db, Usuario, "username", "ana").id)
        material_id = str(_por_nombre(db, Material, "codigo", "PROY-1").id)
    return admin, ana_id, material_id


def test_dos_equipos_prestan_la_misma_unidad_el_segundo_queda_en_conflicto(tmp_path, servidor):
    equipo_a = _equipo_sincronizado(tmp_path, "a", servidor)
    equipo_b = _equipo_sincronizado(tmp_path, "b", servidor)

    # Sin conexion, ambos prestan el mismo proyector.
    for equipo in (equipo_a, equipo_b):
        admin, ana_id, material_id = _datos_para_prestar(equipo)
        assert _prestamo_directo(equipo, ana_id, material_id, admin).status_code == 201

    assert equipo_a.motor.sincronizar().conflictos == 0
    resumen_b = equipo_b.motor.sincronizar()

    assert resumen_b.conflictos == 1
    with equipo_b.sesion() as db:
        en_conflicto = _lotes(db, LOTE_CONFLICTO)
        assert len(en_conflicto) == 1
        assert "cambio en el servidor" in en_conflicto[0].mensaje
        assert "Prestamo" in en_conflicto[0].descripcion
    with servidor.sesion() as db:
        assert len(list(db.execute(select(PrestamoCabecera)).scalars())) == 1  # solo el del equipo A


def test_descartar_el_conflicto_deja_el_equipo_igual_que_el_servidor(tmp_path, servidor):
    equipo_a = _equipo_sincronizado(tmp_path, "a", servidor)
    equipo_b = _equipo_sincronizado(tmp_path, "b", servidor)
    for equipo in (equipo_a, equipo_b):
        admin, ana_id, material_id = _datos_para_prestar(equipo)
        _prestamo_directo(equipo, ana_id, material_id, admin)
    equipo_a.motor.sincronizar()
    equipo_b.motor.sincronizar()

    with equipo_b.sesion() as db:
        lote = _lotes(db, LOTE_CONFLICTO)[0]
        cliente = ClienteCentral("http://central", http=servidor.http)
        cliente.iniciar_sesion("admin", CLAVE_ADMIN)
        descartados = conflictos.descartar(db, cliente, lote.id)
        assert descartados == 1

    equipo_b.motor.sincronizar()
    with equipo_b.sesion() as db:
        assert _lotes(db) == []
        prestamos = list(db.execute(select(PrestamoCabecera)).scalars())
        assert len(prestamos) == 1  # el del equipo A, descargado
        assert _por_nombre(db, Material, "codigo", "PROY-1").estado == "prestado"


def test_reintentar_devuelve_el_lote_a_la_bandeja_de_salida(tmp_path, servidor):
    equipo_a = _equipo_sincronizado(tmp_path, "a", servidor)
    equipo_b = _equipo_sincronizado(tmp_path, "b", servidor)
    for equipo in (equipo_a, equipo_b):
        admin, ana_id, material_id = _datos_para_prestar(equipo)
        _prestamo_directo(equipo, ana_id, material_id, admin)
    equipo_a.motor.sincronizar()
    equipo_b.motor.sincronizar()

    with equipo_b.sesion() as db:
        conflictos.reintentar(db, _lotes(db, LOTE_CONFLICTO)[0].id)
        assert len(_lotes(db, LOTE_PENDIENTE)) == 1
        assert _lotes(db, LOTE_CONFLICTO) == []


def test_enviar_dos_veces_el_mismo_lote_no_duplica(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        db.add(Categoria(nombre="Revistas"))
        db.commit()
        lote = _lotes(db)[0]
        carga = [{"id": str(lote.id), "filas": lote.filas}]

    cliente = ClienteCentral("http://central", http=servidor.http)
    cliente.iniciar_sesion("admin", CLAVE_ADMIN)
    primero = cliente.enviar_lotes(carga)
    segundo = cliente.enviar_lotes(carga)

    assert primero[0]["estado"] == segundo[0]["estado"] == "aplicado"
    with servidor.sesion() as db:
        assert len(list(db.execute(select(Categoria).where(Categoria.nombre == "Revistas")).scalars())) == 1


def test_un_bibliotecario_no_puede_enviar_cambios_de_usuarios(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        crear_usuario(db, "nuevo", "admin", "D-99")  # un administrador creado en el equipo
    equipo.credenciales.recordar("biblio", CLAVE_ADMIN)  # pero quien sincroniza es bibliotecario

    resumen = equipo.motor.sincronizar()

    assert resumen.conflictos == 1
    with equipo.sesion() as db:
        assert "rol" in _lotes(db, LOTE_CONFLICTO)[0].mensaje
    with servidor.sesion() as db:
        assert db.execute(select(Usuario).where(Usuario.username == "nuevo")).first() is None


def test_un_lote_automatico_rechazado_se_descarta_sin_molestar(tmp_path, servidor, reloj_prueba):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    admin, ana_id, material_id = _datos_para_prestar(equipo)
    _prestamo_directo(equipo, ana_id, material_id, admin)  # plazo de 4 horas
    equipo.motor.sincronizar()  # el servidor ya conoce el prestamo (activo)

    reloj_prueba.avanzar(hours=5)
    # Ambos lados detectan el vencimiento por su cuenta.
    equipo.http.get("/api/prestamos/", headers=cabeceras(admin))
    with servidor.sesion() as db:
        admin_central = _por_nombre(db, Usuario, "username", "admin")
    servidor.http.get("/api/prestamos/", headers=cabeceras(admin_central))

    resumen = equipo.motor.sincronizar()

    assert resumen.conflictos == 1
    with equipo.sesion() as db:
        assert _lotes(db) == []  # no queda nada que revisar
        local = db.execute(select(PrestamoCabecera)).scalar_one()
        assert local.estado == "vencido"
    with servidor.sesion() as db:
        central = db.execute(select(PrestamoCabecera)).scalar_one()
    assert local.version == central.version


# ------------------------------------------------------------------ conexion
def test_sin_credenciales_no_se_sincroniza(tmp_path, servidor):
    equipo = crear_equipo(tmp_path, "a", servidor)

    with pytest.raises(SinSesionCentral):
        equipo.motor.sincronizar()


def test_sin_conexion_los_cambios_siguen_pendientes(tmp_path, servidor):
    equipo = _equipo_sincronizado(tmp_path, "a", servidor)
    with equipo.sesion() as db:
        db.add(Categoria(nombre="Revistas"))
        db.commit()

    def sin_red(_url):
        raise ErrorSinConexion("sin red")

    equipo.motor._fabrica_cliente = sin_red
    with pytest.raises(ErrorSinConexion):
        equipo.motor.sincronizar()

    with equipo.sesion() as db:
        assert len(_lotes(db, LOTE_PENDIENTE)) == 1
