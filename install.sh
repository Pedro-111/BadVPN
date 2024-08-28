#!/bin/bash

# Colores
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Crea el directorio si no existe
mkdir -p "$HOME/.local/bin"

# Descarga el script principal de GitHub
curl -sSL https://raw.githubusercontent.com/Pedro-111/BadVPN/main/Main_BadVPN.sh -o "$HOME/.local/bin/Main_BadVPN.sh"

# Dale permisos de ejecución al script
chmod +x "$HOME/.local/bin/Main_BadVPN.sh"

# Añade un alias al archivo .bashrc si no existe
if ! grep -q "alias menu_badvpn=" "$HOME/.bashrc"; then
    echo "alias menu_badvpn='$HOME/.local/bin/Main_BadVPN.sh'" >> "$HOME/.bashrc"
    echo -e "${GREEN}Alias 'menu_badvpn' añadido a ~/.bashrc.${NC}"
fi

# Recarga el archivo .bashrc
source "$HOME/.bashrc"

# Muestra un mensaje al usuario
echo -e "${GREEN}El script se ha instalado correctamente.${NC}"
echo -e "${GREEN}Puedes ejecutarlo con el comando 'menu_badvpn' o ejecutando '$HOME/.local/bin/Main_BadVPN.sh'${NC}"

# Pregunta si el usuario quiere ejecutar el script ahora
read -p "¿Deseas ejecutar el script ahora? (s/n): " run_now
if [[ $run_now == [sS] ]]; then
    "$HOME/.local/bin/Main_BadVPN.sh"
fi
