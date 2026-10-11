; Instalador de BiblioGest para Windows (Inno Setup 6).
;
; No se compila a mano: lo hace scripts\construir_ejecutable.ps1, que le pasa
;   /DVersion=1.0.0
;   /DOrigen=<carpeta con BiblioGest.exe y la subcarpeta backend>
;
; Se instala para el usuario actual (sin permisos de administrador) en
; %LOCALAPPDATA%\Programs\BiblioGest. Los datos de la biblioteca viven aparte, en
; %LOCALAPPDATA%\BiblioGest, y NO se borran al desinstalar ni al actualizar.

#ifndef Version
  #define Version "1.0.0"
#endif
#ifndef Origen
  #error Falta /DOrigen=<carpeta del programa compilado>
#endif

[Setup]
AppId={{6F1B8C52-4E0A-4B2D-9C47-5B3E0D7A91C4}
AppName=BiblioGest
AppVersion={#Version}
AppPublisher=BiblioGest
DefaultDirName={localappdata}\Programs\BiblioGest
DefaultGroupName=BiblioGest
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\build\instalador
OutputBaseFilename=BiblioGest-Setup-{#Version}
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
