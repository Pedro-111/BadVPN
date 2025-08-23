#!/bin/bash
# install.sh: Un instalador inteligente y robusto para BadVPN-Manager

# --- Variables de Configuración ---
readonly SCRIPT_NAME="badvpn-manager"
readonly GITHUB_USER="Pedro-111"
readonly GITHUB_REPO="BadVPN"
readonly SCRIPT_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/Main_BadVPN.sh"
readonly INSTALL_DIR="$HOME/.local/bin"

# --- Colores y Estilos ---
readonly C_GREEN='\033[0;32m'
readonly C_BLUE='\033[0;34m'
readonly C_YELLOW='\033[0;33m'
readonly C_RED='\033[0;31m'
readonly C_BOLD='\033[1m'
readonly C_RESET='\033[0m'

# --- Funciones de Ayuda ---
info() { echo -e "${C_BLUE}ℹ ${*}${C_RESET}"; }
success() { echo -e "${C_GREEN}✔ ${*}${C_RESET}"; }
warn() { echo -e "${C_YELLOW}⚠ ${*}${C_RESET}"; }
error() { echo -e "${C_RED}✖ ${*}${C_RESET}"; exit 1; }
prompt() { echo -e "\n${C_BOLD}${C_GREEN}› ${*}${C_RESET}"; }

# --- Lógica del Script ---

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ejecuta comandos como root solo si es necesario
run_as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Verifica dependencias básicas (curl o wget)
check_dependencies() {
    prompt "Verificando dependencias..."
    if ! command_exists curl && ! command_exists wget; then
        error "Necesitas 'curl' o 'wget' para descargar el script. Por favor, instala uno de ellos."
    fi
    if ! command_exists sudo; then
        warn "'sudo' no encontrado. Si se requieren privilegios de root, el script puede fallar."
    fi
    success "Dependencias encontradas."
}

# Crea el directorio y configura el PATH si es necesario
setup_environment() {
    prompt "Configurando el entorno de instalación..."
    mkdir -p "$INSTALL_DIR"

    # Detecta el archivo de perfil del shell (.bashrc, .zshrc, etc.)
    local shell_profile
    if [[ -n "$BASH_VERSION" ]]; then
        shell_profile="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_profile="$HOME/.zshrc"
    else
        shell_profile="$HOME/.profile"
    fi

    # Añade el directorio al PATH solo si no está ya incluido
    if ! grep -q "export PATH=.*$INSTALL_DIR" "$shell_profile"; then
        info "Añadiendo '$INSTALL_DIR' a tu PATH en '$shell_profile'."
        echo -e "\n# Añadido por el instalador de BadVPN-Manager\nexport PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_profile"
        success "PATH configurado. Deberás reiniciar tu terminal para que los cambios surtan efecto."
    else
        info "El directorio '$INSTALL_DIR' ya está en tu PATH."
    fi
}

# Descarga el script principal desde GitHub
download_script() {
    local target_path="$INSTALL_DIR/$SCRIPT_NAME"
    prompt "Descargando el script principal..."

    if command_exists curl; then
        if curl -sSL "$SCRIPT_URL" -o "$target_path"; then
            success "Script descargado en '$target_path'."
        else
            error "La descarga con curl falló."
        fi
    elif command_exists wget; then
        if wget -q -O "$target_path" "$SCRIPT_URL"; then
            success "Script descargado en '$target_path'."
        else
            error "La descarga con wget falló."
        fi
    fi
    
    chmod +x "$target_path"
    success "Permisos de ejecución asignados."
}

# --- Flujo Principal ---
main() {
    clear
    echo -e "${C_BOLD}${C_GREEN}--- Instalador de BadVPN Manager ---${C_RESET}"
    check_dependencies
    setup_environment
    download_script
    
    echo -e "\n\n${C_BOLD}🎉 ¡Instalación completada! 🎉${C_RESET}"
    info "Para empezar, reinicia tu terminal o ejecuta:"
    echo -e "  ${C_YELLOW}source ~/.bashrc  # (o el archivo de tu shell, ej: ~/.zshrc)${C_RESET}"
    info "Luego, simplemente ejecuta el comando:"
    echo -e "  ${C_GREEN}${SCRIPT_NAME}${C_RESET}"
}

main
