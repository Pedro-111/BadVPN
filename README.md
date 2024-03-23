# Script de BadVPN

Este script de Bash permite instalar BadVPN, cerrar un puerto de BadVPN y desinstalar BadVPN.

## Uso

Para usar este script, simplemente ejecútalo en la terminal con el comando `bash badvpn.sh`. Se te presentará un menú con las siguientes opciones:

1. Instalar BadVPN: Esta opción te pedirá que introduzcas los puertos en los que deseas instalar BadVPN. Debes introducir los puertos separados por un espacio (por ejemplo, 7100 7200 ...).
2. Cerrar puerto BadVPN: Esta opción te pedirá que introduzcas el puerto de BadVPN que deseas cerrar.
3. Desinstalar BadVPN: Esta opción desinstalará BadVPN.
4. Salir: Esta opción terminará el script.

## Dependencias

Este script depende de los siguientes paquetes: cmake, screen, wget, gcc, build-essential, g++, make. Estos paquetes se instalarán automáticamente cuando elijas la opción de instalar BadVPN.

## Advertencia

Este script es solo un ejemplo y puede que necesites ajustarlo para que funcione en tu sistema específico. Te recomendamos probar estos comandos en un entorno seguro antes de usarlos en un sistema en producción. 

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
