[Setup]
; Basic Information
AppName=Beats Music
AppVersion=1.2.0
AppPublisher=Aadith C V
AppPublisherURL=https://github.com/AWTMODS/Beats-Music
AppSupportURL=https://t.me/beats_music_player
AppUpdatesURL=https://t.me/beats_music_player

; Installation Directory
DefaultDirName={autopf}\Beats Music
DisableProgramGroupPage=yes

; Output
OutputDir=d:\Beats-Music\installers
OutputBaseFilename=BeatsMusicSetup_v1.2.0
Compression=lzma2/ultra64
SolidCompression=yes

; Visuals
SetupIconFile=d:\Beats-Music\windows\runner\resources\app_icon.ico
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; The Main Executable
Source: "d:\Beats-Music\build\windows\x64\runner\Release\Beats.exe"; DestDir: "{app}"; Flags: ignoreversion
; The Data and DLLs (Recursive)
Source: "d:\Beats-Music\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Beats Music"; Filename: "{app}\Beats.exe"
Name: "{autodesktop}\Beats Music"; Filename: "{app}\Beats.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Beats.exe"; Description: "{cm:LaunchProgram,Beats Music}"; Flags: nowait postinstall skipifsilent
