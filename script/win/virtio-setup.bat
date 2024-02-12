:: Windows script to setup VirtioFS service. Run as Administrator.
:: This is needed to allow for host filesystem sharing from your Linux box. 
:: Batch file ... Ewwww. 

:: Add virtiofs driver 
pnputil /add-driver E:\viofs\w11\amd64\viofs.inf /install 

:: Download WinFSP.
:: Credit to Copilot for telling me how to download a file in a batch script
set winFspUrl=https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi
set winFspInstaller=%temp%\winfsp-2.0.23075.msi
bitsadmin /transfer myDownloadJob /download /priority normal %winFspUrl% %winFspInstaller%

:: Install WinFSP
msiexec /i %winFspInstaller% /quiet /qn /norestart

:: create virtio service. Will it always be drive E? Damn windows. 
sc create VirtioFsSvc binpath="E:\viofs\w11\amd64\virtiofs.exe" start=auto depend="WinFsp.Launcher/VirtioFsDrv" DisplayName="Virtio FS Service"

:: start the service
sc start VirtioFsSvc 