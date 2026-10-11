"""Sincronizacion con el ejecutable de escritorio

- Todas las tablas replicadas ganan `version` (cuenta los cambios de la fila,
  para detectar conflictos) y `fecha_actualizacion` (orden de descarga).
- sync_lotes_recibidos: lotes ya aplicados, para que un reintento no duplique.

Los equipos con el ejecutable usan SQLite y crean su esquema solos; esta
migracion es solo para el servidor central (PostgreSQL).

Revision ID: e5f6a7b8c9d0
Revises: d4e5f6a7b8c9
Create Date: 2026-10-11

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID


# revision identifiers, used by Alembic.
revision = 'e5f6a7b8c9d0'
down_revision = 'd4e5f6a7b8c9'
branch_labels = None
depends_on = None

TABLAS_CON_VERSION = (
    'usuarios',
    'categorias',
    'materiales',
    'prestamos_cabecera',
    'prestamos_detalle',
    'devoluciones',
)
# Tablas que todavia no tenian fecha_actualizacion.
TABLAS_SIN_FECHA_ACTUALIZACION = ('categorias', 'prestamos_detalle', 'devoluciones')


def _columnas(tabla: str) -> set:
    return {c['name'] for c in sa.inspect(op.get_bind()).get_columns(tabla)}


def upgrade() -> None:
    # Se comprueba antes de agregar porque `create_all` del arranque puede haber
    # creado ya algunas columnas o tablas (ver README, seccion Migraciones).
    for tabla in TABLAS_SIN_FECHA_ACTUALIZACION:
        if 'fecha_actualizacion' not in _columnas(tabla):
            op.add_column(tabla, sa.Column('fecha_actualizacion', sa.DateTime(), nullable=True))
        # Las filas existentes quedan como "modificadas al crearse".
        op.execute(
            f"UPDATE {tabla} SET fecha_actualizacion = COALESCE(fecha_creacion, NOW()) "
            "WHERE fecha_actualizacion IS NULL"
        )

    for tabla in TABLAS_CON_VERSION:
        if 'version' not in _columnas(tabla):
            op.add_column(
                tabla,
                sa.Column('version', sa.Integer(), nullable=False, server_default='1'),
            )

    if not sa.inspect(op.get_bind()).has_table('sync_lotes_recibidos'):
        op.create_table(
            'sync_lotes_recibidos',
            sa.Column('id', UUID(as_uuid=True), primary_key=True),
            sa.Column('recibido_en', sa.DateTime(), nullable=False),
            sa.Column('usuario_id', UUID(as_uuid=True), nullable=True),
        )

    # Indices para la descarga incremental (filtra y ordena por fecha_actualizacion).
    for tabla in TABLAS_CON_VERSION:
        op.create_index(f'ix_{tabla}_fecha_actualizacion', tabla, ['fecha_actualizacion'], if_not_exists=True)


def downgrade() -> None:
    for tabla in TABLAS_CON_VERSION:
        op.drop_index(f'ix_{tabla}_fecha_actualizacion', table_name=tabla, if_exists=True)
        op.drop_column(tabla, 'version')
    for tabla in TABLAS_SIN_FECHA_ACTUALIZACION:
        op.drop_column(tabla, 'fecha_actualizacion')
    op.drop_table('sync_lotes_recibidos')
