<#
.SYNOPSIS
  Construye el APK de BiblioGest para Android y el manifiesto de actualizaciones.

.DESCRIPTION
  1. Compila la app de Android (release) apuntando al servidor indicado.
  2. Verifica que el APK este firmado con la clave de release (no con la de depuracion).
  3. Genera y firma el manifiesto de actualizaciones (latest-android.json) con la misma
     clave Ed25519 que usa el ejecutable de Windows.

  Resultado, en build\apk\ (esto se sube al MISMO Release que el instalador de Windows):
    BiblioGest-<version>.apk     el APK que descargan y actualizan los telefonos
    BiblioGest.apk               copia con nombre fijo: es el enlace de descarga de la web
    latest-android.json          manifiesto: ultima version, minima soportada, huella SHA-256
    latest-android.json.sig      firma del manifiesto

  La version sale de frontend\pubspec.yaml. Ver docs\app-movil.md.

  Requisitos (una sola vez):
    - Android SDK con las licencias aceptadas: flutter doctor --android-licenses
    - Clave de firma: .\scripts\crear_keystore.ps1
    - Clave de firma de actualizaciones (la misma de Windows, ver docs\actualizaciones.md)

.EXAMPLE
  .\scripts\construir_apk.ps1 -ApiUrl https://bibliogest-api.onrender.com
  .\scripts\construir_apk.ps1 -ApiUrl https://bibliogest-api.onrender.com -Minima 0.11.0 -Notas "Corrige un error grave."
#>
param(
    # Direccion (https) del servidor central. Tambien se puede dejar en la variable de
    # entorno BIBLIOGEST_API_URL.
    [string]$ApiUrl = $env:BIBLIOGEST_API_URL,
    [string]$Version = "",
    # Version mas antigua que puede seguir usandose (actualizacion obligatoria).
    # "0.0.0" = nunca obliga. Se arrastra: si una version anterior ya exigia una, indicala otra vez.
    [string]$Minima = "0.0.0",
    # Texto de "Novedades" que ve el usuario al actualizar.
    [string]$Notas = "",
    # Direccion (https) donde se publicara el APK. Debe terminar en "/".
    [string]$UrlBase = "https://github.com/joi-man/BiblioGest-releases/releases/download/v{version}/",
    # Permite compilar con la clave de depuracion (SOLO PRUEBAS: ese APK no se puede publicar).
    [switch]$SinFirmaDeRelease,
    [string]$Flutter = "flutter"
)

$ErrorActionPreference = "Continue"
$raiz = Split-Path $PSScriptRoot -Parent
$frontend = Join-Path $raiz "frontend"
$salida = Join-Path $raiz "build\apk"

function Paso($texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }
function Verificar($mensaje) { if ($LASTEXITCODE -ne 0) { throw "$mensaje (codigo $LASTEXITCODE)" } }

$lineaVersion = Select-String -Path (Join-Path $frontend "pubspec.yaml") -Pattern '^version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?' | Select-Object -First 1
if (-not $lineaVersion) { throw "No se encontro la version en frontend\pubspec.yaml" }
$versionPubspec = $lineaVersion.Matches[0].Groups[1].Value
$numeroCompilacion = $lineaVersion.Matches[0].Groups[2].Value
if ($Version -eq "") { $Version = $versionPubspec }
if ($Version -ne $versionPubspec) { throw "La version indicada ($Version) no coincide con frontend\pubspec.yaml ($versionPubspec). Cambia el pubspec." }
if ($Minima -notmatch '^\d+\.\d+\.\d+$') { throw "-Minima debe tener el formato mayor.menor.parche" }
if (-not $ApiUrl) { throw "Falta la direccion del servidor: usa -ApiUrl https://tu-api.onrender.com (o la variable BIBLIOGEST_API_URL)." }
if ($ApiUrl -notmatch '^https://') { throw "-ApiUrl debe empezar con https:// (Android no permite http en una app publicada)." }

$propiedades = Join-Path $frontend "android\key.properties"
$hayClave = Test-Path $propiedades
if (-not $hayClave -and -not $SinFirmaDeRelease) {
    throw "No hay clave de firma (frontend\android\key.properties). Crea una con .\scripts\crear_keystore.ps1. Sin ella, los telefonos no podrian actualizar la app."
}
if (-not $hayClave) { Write-Host "AVISO: se firmara con la clave de depuracion. No publiques este APK." -ForegroundColor Yellow }

# ------------------------------------------------------------------ 1. Flutter
Paso "Compilando la app de Android (Flutter, release)"
Push-Location $frontend
try {
    & $Flutter pub get
    Verificar "Fallo flutter pub get"
    $argumentos = @("--build-name", $Version, "--dart-define=API_URL=$ApiUrl")
    if ($numeroCompilacion) { $argumentos += @("--build-number", $numeroCompilacion) }
    & $Flutter build apk --release @argumentos
    Verificar "Fallo la compilacion de Android. Si habla de licencias: flutter doctor --android-licenses"
} finally { Pop-Location }

$apkCompilado = Join-Path $frontend "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkCompilado)) { throw "No se genero $apkCompilado" }

# --------------------------------------------------------------- 2. Copiar
if (Test-Path $salida) { Remove-Item $salida -Recurse -Force }
New-Item -ItemType Directory -Force $salida | Out-Null
$apk = Join-Path $salida "BiblioGest-$Version.apk"
Copy-Item $apkCompilado $apk
Copy-Item $apkCompilado (Join-Path $salida "BiblioGest.apk")

# --------------------------------------------------------------- 3. Manifiesto
Paso "Generando y firmando el manifiesto de actualizaciones"
if (-not $UrlBase.EndsWith("/")) { $UrlBase += "/" }
$archivo = Get-Item $apk
$manifiesto = [ordered]@{
    version = $Version
    minima  = $Minima
    url     = ($UrlBase.Replace("{version}", $Version) + $archivo.Name)
    sha256  = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLower()
    tamano  = [int64]$archivo.Length
    notas   = $Notas
    fecha   = (Get-Date -Format "yyyy-MM-dd")
}
$rutaManifiesto = Join-Path $salida "latest-android.json"
# UTF-8 sin BOM: la firma se calcula sobre los bytes exactos de este archivo.
[System.IO.File]::WriteAllText($rutaManifiesto, ($manifiesto | ConvertTo-Json), (New-Object System.Text.UTF8Encoding($false)))

$dart = if ($Flutter -match "flutter(\.bat)?$" -and $Flutter -ne "flutter") { Join-Path (Split-Path $Flutter -Parent) "dart.bat" } else { "dart" }
Push-Location $frontend
try {
    & $dart run tool/firmar_manifiesto.dart $rutaManifiesto
    Verificar "No se pudo firmar el manifiesto (genera la clave con: dart run tool/generar_clave_actualizaciones.dart)"
} finally { Pop-Location }

Write-Host "`nListo: $apk" -ForegroundColor Green
Write-Host "Sube a Release v$Version (el mismo del instalador de Windows): BiblioGest-$Version.apk, BiblioGest.apk, latest-android.json y latest-android.json.sig"
