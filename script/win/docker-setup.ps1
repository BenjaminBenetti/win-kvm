
echo "Setting up Docker 🐳"
echo "This script is quite slow. Please be patient."
echo "Your computer will restart shortly (hit enter if it doesn't). Once restarted, please run this script again to complete the setup."

# Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName $("Microsoft-Hyper-V", "Containers") -All

# install docker desktop
wget https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -o $Env:Temp\docker-installer.exe
& $Env:Temp\docker-installer.exe install --always-run-service

echo "Docker Installed! 🐳"