#!/bin/bash

# Definir colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Función para instalar BadVPN
install_badvpn() {
    # Comprueba si BadVPN ya está instalado
    if [ -d ~/badvpn-1.999.128 ]; then
        echo "BadVPN ya está instalado."
        return 1
    fi
    echo "Instalando BadVPN..."
    apt-get install cmake -y
    apt-get install screen wget gcc build-essential g++ make -y
    wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/badvpn/badvpn-1.999.128.tar.bz2
    tar xf badvpn-1.999.128.tar.bz2
    cd badvpn-1.999.128/
    cmake ~/badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    make install
    for port in $@; do
        echo "Iniciando BadVPN en el puerto $port..."
        badvpn-udpgw --listen-addr 127.0.0.1:$port >/dev/null &
    done
}
# Función para mostrar los puertos de BadVPN activos
show_active_badvpn_ports() {
    echo "Mostrando los puertos de BadVPN activos..."
    # Utiliza lsof para encontrar todos los procesos de BadVPN y mostrar sus puertos
    lsof -i | grep badvpn
}

# Función para abrir un puerto de BadVPN
open_badvpn_port() {
    port=$1
    echo "Abriendo el puerto $port de BadVPN..."
    # Aquí iría el código para abrir el puerto especificado de BadVPN
    badvpn-udpgw --listen-addr 127.0.0.1:$port >/dev/null &
}
# Función para cerrar puerto BadVPN
close_badvpn_port() {
    port=$1
    echo "Cerrando el puerto $port de BadVPN..."
    # Obtén el ID del proceso que está escuchando en el puerto especificado
    pid=$(lsof -t -i:$port)
    if [ -z "$pid" ]; then
        echo "No se encontró ningún proceso escuchando en el puerto $port."
    else
        # Intenta terminar el proceso
        if kill $pid; then
            echo "El puerto $port de BadVPN ha sido cerrado."
        else
            echo "Hubo un error al intentar cerrar el puerto $port de BadVPN."
        fi
    fi
}

# Función para cerrar todos los puertos de BadVPN
close_all_badvpn_ports() {
    echo "Cerrando todos los puertos de BadVPN..."
    # Obtén los IDs de todos los procesos de BadVPN
    pids=$(pgrep badvpn-udpgw)
    if [ -z "$pids" ]; then
        echo "No se encontraron procesos de BadVPN."
    else
        # Termina cada proceso de BadVPN
        for pid in $pids; do
            if kill $pid; then
                echo "El proceso de BadVPN con PID $pid ha sido cerrado."
            else
                echo "Hubo un error al intentar cerrar el proceso de BadVPN con PID $pid."
            fi
        done
    fi
}

# Función para desinstalar BadVPN
uninstall_badvpn() {
    echo "Desinstalando BadVPN..."
    # Intenta eliminar los archivos de BadVPN
    if rm -rf ~/badvpn-1.999.128 && rm ~/badvpn-1.999.128.tar.bz2; then
        echo "BadVPN ha sido desinstalado."
        close_all_badvpn_ports
    else
        echo "Hubo un error al intentar desinstalar BadVPN."
    fi
}

# Función para mostrar el menú
show_menu() {
    echo -e "${GREEN}Por favor, selecciona una opción:${NC}"
    echo "1) Instalar BadVPN"
    echo "2) Mostrar puertos de BadVPN activos"
    echo "3) Abrir puerto de BadVPN"
    echo "4) Cerrar puerto de BadVPN"
    echo "5) Desinstalar BadVPN"
    echo "0) Salir"
}

# Bucle principal
while true; do
    show_menu
    read -p "Introduce tu opción: " option
    case $option in
    1)
        echo -e "${RED}Has seleccionado Instalar BadVPN.${NC}"
        read -p "Ingrese puertos para BadVPN (separados por un espacio: 7100 7200 ...): " ports
        install_badvpn $ports
        ;;
    2)
        echo -e "${RED}Has seleccionado Mostrar puertos de BadVPN activos.${NC}"
        show_active_badvpn_ports
        ;;
    3)
        echo -e "${RED}Has seleccionado Abrir puerto de BadVPN.${NC}"
        read -p "Ingrese el puerto de BadVPN que desea abrir: " port
        open_badvpn_port $port
        ;;
    4)
        echo -e "${RED}Has seleccionado Cerrar puerto BadVPN.${NC}"
        read -p "Ingrese el puerto de BadVPN que desea cerrar: " port
        close_badvpn_port $port
        ;;
    5)
        echo -e "${RED}Has seleccionado Desinstalar BadVPN.${NC}"
        uninstall_badvpn
        ;;
    0)
        echo "Saliendo..."
        break
        ;;
    *)
        echo "Opción no válida"
        ;;
    esac
done
