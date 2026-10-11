<#
.SYNOPSIS
  Construye el instalador de BiblioGest para Windows.

.DESCRIPTION
  1. Empaqueta el backend (Python + SQLite) en un .exe con PyInstaller.
  2. Compila la aplicacion Flutter para Windows (Release).
  3. Copia el backend dentro de la carpeta de la aplicacion (subcarpeta backend).
  4. Genera el instalador con Inno Setup.

  Resultado, en build\instalador\ (esto es lo que se publica como una version):
    BiblioGest-Setup-<version>.exe   el instalador
    latest.json                      manifiesto: ultima version, minima soportada, huella SHA-256
    latest.json.sig                  firma del manifiesto (clave privada, ver docs\actualizaciones.md)

  La version sale de frontend\pubspec.yaml (campo version). Para un lanzamiento:
  subir la version en el pubspec, ejecutar este script y publicar los tres archivos.

  Requisitos (una sola vez): ver docs\ejecutable-offline.md
    - Modo desarrollador de Windows activado (Flutter lo necesita para los plugins).
    - Visual Studio Build Tools con "Desarrollo para el escritorio con C++".
    - Inno Setup 6 (winget install JRSoftware.InnoSetup).
    - Entorno virtual del backend con sus dependencias (backend\.venv).

.EXAMPLE
  .\scripts\construir_ejecutable.ps1
  .\scripts\construir_ejecutable.ps1 -Minima 0.9.1 -Notas "Corrige el cierre de caja."
#>
param(
    # Por defecto, la version de frontend\pubspec.yaml.
    [string]$Version = "",
    # Version mas antigua que puede seguir usandose. Quien tenga una anterior debe
    # actualizar para continuar (actualizacion obligatoria). "0.0.0" = nunca obliga.
    # Se arrastra: si una version anterior ya exigia 0.9.1, vuelve a indicarlo aqui.
    [string]$Minima = "0.0.0",
    # Texto de "Novedades" que ve el usuario al actualizar.
    [string]$Notas = "",
    # Direccion (https) donde se publicara el instalador. Debe terminar en "/".
    [string]$UrlBase = "https://github.com/joi-man/BiblioGest-releases/releases/download/v{version}/",
    # No genera ni firma el manifiesto (solo el instalador).
    [switch]$SinManifiesto,
    # SOLO PRUEBAS: identificador distinto de la aplicacion, para instalar una copia
    # de prueba sin pisar la instalacion real. Ejemplo: "{{GUID-de-prueba}".
    [string]$IdApp = "",
    # SOLO PRUEBAS: opciones --dart-define extra, por ejemplo URL_ACTUALIZACIONES=http://127.0.0.1:8777/latest.json
    [string[]]$DartDefine = @(),
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

# La version manda en pubspec.yaml: asi el .exe, el instalador y las actualizaciones coinciden.
$lineaVersion = Select-String -Path (Join-Path $frontend "pubspec.yaml") -Pattern '^version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?' | Select-Object -First 1
if (-not $lineaVersion) { throw "No se encontro la version en frontend\pubspec.yaml" }
$versionPubspec = $lineaVersion.Matches[0].Groups[1].Value
$numeroCompilacion = $lineaVersion.Matches[0].Groups[2].Value
if ($Version -eq "") { $Version = $versionPubspec }
if ($Version -ne $versionPubspec) { throw "La version indicada ($Version) no coincide con frontend\pubspec.yaml ($versionPubspec). Cambia el pubspec." }
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "La version debe tener el formato mayor.menor.parche (por ejemplo 0.9.1)" }
if ($Minima -notmatch '^\d+\.\d+\.\d+$') { throw "-Minima debe tener el formato mayor.menor.parche" }

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
    $argsVersion = @("--build-name", $Version)
    if ($numeroCompilacion) { $argsVersion += @("--build-number", $numeroCompilacion) }
    foreach ($d in $DartDefine) { $argsVersion += "--dart-define=$d" }
    & $Flutter build windows --release @argsVersion
    if ($LASTEXITCODE -ne 0) {
        # Una carpeta build a medias de otra version de Flutter suele ser la causa
        # (por ejemplo "file INSTALL cannot find ...\native_assets\windows"): se limpia y se reintenta.
        Write-Host "La compilacion fallo; se limpia la carpeta build y se reintenta una vez..." -ForegroundColor Yellow
        & $Flutter clean
        & $Flutter pub get
        Verificar "flutter" "Fallo flutter pub get tras limpiar"
        & $Flutter build windows --release @argsVersion
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la compilacion de Windows. Si el mensaje habla de 'symlink', activa el Modo desarrollador (start ms-settings:developers). Si dice que no encuentra Visual Studio, instala el componente 'Desarrollo para el escritorio con C++' o usa un Flutter mas nuevo con -Flutter <ruta>\bin\flutter.bat."
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

$argsInno = @("/DVersion=$Version", "/DOrigen=$release")
if ($IdApp -ne "") { $argsInno += "/DIdApp=$IdApp" }
& $iscc @argsInno (Join-Path $raiz "instalador\bibliogest.iss")
Verificar "ISCC" "Fallo la generacion del instalador"

$instalador = Join-Path $raiz "build\instalador\BiblioGest-Setup-$Version.exe"

# ------------------------------------------- 5. Manifiesto de actualizaciones
if (-not $SinManifiesto) {
    Paso "Generando y firmando el manifiesto de actualizaciones"
    if (-not $UrlBase.EndsWith("/")) { $UrlBase += "/" }
    $archivo = Get-Item $instalador
    $manifiesto = [ordered]@{
        version = $Version
        minima  = $Minima
        url     = ($UrlBase.Replace("{version}", $Version) + $archivo.Name)
        sha256  = (Get-FileHash $instalador -Algorithm SHA256).Hash.ToLower()
        tamano  = [int64]$archivo.Length
        notas   = $Notas
        fecha   = (Get-Date -Format "yyyy-MM-dd")
    }
    $rutaManifiesto = Join-Path $raiz "build\instalador\latest.json"
    # UTF-8 sin BOM: la firma se calcula sobre los bytes exactos de este archivo.
    [System.IO.File]::WriteAllText($rutaManifiesto, ($manifiesto | ConvertTo-Json), (New-Object System.Text.UTF8Encoding($false)))

    $dart = if ($Flutter -match "flutter(\.bat)?$" -and $Flutter -ne "flutter") { Join-Path (Split-Path $Flutter -Parent) "dart.bat" } else { "dart" }
    Push-Location $frontend
    try {
        & $dart run tool/firmar_manifiesto.dart $rutaManifiesto
        Verificar "dart" "No se pudo firmar el manifiesto (genera la clave con: dart run tool/generar_clave_actualizaciones.dart)"
    } finally { Pop-Location }
    Write-Host "Manifiesto: $rutaManifiesto"
}

Write-Host "`nListo: $instalador" -ForegroundColor Green
