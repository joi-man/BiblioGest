"""Prestamos: flujo de solicitud, aprobacion, entrega y devolucion con fecha y hora

- prestamos_cabecera: las fechas pasan de DATE a TIMESTAMP, la fecha de
  prestamo y la esperada pasan a ser opcionales (una solicitud pendiente aun
  no tiene entrega) y se agregan los campos del flujo.
- prestamos_detalle: fecha limite de devolucion propia de cada item.
- devoluciones: quien recibio, dias de retraso y multa opcional.

Revision ID: d4e5f6a7b8c9
Revises: c3d4e5f6a7b8
Create Date: 2026-10-10

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID


# revision identifiers, used by Alembic.
revision = 'd4e5f6a7b8c9'
down_revision = 'c3d4e5f6a7b8'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # --- prestamos_cabecera: fechas con hora ---
    for columna in ('fecha_prestamo', 'fecha_devolucion_esperada', 'fecha_devolucion_real'):
        op.alter_column(
            'prestamos_cabecera', columna,
            type_=sa.DateTime(),
            existing_type=sa.Date(),
            existing_nullable=(columna == 'fecha_devolucion_real'),
            nullable=True,
            postgresql_using=f'{columna}::timestamp',
        )
    op.alter_column('prestamos_cabecera', 'estado', server_default='pendiente')

    # --- prestamos_cabecera: campos del flujo ---
    op.add_column('prestamos_cabecera', sa.Column(
        'fecha_solicitud', sa.DateTime(), nullable=False, server_default=sa.func.now()))
    op.add_column('prestamos_cabecera', sa.Column('fecha_retiro_limite', sa.DateTime(), nullable=True))
    op.add_column('prestamos_cabecera', sa.Column(
        'aprobado_por_id', UUID(as_uuid=True), sa.ForeignKey('usuarios.id'), nullable=True))
    op.add_column('prestamos_cabecera', sa.Column(
        'entregado_por_id', UUID(as_uuid=True), sa.ForeignKey('usuarios.id'), nullable=True))
    op.add_column('prestamos_cabecera', sa.Column('motivo_rechazo', sa.Text(), nullable=True))

    # --- prestamos_detalle ---
    op.add_column('prestamos_detalle', sa.Column('fecha_devolucion_esperada', sa.DateTime(), nullable=True))

    # --- devoluciones ---
    op.add_column('devoluciones', sa.Column(
        'recibido_por_id', UUID(as_uuid=True), sa.ForeignKey('usuarios.id'), nullable=True))
    op.add_column('devoluciones', sa.Column(
        'dias_retraso', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('devoluciones', sa.Column('multa_monto', sa.Numeric(10, 2), nullable=True))


def downgrade() -> None:
    op.drop_column('devoluciones', 'multa_monto')
    op.drop_column('devoluciones', 'dias_retraso')
    op.drop_column('devoluciones', 'recibido_por_id')

    op.drop_column('prestamos_detalle', 'fecha_devolucion_esperada')

    op.drop_column('prestamos_cabecera', 'motivo_rechazo')
    op.drop_column('prestamos_cabecera', 'entregado_por_id')
    op.drop_column('prestamos_cabecera', 'aprobado_por_id')
    op.drop_column('prestamos_cabecera', 'fecha_retiro_limite')
    op.drop_column('prestamos_cabecera', 'fecha_solicitud')
    op.alter_column('prestamos_cabecera', 'estado', server_default='activo')

    # Al volver a DATE se pierde la hora; los campos que eran obligatorios
    # quedan nulos en solicitudes sin entregar, por eso se rellenan antes.
    op.execute("UPDATE prestamos_cabecera SET fecha_prestamo = COALESCE(fecha_prestamo, fecha_solicitud)")
    op.execute(
        "UPDATE prestamos_cabecera SET fecha_devolucion_esperada = "
        "COALESCE(fecha_devolucion_esperada, fecha_solicitud)"
    )
    for columna in ('fecha_prestamo', 'fecha_devolucion_esperada', 'fecha_devolucion_real'):
        op.alter_column(
            'prestamos_cabecera', columna,
            type_=sa.Date(),
            existing_type=sa.DateTime(),
            nullable=(columna == 'fecha_devolucion_real'),
            postgresql_using=f'{columna}::date',
        )
