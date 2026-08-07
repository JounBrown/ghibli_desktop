#!/bin/bash

echo "Iniciando la instalación de la personalización de Conky (Tema Ghibli)..."

# 1. Instalar dependencias necesarias
echo "Instalando Conky y dependencias (conky-all)..."
sudo apt update
sudo apt install -y conky-all

# 2. Crear los directorios recomendados (buenas prácticas XDG)
echo "Creando estructura de carpetas..."
mkdir -p ~/.config/conky
mkdir -p ~/Imágenes/Wallpapers
mkdir -p ~/.config/autostart

# 3. Copiar los archivos de Conky a su ubicación definitiva
echo "Instalando configuración de Conky..."
cp conky.conf ~/.config/conky/
cp lluvia.lua ~/.config/conky/

# 4. Copiar el fondo de pantalla
echo "Instalando el fondo de Studio Ghibli..."
cp 1.png ~/Imágenes/Wallpapers/

# 5. Cambiar el fondo de pantalla automáticamente en XFCE
echo "Aplicando el fondo de pantalla en el escritorio..."
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ~/Imágenes/Wallpapers/1.png 2>/dev/null

# 6. Configurar el autoarranque en Sesión e Inicio automáticamente
echo "Configurando el autoarranque..."
cat <<EOF > ~/.config/autostart/conky.desktop
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Reloj Conky
Comment=
Exec=sh -c "sleep 5 && conky -c ~/.config/conky/conky.conf -d"
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF

# 7. Reiniciar Conky para cargar la nueva configuración
echo "Iniciando Conky..."
killall conky 2>/dev/null
sh -c "sleep 2 && conky -c ~/.config/conky/conky.conf -d" &

echo "¡Instalación completada con éxito!"
