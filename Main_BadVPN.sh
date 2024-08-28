#!/bin/bash

# Definición de colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio de instalación
INSTALL_DIR="$HOME/.local/bin"

# Función para comprobar si se necesita sudo
need_sudo() {
    if [ "$(id -u)" != "0" ]; then
        echo "sudo"
    fi
}

# Función para registrar acciones
log_action() {
    echo "$(date): $1" >> "$HOME/.badvpn_script.log"
}

# Función para validar puertos
validate_port() {
    if ! [[ $1 =~ ^[0-9]+$ ]] || [ $1 -lt 1 ] || [ $1 -gt 65535 ]; then
        echo -e "${RED}Error: '$1' no es un número de puerto válido.${NC}"
        return 1
    fi
    return 0
}

# Función para verificar si BadVPN está instalado
is_badvpn_installed() {
    if [ -d "$HOME/badvpn-1.999.128" ]; then
        return 0
    else
        return 1
    fi
}

# Función para instalar BadVPN
install_badvpn() {
    if is_badvpn_installed; then
        echo -e "${YELLOW}BadVPN ya está instalado.${NC}"
        return 1
    fi
    echo -e "${BLUE}Instalando BadVPN...${NC}"
    $(need_sudo) apt-get install cmake screen wget gcc build-essential g++ make -y
    wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/badvpn/badvpn-1.999.128.tar.bz2
    tar xf badvpn-1.999.128.tar.bz2
    cd badvpn-1.999.128/
    cmake ~/badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    $(need_sudo) make install
    for port in $@; do
        if validate_port $port; then
            echo -e "${BLUE}Iniciando BadVPN en el puerto $port...${NC}"
            $(need_sudo) badvpn-udpgw --listen-addr 127.0.0.1:$port >/dev/null &
            log_action "BadVPN iniciado en el puerto $port"
        fi
    done
    echo -e "${GREEN}✔ BadVPN ha sido instalado correctamente.${NC}"
    
    # Añade un alias al archivo .bashrc
    echo "alias menu_badvpn='$INSTALL_DIR/Main_BadVPN.sh'" >> ~/.bashrc
    echo -e "${BLUE}Alias 'menu_badvpn' añadido a ~/.bashrc.${NC}"
    
    # Recargar ~/.bashrc para aplicar alias
    echo -e "${BLUE}Recargando ~/.bashrc...${NC}"
    source ~/.bashrc
    echo -e "${GREEN}✔ ~/.bashrc recargado.${NC}"
}

# Función para mostrar los puertos de BadVPN activos
show_active_badvpn_ports() {
    echo -e "${BLUE}Mostrando los puertos de BadVPN activos...${NC}"
    $(need_sudo) lsof -i | grep badvpn
}

# Función para abrir un puerto de BadVPN
open_badvpn_port() {
    port=$1
    if validate_port $port; then
        echo -e "${BLUE}Abriendo el puerto $port de BadVPN...${NC}"
        $(need_sudo) badvpn-udpgw --listen-addr 127.0.0.1:$port >/dev/null &
        log_action "Puerto $port de BadVPN abierto"
        echo -e "${GREEN}✔ Puerto $port de BadVPN abierto correctamente.${NC}"
    fi
}

# Función para cerrar puerto BadVPN
close_badvpn_port() {
    port=$1
    if validate_port $port; then
        echo -e "${BLUE}Cerrando el puerto $port de BadVPN...${NC}"
        pid=$($(need_sudo) lsof -t -i:$port)
        if [ -z "$pid" ]; then
            echo -e "${YELLOW}No se encontró ningún proceso escuchando en el puerto $port.${NC}"
        else
            if $(need_sudo) kill $pid; then
                echo -e "${GREEN}✔ El puerto $port de BadVPN ha sido cerrado.${NC}"
                log_action "Puerto $port de BadVPN cerrado"
            else
                echo -e "${RED}✘ Hubo un error al intentar cerrar el puerto $port de BadVPN.${NC}"
            fi
        fi
    fi
}

# Función para cerrar todos los puertos de BadVPN
close_all_badvpn_ports() {
    echo -e "${BLUE}Cerrando todos los puertos de BadVPN...${NC}"
    pids=$($(need_sudo) pgrep badvpn-udpgw)
    if [ -z "$pids" ]; then
        echo -e "${YELLOW}No se encontraron procesos de BadVPN.${NC}"
    else
        for pid in $pids; do
            if $(need_sudo) kill $pid; then
                echo -e "${GREEN}✔ El proceso de BadVPN con PID $pid ha sido cerrado.${NC}"
                log_action "Proceso de BadVPN con PID $pid cerrado"
            else
                echo -e "${RED}✘ Hubo un error al intentar cerrar el proceso de BadVPN con PID $pid.${NC}"
            fi
        done
    fi
}

