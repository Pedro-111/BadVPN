# 🚀 Script de BadVPN

![Ubuntu](https://img.shields.io/badge/Ubuntu-18.04%20%7C%2020.04%20%7C%2022.04-orange)
![License](https://img.shields.io/badge/License-Apache%202.0-blue)

Este script de Bash permite instalar **BadVPN** en el sistema operativo **Ubuntu 18.04 LTS**, **Ubuntu 20.04.6 LTS**, **Ubuntu 22.04 LTS**. También puedes probarlo en otras versiones de Ubuntu.

## 📥 Instalación

Para instalar este script en tu VPS, simplemente ejecuta el siguiente comando en tu terminal:

```bash
wget https://raw.githubusercontent.com/Pedro-111/BadVPN/main/install.sh -O install.sh && chmod +x install.sh && ./install.sh
```

## 🛠️ Uso

Para usar este script, simplemente ejecútalo en la terminal con el comando `menu_badvpn`. Se te presentará un menú con las siguientes opciones:

1. **Instalar BadVPN**: Esta opción te pedirá que introduzcas los puertos en los que deseas instalar BadVPN. Debes introducir los puertos separados por un espacio (por ejemplo, 7100 7200 ...).
2. **Mostrar puertos de BadVPN activos**
3. **Abrir un puerto de BadVPN**
4. **Cerrar puerto BadVPN**: Esta opción te pedirá que introduzcas el puerto de BadVPN que deseas cerrar.
5. **Desinstalar BadVPN**: Esta opción desinstalará BadVPN con todos los puertos activos para este servicio.
0. **Salir**: Esta opción terminará el script.

## 📦 Dependencias

Este script depende de los siguientes paquetes: cmake, screen, wget, gcc, build-essential, g++, make. Estos paquetes se instalarán automáticamente cuando elijas la opción de instalar BadVPN.

## ⚠️ Advertencia

Este script fue probado en Ubuntu y puede que necesites ajustarlo para que funcione en tu sistema específico. Te recomendamos probar estos comandos en un entorno seguro antes de usarlos en un sistema en producción. 

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la Licencia Apache 2.0.
