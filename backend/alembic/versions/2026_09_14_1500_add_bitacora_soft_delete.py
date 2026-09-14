"""Add bitacora and soft delete fields

Revision ID: a1b2c3d4e5f6
Revises: c67e6c828861
Create Date: 2026-09-14

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSONB


# revision identifiers, used by Alembic.
revision = 'a1b2c3d4e5f6'
down_revision = 'c67e6c828861'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create bitacora_acciones table
    op.create_table(
        'bitacora_acciones',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuarios.id'), nullable=True),
        sa.Column('accion', sa.String(50), nullable=False),
        sa.Column('tabla_afectada', sa.String(50), nullable=True),
        sa.Column('registro_id', UUID(as_uuid=True), nullable=True),
        sa.Column('detalles', JSONB, nullable=True),
        sa.Column('ip_address', sa.String(45), nullable=True),
        sa.Column('user_agent', sa.Text, nullable=True),
        sa.Column('fecha_accion', sa.DateTime, server_default=sa.func.now()),
    )
    
    # Create indexes for bitacora
    op.create_index('idx_bitacora_usuario', 'bitacora_acciones', ['usuario_id'])
    op.create_index('idx_bitacora_tabla', 'bitacora_acciones', ['tabla_afectada'])
    op.create_index('idx_bitacora_fecha', 'bitacora_acciones', ['fecha_accion'])
    
    # Add soft delete fields to usuarios
    op.add_column('usuarios', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('usuarios', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))
    
    # Add soft delete fields to categorias
    op.add_column('categorias', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('categorias', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))
    
    # Add soft delete fields to materiales
    op.add_column('materiales', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('materiales', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))
    
    # Add soft delete fields to prestamos_cabecera
    op.add_column('prestamos_cabecera', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('prestamos_cabecera', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))
    
    # Add soft delete fields to prestamos_detalle
    op.add_column('prestamos_detalle', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('prestamos_detalle', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))
    
    # Add soft delete fields to devoluciones
    op.add_column('devoluciones', sa.Column('eliminado', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('devoluciones', sa.Column('fecha_eliminacion', sa.DateTime(), nullable=True))


def downgrade() -> None:
    # Remove soft delete fields from devoluciones
    op.drop_column('devoluciones', 'fecha_eliminacion')
    op.drop_column('devoluciones', 'eliminado')
    
    # Remove soft delete fields from prestamos_detalle
    op.drop_column('prestamos_detalle', 'fecha_eliminacion')
    op.drop_column('prestamos_detalle', 'eliminado')
    
    # Remove soft delete fields from prestamos_cabecera
    op.drop_column('prestamos_cabecera', 'fecha_eliminacion')
    op.drop_column('prestamos_cabecera', 'eliminado')
    
    # Remove soft delete fields from materiales
    op.drop_column('materiales', 'fecha_eliminacion')
    op.drop_column('materiales', 'eliminado')
    
    # Remove soft delete fields from categorias
    op.drop_column('categorias', 'fecha_eliminacion')
    op.drop_column('categorias', 'eliminado')
    
    # Remove soft delete fields from usuarios
    op.drop_column('usuarios', 'fecha_eliminacion')
    op.drop_column('usuarios', 'eliminado')
    
    # Drop bitacora indexes
    op.drop_index('idx_bitacora_fecha')
    op.drop_index('idx_bitacora_tabla')
    op.drop_index('idx_bitacora_usuario')
    
    # Drop bitacora table
    op.drop_table('bitacora_acciones')
