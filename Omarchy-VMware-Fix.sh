#!/bin/bash

# Comprobar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;33m[AVISO] Este script requiere permisos de superusuario. \033[0m"
    exec sudo "$0" "$@"
    exit
fi

# Guardar el nombre del usuario real que invocó el script (en lugar de 'root')
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")

# Captura cualquier error para mostrarlo en pantalla
set -e
trap 'echo -e "\n\033[0;31m[ERROR] Ocurrió un fallo en la línea $LINENO al ejecutar el último comando.\033[0m"' ERR

echo ""
echo "=== Aplicando Fix de VMware para Omarchy/Hyprland ==="
echo ""

# 1. Instalar los paquetes requeridos de Vulkan y Mesa
echo ""
echo "[1/4] Instalando paquetes necesarios..."
pacman -S --needed --noconfirm vulkan-swrast mesa vulkan-tools

# 2. Definir la ruta del archivo de configuración del usuario real
CONFIG_FILE="$REAL_HOME/.config/hypr/hyprland.lua"

echo ""
echo "[2/4] Agregando variables de entorno..."

# Crear la carpeta de configuración si no existe
mkdir -p "$REAL_HOME/.config/hypr"
chown "$REAL_USER":"$REAL_USER" "$REAL_HOME/.config/hypr"

# Añadir un comentario identificador y las variables al final del archivo
cat << 'EOF' >> "$CONFIG_FILE"

-- [Fix VMware Workstation / Lavapipe]
hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
hl.env("VK_DRIVER_FILES", "/usr/share/vulkan/icd.d/lvp_icd.x86_64.json")
hl.env("WLR_RENDERER", "pixman")
EOF

# Ajustar permisos para que el usuario sea el propietario del archivo editado
chown "$REAL_USER":"$REAL_USER" "$CONFIG_FILE"

# 3. Configurar la resolución de la pantalla en monitors.lua usando sed
echo ""
echo "[3/4] Configuración de resolución de pantalla..."

# Detectar el monitor activo mediante hyprctl (ej. Virtual-1, eDP-1, etc.)
ACTIVE_MONITOR=$(su "$REAL_USER" -c "hyprctl monitors" | grep "Monitor" | awk '{print $2}' | head -n 1)

# Solicitar resolución al usuario
echo "  -> Ingresa la resolución para la pantalla (ej. 1920x1080@60)"
read -p "    o presiona ENTER para continuar [Por defecto: 1920x1080@60]: " USER_RES
USER_RES=${USER_RES:-"1920x1080@60"}

MONITORS_FILE="$REAL_HOME/.config/hypr/monitors.lua"

# Reemplazar únicamente la línea de hl.monitor activa manteniendo el resto del archivo intacto
if [ -f "$MONITORS_FILE" ]; then
    sed -i "s|hl\.monitor({ output = \".*\", mode = \".*\"|hl.monitor({ output = \"$ACTIVE_MONITOR\", mode = \"$USER_RES\"|g" "$MONITORS_FILE"
    chown "$REAL_USER":"$REAL_USER" "$MONITORS_FILE"
else
    echo -e "\033[0;33m[ADVERTENCIA] No se encontró $MONITORS_FILE para modificar.\033[0m"
fi

# 4. Recargar el entorno para aplicar los cambios ejecutando los comandos como el usuario real
echo ""
echo "[4/4] Recargando la configuración de Omarchy..."

# Obtener las variables de la sesión gráfica activa
REAL_UID=$(id -u "$REAL_USER")
HYPR_SIG=${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -t /run/user/$REAL_UID/hypr/ 2>/dev/null | grep -v '\.sock' | head -n 1)}

# Ejecutar comandos pasando el entorno explícito de Wayland y Hyprland
su "$REAL_USER" -c "env XDG_RUNTIME_DIR=/run/user/$REAL_UID HYPRLAND_INSTANCE_SIGNATURE=$HYPR_SIG hyprctl reload" &> /dev/null || true 
su "$REAL_USER" -c "env XDG_RUNTIME_DIR=/run/user/$REAL_UID HOME=$REAL_HOME omarchy restart-shell" &> /dev/null || true 

echo "-------------------------------------------------"
echo "¡Interfaz de Omarchy restaurada con éxito!"