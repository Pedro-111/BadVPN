#!/bin/bash
# badvpn-manager: Un script completo para instalar y gestionar BadVPN y su servicio.

# --- Variables Globales ---
readonly SCRIPT_VERSION="2.0"
readonly GITHUB_URL="https://raw.githubusercontent.com/Pedro-111/BadVPN/main/Main_BadVPN.sh"
readonly SCRIPT_PATH="$HOME/.local/bin/badvpn-manager"

# Dependencias necesarias para compilar
readonly BUILD_DEPS="cmake build-essential g++ make screen wget"

# Rutas y nombres para BadVPN
readonly BADVPN_SRC_DIR="$HOME/badvpn-source"
readonly BADVPN_TAR_URL="https://github.com/Pedro-111/BadVPN/raw/refs/heads/main/badvpn-1.999.128.tar.bz2"
readonly BADVPN_TAR_FILE="$HOME/badvpn-1.999.128.tar.bz2"
readonly BADVPN_BIN_PATH="/usr/local/bin/badvpn-udpgw"

# Configuración del servicio systemd
readonly SERVICE_NAME="badvpn-udpgw.service"
readonly SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

# --- Colores y Estilos ---
readonly C_GREEN='\033[0;32m'
readonly C_BLUE='\033[0;34m'
readonly C_YELLOW='\033[0;33m'
readonly C_RED='\033[0;31m'
readonly C_CYAN='\033[0;36m'
readonly C_BOLD='\033[1m'
readonly C_RESET='\033[0m'

# --- Funciones de Ayuda ---
info() { echo -e "${C_BLUE}ℹ ${*}${C_RESET}"; }
success() { echo -e "${C_GREEN}✔ ${*}${C_RESET}"; }
warn() { echo -e "${C_YELLOW}⚠ ${*}${C_RESET}"; }
error() { echo -e "${C_RED}✖ ${*}${C_RESET}"; }

run_as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@";
    else
        sudo "$@";
    fi
}

press_enter_to_continue() {
    echo -e "\n${C_CYAN}Presiona [Enter] para continuar...${C_RESET}"
    read -r
}

# --- Funciones de Lógica Principal ---

# Verifica si BadVPN está compilado e instalado
is_badvpn_installed() {
    command -v badvpn-udpgw >/dev/null 2>&1
}

# Compila e instala BadVPN desde el código fuente
install_badvpn() {
    if is_badvpn_installed; then
        warn "BadVPN ya está instalado."
        info "Si quieres reinstalar, primero desinstálalo (Opción 5)."
        return 1
    fi

    info "Paso 1: Instalando dependencias de compilación..."
    run_as_root apt-get update
    run_as_root apt-get install -y $BUILD_DEPS
    
    info "Paso 2: Descargando el código fuente de BadVPN..."
    wget -O "$BADVPN_TAR_FILE" "$BADVPN_TAR_URL"
    
    info "Paso 3: Descomprimiendo y compilando..."
    rm -rf "$BADVPN_SRC_DIR"
    mkdir -p "$BADVPN_SRC_DIR"
    tar -xjf "$BADVPN_TAR_FILE" -C "$BADVPN_SRC_DIR" --strip-components=1
    
    cd "$BADVPN_SRC_DIR" || exit
    cmake -B build -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    cd build || exit
    make
    
    info "Paso 4: Instalando el binario en el sistema..."
    run_as_root make install
    
    info "Paso 5: Limpiando archivos de instalación..."
    rm -rf "$BADVPN_SRC_DIR"
    rm -f "$BADVPN_TAR_FILE"

    success "¡BadVPN ha sido compilado e instalado correctamente!"
    info "El binario se encuentra en: $BADVPN_BIN_PATH"
}

# Crea y configura un servicio de systemd para BadVPN
create_service() {
    read -p "Introduce los puertos que quieres que BadVPN escuche (ej: 7100 7200 7300): " ports
    if [[ -z "$ports" ]]; then
        error "No se especificaron puertos. Operación cancelada."
        return 1
    fi

    local listen_addr="127.0.0.1"
    local exec_start_cmd="$BADVPN_BIN_PATH"
    for port in $ports; do
        exec_start_cmd+=" --listen-addr $listen_addr:$port"
    done

    info "Creando el archivo de servicio en $SERVICE_FILE..."
    
    # Usamos cat con EOF para escribir el contenido del servicio
    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
ExecStart=$exec_start_cmd
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    info "Recargando systemd, habilitando e iniciando el servicio..."
    run_as_root systemctl daemon-reload
    run_as_root systemctl enable "$SERVICE_NAME"
    run_as_root systemctl start "$SERVICE_NAME"

    success "¡Servicio BadVPN creado y activado!"
    run_as_root systemctl status "$SERVICE_NAME" --no-pager
}

