; Instalador de BiblioGest para Windows (Inno Setup 6).
;
; No se compila a mano: lo hace scripts\construir_ejecutable.ps1, que le pasa
;   /DVersion=1.0.0
;   /DOrigen=<carpeta con BiblioGest.exe y la subcarpeta backend>
;
; Se instala para el usuario actual (sin permisos de administrador) en
; %LOCALAPPDATA%\Programs\BiblioGest. Los datos de la biblioteca viven aparte, en
; %LOCALAPPDATA%\BiblioGest, y NO se borran al desinstalar ni al actualizar.
;
; Actualizaciones: la aplicacion descarga una version nueva y ejecuta este mismo
; instalador sobre la instalacion existente (mismo AppId) con
;   /SILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS /RELANZAR=1

#ifndef Version
  #define Version "1.0.0"
#endif
#ifndef IdApp
  ; Solo las pruebas lo cambian, para no pisar una instalacion real.
  #define IdApp "{{6F1B8C52-4E0A-4B2D-9C47-5B3E0D7A91C4}"
#endif
#ifndef Origen
  #error Falta /DOrigen=<carpeta del programa compilado>
#endif

[Setup]
AppId={#IdApp}
AppName=BiblioGest
AppVersion={#Version}
AppPublisher=BiblioGest
DefaultDirName={localappdata}\Programs\BiblioGest
DefaultGroupName=BiblioGest
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\build\instalador
OutputBaseFilename=BiblioGest-Setup-{#Version}
SetupIconFile=..\frontend\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName=BiblioGest
UninstallDisplayIcon={app}\BiblioGest.exe
; Si el programa esta abierto al actualizar, el instalador ofrece cerrarlo.
CloseApplications=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "iconoescritorio"; Description: "Crear un acceso directo en el escritorio"; GroupDescription: "Accesos directos:"

[Files]
Source: "{#Origen}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\BiblioGest"; Filename: "{app}\BiblioGest.exe"
Name: "{autodesktop}\BiblioGest"; Filename: "{app}\BiblioGest.exe"; Tasks: iconoescritorio

[Run]
Filename: "{app}\BiblioGest.exe"; Description: "Abrir BiblioGest"; Flags: nowait postinstall skipifsilent
; Cuando la propia aplicacion se actualiza (instalacion silenciosa con /RELANZAR=1)
; vuelve a abrirse sola al terminar.
Filename: "{app}\BiblioGest.exe"; Flags: nowait; Check: RelanzarAlTerminar

[Code]
function RelanzarAlTerminar: Boolean;
begin
  Result := ExpandConstant('{param:RELANZAR|0}') = '1';
end;
