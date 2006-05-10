; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=Kid
AppVerName=Kid 0.01
AppPublisher=Agent Zhang (���ഺ)
DefaultDirName=C:\Program Files\Kid
DisableDirPage=no
DefaultGroupName=Kid
AllowNoIcons=yes
LicenseFile=Artistic.txt
OutputDir=..\release
OutputBaseFilename=Kid-0.01-r482
Compression=lzma
SolidCompression=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: ".\*"; Excludes: "unins000*"; DestDir: "{app}"; Flags: ignoreversion overwritereadonly recursesubdirs createallsubdirs

[Icons]
; Name: "{group}\Kid Doucments"; Filename: "{app}\samples\samples.html"
Name: "{group}\Uninstall Kid"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\bin\regenv.exe"; Parameters: "/q prepend user PATH ""{app}\bin;"""; Description: "Set PATH environment for the current user"; Flags: shellexec postinstall
Filename: "{app}\bin\regenv.exe"; Parameters: "/q append all PATH "";{app}\bin"""; Description: "Set PATH environment for ALL users"; Flags: shellexec postinstall
