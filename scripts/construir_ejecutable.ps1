<#
.SYNOPSIS
  Construye el instalador de BiblioGest para Windows.

.DESCRIPTION
  1. Empaqueta el backend (Python + SQLite) en un .exe con PyInstaller.
  2. Compila la aplicacion Flutter para Windows (Release).
  3. Copia el backend dentro de la carpeta de la aplicacion (subcarpeta backend).
  4. Genera el instalador con Inno Setup.

  Resultado: build\instalador\BiblioGest-Setup-<version>.exe

  Requisitos (una sola vez): ver docs\ejecutable-offline.md
    - Modo desarrollador de Windows activado (Flutter lo necesita para los plugins).
    - Visual Studio Build Tools con "Desarrollo para el escritorio con C++".
    - Inno Setup 6 (winget install JRSoftware.InnoSetup).
    - Entorno virtual del backend con sus dependencias (backend\.venv).

.EXAMPLE
  .\scripts\construir_ejecutable.ps1 -Version 1.0.0
#>
param(
    [string]$Version = "1.0.0",
    # Flutter a usar. Hace falta una version que reconozca tu Visual Studio
    # (Visual Studio 2026 necesita Flutter 3.4x o mas nuevo).
    [string]$Flutter = "flutter",
    # Solo empaqueta el backend (util para probarlo sin compilar Flutter).
    [switch]$SoloBackend
)

# Los programas externos (pip, flutter...) escriben avisos en stderr; en PowerShell 5.1 eso
# detendria el script aunque todo vaya bien. Se controla cada paso por su codigo de salida.
$ErrorActionPreference = "Continue"
$raiz = Split-Path $PSScriptRoot -Parent
$backend = Join-Path $raiz "backend"
$frontend = Join-Path $raiz "frontend"
$salida = Join-Path $raiz "build\ejecutable"
$python = Join-Path $backend ".venv\Scripts\python.exe"

function Paso($texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }

function Verificar($comando, $mensaje) {
    if ($LASTEXITCODE -ne 0) { throw "$mensaje (codigo $LASTEXITCODE)" }
}

# ------------------------------------------------------------------ 1. Backend
Paso "Empaquetando el backend (PyInstaller)"
if (-not (Test-Path $python)) { throw "No existe $python. Crea el entorno: cd backend; python -m venv .venv; pip install -r requirements.txt" }

& $python -m pip install --quiet pyinstaller
Verificar "pip" "No se pudo instalar PyInstaller"

if (Test-Path $salida) { Remove-Item $salida -Recurse -Force -ErrorAction Stop }
New-Item -ItemType Directory -Force "$salida\work", "$salida\spec" -ErrorAction Stop | Out-Null

Push-Location $backend
try {
    & $python -m PyInstaller --noconfirm --clean --onedir --name bibliogest-backend --console `
        --distpath "$salida\dist" --workpath "$salida\work" --specpath "$salida\spec" `
        --paths . --collect-submodules uvicorn --collect-submodules passlib.handlers `
        --hidden-import main --hidden-import email_validator --hidden-import sqlalchemy.dialects.sqlite `
        --collect-data reportlab `
        --exclude-module psycopg --exclude-module psycopg_binary --exclude-module alembic `
        --exclude-module pytest --exclude-module tkinter `
        local_main.py
    Verificar "PyInstaller" "Fallo el empaquetado del backend"
} finally { Pop-Location }

$backendEmpaquetado = Join-Path $salida "dist\bibliogest-backend"
Write-Host "Backend listo: $backendEmpaquetado"
if ($SoloBackend) { return }

# ------------------------------------------------------------------ 2. Flutter
Paso "Compilando la aplicacion para Windows (Flutter)"
Push-Location $frontend
try {
    & $Flutter pub get
    Verificar "flutter" "Fallo flutter pub get"
    & $Flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la compilacion de Windows. Si el mensaje habla de 'symlink', activa el Modo desarrollador (start ms-settings:developers). Si dice que no encuentra Visual Studio, instala el componente 'Desarrollo para el escritorio con C++' o usa un Flutter mas nuevo con -Flutter <ruta>inlutter.bat."
    }
} finally { Pop-Location }

$release = Join-Path $frontend "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $release "BiblioGest.exe"))) { throw "No se genero BiblioGest.exe en $release" }

# ------------------------------------------------------- 3. Juntar los programas
Paso "Copiando el backend dentro de la aplicacion"
$destinoBackend = Join-Path $release "backend"
if (Test-Path $destinoBackend) { Remove-Item $destinoBackend -Recurse -Force }
Copy-Item $backendEmpaquetado $destinoBackend -Recurse

# ----------------------------------------------------------- 4. Instalador
Paso "Generando el instalador (Inno Setup)"
$candidatos = @(
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
)
$iscc = $candidatos | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw "No se encontro Inno Setup. Instalalo con: winget install JRSoftware.InnoSetup" }

& $iscc "/DVersion=$Version" "/DOrigen=$release" (Join-Path $raiz "instalador\bibliogest.iss")
Verificar "ISCC" "Fallo la generacion del instalador"

$instalador = Join-Path $raiz "build\instalador\BiblioGest-Setup-$Version.exe"
Write-Host "`nListo: $instalador" -ForegroundColor Green
