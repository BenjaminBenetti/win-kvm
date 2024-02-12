echo "Setting up dotnet development environment"

# install git
choco install git -y

# install dotnet cli
choco install dotnet -y

# install latest LTS dotnet sdk
wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -o $Env:Temp\dotnet-install.ps1
$Env:Temp\dotnet-install.ps1 -Channel LTS
setx /M PATH "%PATH%;C:\Users\windo\AppData\Local\Microsoft\dotnet\"

# install visual studio code
choco install vscode -y

# install visual studio community 2022
choco install visualstudio2022community -y


