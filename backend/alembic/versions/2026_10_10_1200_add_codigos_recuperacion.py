"""Add codigos_recuperacion table

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-10-10

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID


# revision identifiers, used by Alembic.
revision = 'b2c3d4e5f6a7'
down_revision = 'a1b2c3d4e5f6'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'codigos_recuperacion',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuarios.id'), nullable=False),
        sa.Column('codigo_hash', sa.String(255), nullable=False),
        sa.Column('expira_en', sa.DateTime, nullable=False),
        sa.Column('usado', sa.Boolean, nullable=False, server_default='false'),
        sa.Column('intentos', sa.Integer, nullable=False, server_default='0'),
        sa.Column('fecha_creacion', sa.DateTime, server_default=sa.func.now()),
    )
    op.create_index('ix_codigos_recuperacion_usuario_id', 'codigos_recuperacion', ['usuario_id'])


def downgrade() -> None:
    op.drop_index('ix_codigos_recuperacion_usuario_id')
    op.drop_table('codigos_recuperacion')
