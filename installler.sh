#!/bin/bash

# Descarga el script de GitHub
wget https://raw.githubusercontent.com/usuario/repositorio/rama/nombre_del_script.sh -O /ruta/al/script/menu.sh

# Dale permisos de ejecución
chmod +x /ruta/al/script/menu.sh

# Añade un alias al archivo .bashrc
echo "alias menu='/ruta/al/script/menu.sh'" >> ~/.bashrc

# Recarga el archivo .bashrc
source ~/.bashrc

# Muestra un mensaje al usuario
echo "El script se ha instalado correctamente. Puedes ejecutarlo con la palabra 'menu'."