# Función para desinstalar BadVPN y eliminar archivos descargados
uninstall_badvpn() {
    # Pregunta al usuario si desea continuar con la desinstalación
    read -p "${YELLOW}¿Estás seguro de que deseas desinstalar BadVPN? Esto cerrará los puertos utilizados por BadVPN. (s/n) ${NC}" confirm
    if [[ $confirm != [sS] ]]; then
        echo -e "${RED}Desinstalación cancelada.${NC}"
        return
    fi

    echo -e "${BLUE}Desinstalando BadVPN...${NC}"

    # Eliminar BadVPN
    if rm -rf ~/badvpn-1.999.128 && rm ~/badvpn-1.999.128.tar.bz2; then
        echo -e "${GREEN}✔ BadVPN ha sido desinstalado.${NC}"
        close_all_badvpn_ports
        log_action "BadVPN desinstalado"
    else
        echo -e "${RED}✘ Hubo un error al intentar desinstalar BadVPN.${NC}"
    fi

    # Eliminación de archivos descargados
    if [ -f ~/badvpn-1.999.128.tar.bz2 ]; then
        rm ~/badvpn-1.999.128.tar.bz2
        echo -e "${GREEN}✔ Archivos descargados han sido eliminados.${NC}"
        log_action "Archivos descargados eliminados"
    else
        echo -e "${YELLOW}No se encontraron archivos descargados para eliminar.${NC}"
    fi

    # Pregunta si se debe borrar el servicio BadVPN
    read -p "${YELLOW}¿Deseas borrar el servicio BadVPN? (s/n) ${NC}" delete_service
    if [[ $delete_service == [sS] ]]; then
        $(need_sudo) systemctl stop badvpn
        $(need_sudo) systemctl disable badvpn
        $(need_sudo) rm /etc/systemd/system/badvpn.service
        $(need_sudo) systemctl daemon-reload
        echo -e "${GREEN}✔ Servicio BadVPN eliminado.${NC}"
        log_action "Servicio BadVPN eliminado"
    fi
}

# Función para eliminar el script
delete_script() {
    # Pregunta al usuario si desea eliminar el script
    echo -e "${YELLOW}¿Estás seguro de que deseas eliminar este script? Esto eliminará el archivo del script.${NC}"
    read -p "¿Deseas continuar? (s/n): " confirm
    if [[ $confirm != [sS] ]]; then
        echo -e "${RED}Eliminación del script cancelada.${NC}"
        return
    fi

    echo -e "${BLUE}Eliminando el script...${NC}"
    script_path="$INSTALL_DIR/Main_BadVPN.sh"
    if [ -f "$script_path" ]; then
        if rm "$script_path"; then
            echo -e "${GREEN}✔ El script ha sido eliminado.${NC}"
            log_action "Script eliminado"
            
            # Eliminar alias del .bashrc
            sed -i '/alias menu_badvpn/d' ~/.bashrc
            echo -e "${GREEN}✔ Alias 'menu_badvpn' eliminado de ~/.bashrc.${NC}"
            
            # Eliminar archivos descargados
            rm -f ~/badvpn-1.999.128.tar.bz2
            rm -rf ~/badvpn-1.999.128
            echo -e "${GREEN}✔ Archivos descargados eliminados.${NC}"
            
            echo -e "${YELLOW}El script se ha eliminado. Este menú se cerrará ahora.${NC}"
            exit 0
        else
            echo -e "${RED}✘ Hubo un error al intentar eliminar el script.${NC}"
        fi
    else
        echo -e "${RED}✘ No se pudo encontrar el script para eliminarlo.${NC}"
    fi
}

# Función para actualizar el script
update_script() {
    echo -e "${BLUE}Actualizando el script...${NC}"
    temp_file="/tmp/Main_BadVPN.sh"
    if wget https://raw.githubusercontent.com/Pedro-111/BadVPN/main/Main_BadVPN.sh -O "$temp_file"; then
        if mv "$temp_file" "$INSTALL_DIR/Main_BadVPN.sh"; then
            chmod +x "$INSTALL_DIR/Main_BadVPN.sh"
            echo -e "${GREEN}✔ El script ha sido actualizado correctamente.${NC}"
            log_action "Script actualizado"
            echo -e "${YELLOW}Por favor, reinicia el script para usar la versión actualizada.${NC}"
            exit 0
        else
            echo -e "${RED}✘ Error al mover el archivo actualizado.${NC}"
        fi
    else
        echo -e "${RED}✘ Error al descargar la actualización.${NC}"
    fi
}

# Función para mostrar el menú
show_menu() {
    echo -e "${BLUE}╔════════════════════════════╗${NC}"
    echo -e "${BLUE}║      ${GREEN}Menú de BadVPN${BLUE}        ║${NC}"
    echo -e "${BLUE}╠════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} 1) Instalar BadVPN          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 2) Mostrar puertos activos  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 3) Abrir puerto             ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 4) Cerrar puerto            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 5) Desinstalar BadVPN       ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 6) Eliminar script          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 7) Actualizar script        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 0) Salir                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════╝${NC}"
}

# Bucle principal
while true; do
    show_menu
    read -p "Introduce tu opción: " option
    case $option in
    1)
        echo -e "${YELLOW}Has seleccionado Instalar BadVPN.${NC}"
        read -p "Ingrese puertos para BadVPN (separados por un espacio: 7100 7200 ...): " ports
        install_badvpn $ports
        ;;
    2)
        echo -e "${YELLOW}Has seleccionado Mostrar puertos de BadVPN activos.${NC}"
        show_active_badvpn_ports
        ;;
    3)
        echo -e "${YELLOW}Has seleccionado Abrir puerto de BadVPN.${NC}"
        read -p "Ingrese el puerto de BadVPN que desea abrir: " port
        open_badvpn_port $port
        ;;
    4)
        echo -e "${YELLOW}Has seleccionado Cerrar puerto BadVPN.${NC}"
        read -p "Ingrese el puerto de BadVPN que desea cerrar: " port
        close_badvpn_port $port
        ;;
    5)
        echo -e "${YELLOW}Has seleccionado Desinstalar BadVPN.${NC}"
        uninstall_badvpn
        ;;
    6)
        echo -e "${YELLOW}Has seleccionado Eliminar script.${NC}"
        delete_script
        ;;
    7)
        echo -e "${YELLOW}Has seleccionado Actualizar script.${NC}"
        update_script
        ;;
    0)
        echo -e "${GREEN}Saliendo...${NC}"
        break
        ;;
    *)
        echo -e "${RED}Opción no válida${NC}"
        ;;
    esac
done