# Desinstala BadVPN y su servicio
uninstall_badvpn() {
    if ! is_badvpn_installed; then
        warn "BadVPN no parece estar instalado."
        return 1
    fi

    read -p "¿Estás seguro de que quieres desinstalar BadVPN y su servicio? (s/n): " confirm
    if [[ "$confirm" != "s" ]]; then
        info "Desinstalación cancelada."
        return
    fi
    
    if systemctl list-units --full -all | grep -q "$SERVICE_NAME"; then
        info "Deteniendo y deshabilitando el servicio..."
        run_as_root systemctl stop "$SERVICE_NAME"
        run_as_root systemctl disable "$SERVICE_NAME"
        run_as_root rm -f "$SERVICE_FILE"
        run_as_root systemctl daemon-reload
        success "Servicio eliminado."
    fi

    info "Eliminando el binario de BadVPN..."
    run_as_root rm -f "$BADVPN_BIN_PATH"

    info "Eliminando carpetas y archivos residuales..."
    rm -rf "$BADVPN_SRC_DIR"
    rm -f "$BADVPN_TAR_FILE"

    success "¡BadVPN desinstalado por completo!"
}

# Se actualiza a sí mismo desde GitHub
update_script() {
    info "Buscando actualizaciones..."
    if wget -q -O "$SCRIPT_PATH.tmp" "$GITHUB_URL"; then
        mv "$SCRIPT_PATH.tmp" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        success "Script actualizado a la última versión."
        info "Por favor, vuelve a ejecutar el script."
        exit 0
    else
        error "No se pudo descargar la actualización."
    fi
}

# Se elimina a sí mismo
delete_script() {
    read -p "¿Estás seguro de que quieres eliminar este script gestor? (s/n): " confirm
    if [[ "$confirm" == "s" ]]; then
        rm -f "$SCRIPT_PATH"
        success "Script eliminado."
        info "¡Adiós!"
        exit 0
    fi
    info "Eliminación cancelada."
}

# Muestra el menú principal
show_menu() {
    clear
    echo -e "${C_BOLD}${C_CYAN} BADVPM Manager v${SCRIPT_VERSION} ${C_RESET}"
    echo -e "────────────────────────────────────────"
    if is_badvpn_installed; then
        echo -e " ${C_GREEN}● BadVPN está instalado${C_RESET}"
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo -e " ${C_GREEN}● Servicio está ACTIVO${C_RESET}"
        else
            echo -e " ${C_YELLOW}● Servicio está INACTIVO${C_RESET}"
        fi
    else
        echo -e " ${C_RED}● BadVPN NO está instalado${C_RESET}"
    fi
    echo -e "────────────────────────────────────────"
    echo -e " ${C_BOLD}1)${C_RESET} Instalar/Reinstalar BadVPN"
    echo -e " ${C_BOLD}2)${C_RESET} Configurar/Reiniciar Servicio (Puertos)"
    echo -e " ${C_BOLD}3)${C_RESET} Ver Estado del Servicio"
    echo -e " ${C_BOLD}4)${C_RESET} Detener/Iniciar Servicio"
    echo -e " ${C_BOLD}5)${C_RESET} ${C_YELLOW}Desinstalar BadVPN${C_RESET}"
    echo -e "────────────────────────────────────────"
    echo -e " ${C_BOLD}8)${C_RESET} Actualizar este script"
    echo -e " ${C_BOLD}9)${C_RESET} ${C_RED}Eliminar este script${C_RESET}"
    echo -e " ${C_BOLD}0)${C_RESET} Salir"
    echo -e "────────────────────────────────────────"
}

# --- Bucle Principal ---
while true; do
    show_menu
    read -p "Elige una opción: " choice

    case $choice in
        1)
            install_badvpn
            press_enter_to_continue
            ;;
        2)
            if ! is_badvpn_installed; then
                error "Debes instalar BadVPN primero (Opción 1)."
            else
                create_service
            fi
            press_enter_to_continue
            ;;
        3)
            if ! systemctl list-units --full -all | grep -q "$SERVICE_NAME"; then
                error "El servicio no existe. Configúralo con la opción 2."
            else
                run_as_root systemctl status "$SERVICE_NAME" --no-pager
            fi
            press_enter_to_continue
            ;;
        4)
            if ! systemctl list-units --full -all | grep -q "$SERVICE_NAME"; then
                error "El servicio no existe. Configúralo con la opción 2."
            else
                if systemctl is-active --quiet "$SERVICE_NAME"; then
                    run_as_root systemctl stop "$SERVICE_NAME"
                    success "Servicio detenido."
                else
                    run_as_root systemctl start "$SERVICE_NAME"
                    success "Servicio iniciado."
                fi
            fi
            press_enter_to_continue
            ;;
        5)
            uninstall_badvpn
            press_enter_to_continue
            ;;
        8)
            update_script
            ;;
        9)
            delete_script
            ;;
        0)
            break
            ;;
        *)
            error "Opción no válida."
            sleep 1
            ;;
    esac
done

echo -e "\n${C_GREEN}¡Hasta luego!${C_RESET}"
