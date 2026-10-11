FROM python:3.12-slim

WORKDIR /app

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivo de requerimientos e instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código del proyecto
COPY . .

EXPOSE 8000

# Render define $PORT (en local queda 8000). Las migraciones solo corren si
# EJECUTAR_MIGRACIONES=1 (produccion); en local no cambia nada.
CMD ["sh", "-c", "if [ \"$EJECUTAR_MIGRACIONES\" = \"1\" ]; then alembic upgrade head; fi && uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
