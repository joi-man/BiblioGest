<#
.SYNOPSIS
  Crea la clave con la que se firma la app de Android (una sola vez).

.DESCRIPTION
  Android solo deja actualizar una app si el APK nuevo esta firmado con la MISMA clave
  que el instalado. Por eso esta clave se crea una vez y se guarda para siempre.

  Genera:
    %USERPROFILE%\.bibliogest\bibliogest-release.jks   la clave (fuera del repositorio)
    frontend\android\key.properties                    como encontrarla (ignorado por git)

  !! HAZ UNA COPIA DE SEGURIDAD de la carpeta %USERPROFILE%\.bibliogest (por ejemplo en un
  gestor de contrasenas o en un disco aparte) y guarda la contrasena. Si se pierde, los
  telefonos con la app instalada NO podran actualizarla: habria que desinstalar e instalar
  otra vez. Nunca la subas a git ni la compartas.

.EXAMPLE
  .\scripts\crear_keystore.ps1
#>
param(
    # Nombre del propietario de la clave (aparece en el certificado).
    [string]$Nombre = "BiblioGest",
    # Anos de validez. Google recomienda 25 o mas.
    [int]$ValidezAnios = 30
)

$ErrorActionPreference = "Stop"
$raiz = Split-Path $PSScriptRoot -Parent
$carpeta = Join-Path $env:USERPROFILE ".bibliogest"
$jks = Join-Path $carpeta "bibliogest-release.jks"
$propiedades = Join-Path $raiz "frontend\android\key.properties"

if (Test-Path $jks) {
    throw "Ya existe $jks. No se sobrescribe: si se pierde la clave original, la app instalada no podria actualizarse."
}

# keytool viene con el JDK que usa Android Studio / Flutter.
$candidatos = @()
if ($env:JAVA_HOME) { $candidatos += (Join-Path $env:JAVA_HOME "bin\keytool.exe") }
$candidatos += @(
    "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
    "$env:ProgramFiles\Android\Android Studio1\jbr\bin\keytool.exe"
)
$enRuta = Get-Command keytool -ErrorAction SilentlyContinue
if ($enRuta) { $candidatos = @($enRuta.Source) + $candidatos }
$keytool = $candidatos | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $keytool) { throw "No se encontro keytool. Instala Android Studio o define JAVA_HOME." }

function LeerClave($mensaje) {
    $segura = Read-Host $mensaje -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($segura)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

$clave = LeerClave "Elige una contrasena para la clave (minimo 6 caracteres)"
$repetida = LeerClave "Repitela"
if ($clave -ne $repetida) { throw "Las contrasenas no coinciden." }
if ($clave.Length -lt 6) { throw "La contrasena debe tener al menos 6 caracteres." }

New-Item -ItemType Directory -Force $carpeta | Out-Null
& $keytool -genkeypair -v -keystore $jks -alias bibliogest -keyalg RSA -keysize 2048 `
    -validity ($ValidezAnios * 365) -storepass $clave -keypass $clave `
    -dname "CN=$Nombre, O=$Nombre, C=ES"
if ($LASTEXITCODE -ne 0) { throw "keytool fallo (codigo $LASTEXITCODE)" }

# gradle lee las rutas con barras normales.
$rutaGradle = $jks.Replace("\", "/")
$contenido = @(
    "storeFile=$rutaGradle",
    "storePassword=$clave",
    "keyAlias=bibliogest",
    "keyPassword=$clave"
) -join "`n"
[System.IO.File]::WriteAllText($propiedades, $contenido + "`n", (New-Object System.Text.UTF8Encoding($false)))

Write-Host "`nListo." -ForegroundColor Green
Write-Host "  Clave:       $jks"
Write-Host "  Propiedades: $propiedades (no se sube a git)"
Write-Host "`nAHORA: copia $carpeta a un lugar seguro y guarda la contrasena." -ForegroundColor Yellow
