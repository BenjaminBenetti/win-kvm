echo "Setting up dotnet development environment"

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install git
choco install git -y

# install dotnet cli
choco install dotnet -y

# install visual studio code
choco install vscode -y

# install visual studio community 2022
choco install visualstudio2022community -y