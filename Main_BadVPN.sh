#!/bin/bash

# Definir colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Función para instalar BadVPN
install_badvpn() {
    echo "Instalando dependencias necesarias..."
    if apt-get install cmake screen wget gcc build-essential g++ make -y ; then
        echo "Dependencias instaladas correctamente."
    else
        echo "Hubo un error al instalar las dependencias. Por favor, verifica tu conexión a internet y los permisos de sudo."
        return 1
    fi

    echo "Descargando BadVPN..."
    if wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/badvpn/badvpn-1.999.128.tar.bz2 ; then
        echo "BadVPN descargado correctamente."
    else
        echo "Hubo un error al descargar BadVPN. Por favor, verifica tu conexión a internet."
        return 1
    fi

    echo "Extrayendo BadVPN..."
    if tar xf badvpn-1.999.128.tar.bz2 ; then
        echo "BadVPN extraído correctamente."
    else
        echo "Hubo un error al extraer BadVPN."
        return 1
    fi

    cd badvpn-1.999.128/
    if cmake ~/badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 ; then
        echo "CMake ejecutado correctamente."
    else
        echo "Hubo un error al ejecutar CMake."
        return 1
    fi

    if make install ; then
        echo "BadVPN instalado correctamente."
    else
        echo "Hubo un error al instalar BadVPN."
        return 1
    fi

    for port in $@
    do
        echo "Iniciando BadVPN en el puerto $port..."
        badvpn-udpgw --listen-addr 127.0.0.1:$port > /dev/null &
    done
}

# Función para cerrar puerto BadVPN
close_badvpn_port() {
    port=$1
    echo "Cerrando el puerto $port de BadVPN..."
    # Obtén el ID del proceso que está escuchando en el puerto especificado
    pid=$(lsof -t -i:$port)
    if [ -z "$pid" ]
    then
        echo "No se encontró ningún proceso escuchando en el puerto $port."
    else
        # Intenta terminar el proceso
        if kill $pid ; then
            echo "El puerto $port de BadVPN ha sido cerrado."
        else
            echo "Hubo un error al intentar cerrar el puerto $port de BadVPN."
        fi
    fi
}

# Función para desinstalar BadVPN
uninstall_badvpn() {
    echo "Desinstalando BadVPN..."
    # Intenta eliminar los archivos de BadVPN
    if rm -rf ~/badvpn-1.999.128 && rm ~/badvpn-1.999.128.tar.bz2 ; then
        echo "BadVPN ha sido desinstalado."
    else
        echo "Hubo un error al intentar desinstalar BadVPN."
    fi
}

# Función para mostrar el menú
show_menu() {
    echo -e "${GREEN}Por favor, selecciona una opción:${NC}"
    echo "1) Instalar BadVPN"
    echo "2) Cerrar puerto BadVPN"
    echo "3) Desinstalar BadVPN"
    echo "4) Salir"
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
            echo -e "${RED}Has seleccionado Cerrar puerto BadVPN.${NC}"
            read -p "Ingrese el puerto de BadVPN que desea cerrar: " port
            close_badvpn_port $port
            ;;
        3)
            echo -e "${RED}Has seleccionado Desinstalar BadVPN.${NC}"
            uninstall_badvpn
            ;;
        4)
            echo "Saliendo..."
            break
            ;;
        *)
            echo "Opción no válida. Por favor, intenta de nuevo."
            ;;
    esac
done
