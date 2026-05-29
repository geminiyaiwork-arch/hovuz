; Inno Setup script for Hovuz Windows installer.
; Build prerequisites (run on Windows):
;   1. flutter build windows --release
;   2. Open this file with Inno Setup Compiler (https://jrsoftware.org/isdl.php)
;   3. Build → produces dist/HovuzSetup-x.y.z.exe
;
; The resulting .exe is a single-file installer that:
;   - Installs to "C:\Program Files\Hovuz"
;   - Creates Start Menu entry and optional desktop shortcut
;   - Registers uninstaller

#define MyAppName "Hovuz"
#ifndef MyAppVersion
  #define MyAppVersion "2.1.0"
#endif
#define MyAppPublisher "VISIO EYE · Qodirov Elyorbek"
#define MyAppURL "https://t.me/voo_uz"
#define MyAppExeName "hovuz.exe"
#define BundleDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{A8E6D2F1-3B5C-4E7A-9F1D-2C4B8A7E9D31}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\dist
OutputBaseFilename=HovuzSetup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
