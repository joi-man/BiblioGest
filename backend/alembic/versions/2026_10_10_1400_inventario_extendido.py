"""Inventario extendido: campos de equipos y plazo de prestamo

Agrega a `materiales` los datos propios de equipos (marca, modelo, serie,
ubicacion, accesorios), la gestion de la unidad (condicion, valor,
si es prestable, plazo propio) y a `categorias` el plazo de prestamo
por defecto.

Revision ID: c3d4e5f6a7b8
Revises: b2c3d4e5f6a7
Create Date: 2026-10-10

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'c3d4e5f6a7b8'
down_revision = 'b2c3d4e5f6a7'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Materiales: datos de equipos
    op.add_column('materiales', sa.Column('marca', sa.String(100), nullable=True))
    op.add_column('materiales', sa.Column('modelo', sa.String(100), nullable=True))
    op.add_column('materiales', sa.Column('numero_serie', sa.String(100), nullable=True))
    op.add_column('materiales', sa.Column('ubicacion', sa.String(150), nullable=True))
    op.add_column('materiales', sa.Column('accesorios', sa.Text(), nullable=True))

    # Materiales: gestion de la unidad fisica
    op.add_column('materiales', sa.Column('condicion', sa.String(20), nullable=False, server_default='bueno'))
    op.add_column('materiales', sa.Column('valor_referencial', sa.Numeric(10, 2), nullable=True))
    op.add_column('materiales', sa.Column('es_prestable', sa.Boolean(), nullable=False, server_default='true'))
    op.add_column('materiales', sa.Column('plazo_prestamo_horas', sa.Integer(), nullable=True))

    # Categorias: plazo de prestamo por defecto
    op.add_column('categorias', sa.Column('plazo_prestamo_horas', sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column('categorias', 'plazo_prestamo_horas')

    op.drop_column('materiales', 'plazo_prestamo_horas')
    op.drop_column('materiales', 'es_prestable')
    op.drop_column('materiales', 'valor_referencial')
    op.drop_column('materiales', 'condicion')

    op.drop_column('materiales', 'accesorios')
    op.drop_column('materiales', 'ubicacion')
    op.drop_column('materiales', 'numero_serie')
    op.drop_column('materiales', 'modelo')
    op.drop_column('materiales', 'marca')
