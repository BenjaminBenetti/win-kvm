
:: Download spice-gest-tools.
set getsToolsUrl=https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe
set getToolsInstaller=%temp%\spice-guest-tools-latest.exe
bitsadmin /transfer myDownloadJob /download /priority normal %getsToolsUrl% %getToolsInstaller%

:: Install spice-guest-tools
%getToolsInstaller% 
