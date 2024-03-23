#!/bin/bash

# Crea el directorio si no existe
mkdir -p /root/

# Descarga el script de GitHub
wget https://raw.githubusercontent.com/Pedro-111/BadVPN/main/Main_BadVPN.sh?token=GHSAT0AAAAAACOPMOLU54OFYB65J374T6C6ZP7H36A -O /root/Main_BadVPN.sh

# Dale permisos de ejecución al script
chmod +x /root/Main_BadVPN.sh

# Ejecuta el script
/root/Main_BadVPN.sh

# Añade un alias al archivo .bashrc
echo "alias menu='/root/Main_BadVPN.sh'" >> ~/.bashrc

# Recarga el archivo .bashrc
source ~/.bashrc

# Muestra un mensaje al usuario
echo "El script se ha instalado correctamente. Puedes ejecutarlo con la palabra 'menu'."

