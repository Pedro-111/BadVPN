#!/bin/bash

# Función para ejecutar comandos como root
run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Definir variables
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="Main_BadVPN.sh"
GITHUB_RAW_URL="https://raw.githubusercontent.com/Pedro-111/BadVPN/main"

# Colores
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Función para instalar dependencias
install_dependencies() {
    run_as_root apt-get update
    run_as_root apt-get install -y wget
}

# Instalar dependencias
install_dependencies

# Crear el directorio de instalación si no existe
mkdir -p "$INSTALL_DIR"

# Descargar el script principal usando wget
echo "Descargando $SCRIPT_NAME..."
wget -q "$GITHUB_RAW_URL/$SCRIPT_NAME" -O "$INSTALL_DIR/$SCRIPT_NAME"

# Hacer el script ejecutable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Agregar el directorio al PATH si no está ya
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
    echo "Se ha añadido $INSTALL_DIR a su PATH."
fi

# Crear un alias
echo "alias menu_badvpn='$INSTALL_DIR/$SCRIPT_NAME'" >> "$HOME/.bashrc"

echo -e "${GREEN}Instalación completada. El comando 'menu_badvpn' estará disponible después de reiniciar la terminal.${NC}"
echo -e "${GREEN}Puede ejecutar 'menu_badvpn' para gestionar BadVPN.${NC}"
echo -e "${GREEN}Reinicia tu terminal con 'source ~/.bashrc'.${NC}"
