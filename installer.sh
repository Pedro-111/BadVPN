#!/bin/bash
# Crea el directorio si no existe
mkdir -p "$HOME/.local/bin"
# Descarga el script de GitHub
wget https://raw.githubusercontent.com/Pedro-111/BadVPN/main/Main_BadVPN.sh -O "$HOME/.local/bin/Main_BadVPN.sh"
# Dale permisos de ejecución al script
chmod +x "$HOME/.local/bin/Main_BadVPN.sh"
# Ejecuta el script
"$HOME/.local/bin/Main_BadVPN.sh"
# Añade un alias al archivo .bashrc
echo "alias menu_badvpn='$HOME/.local/bin/Main_BadVPN.sh'" >> ~/.bashrc
# Recarga el archivo .bashrc
source ~/.bashrc
# Muestra un mensaje al usuario
echo "El script se ha instalado correctamente. Puedes ejecutarlo con la palabra 'menu_badvpn'."
