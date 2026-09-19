# Solución temporal para el error en VMware cuando no se muestra la interfaz de usuario

<br>

<p align="center">
    <img width="410" height="256" alt="Omarchy in VMware" src="https://github.com/user-attachments/assets/d3f78173-6357-4d9d-aa91-7a76596a1348" />
	  <img width="410" height="256" alt="Omarchy without interface" src="https://github.com/user-attachments/assets/75a5eb90-1952-41df-b6a9-72d7115906d7" />
</p>

<br> 

Este script automatiza la solución al problema de congelamiento, fallos visuales y pérdida de atajos de teclado que ocurre al ejecutar **Omarchy** (basado en Arch Linux y Hyprland) por primera vez dentro de una máquina virtual en **VMware Workstation**.

<br> 

## 🚀 ¿Qué hace este script?

1. **Instala paquetes requeridos:** -> Añade `vulkan-swrast`, `mesa` y `vulkan-tools` mediante `pacman`.
2. **Configura Hyprland (Lua):** -> Inserta las variables de entorno necesarias en `~/.config/hypr/hyprland.lua` para forzar el renderizado por software con **Lavapipe** (`llvmpipe`) y la biblioteca Pixman.
3. **Establece la resolución que elijas:** -> Por defecto se configura la resolución 1920x1080@60, pero puedes seleccionar la que más se adapte a tus necesidades.
4. **Recarga la interfaz:** -> Ejecuta `hyprctl reload` y `omarchy restart-shell` para aplicar los cambios en vivo.

<br> 

## 🛠️ Requisitos Previos

* Sistema Omarchy recién instalado (Arch Linux con Hyprland).
* Omarchy ya tiene git instalado por defecto, en caso contrario instalar git (pacman -S git)
* Permisos de superusuario (el script verifica si el usuario tiene permisos elevados).
* Conexión a Internet para descargar este fix.

<br> 

## 💻 Instalación y Uso

1. **Actualizar paquetes del sistema:**

   Primero actualiza los paquetes del sistema con el comando `sudo pacman -Sy`

2. **Crea o descarga el script:**

   En tu distro de Omarchy puedes crear el script o descargarlo usando git clone `git clone https://github.com/srsancen/Omarchy-VMware-Fix.git`

3. **Otorgar permisos de ejecución al script:**

   Dependiendo donde tengas el script, tienes que darle permisos para ejecutarlo `chmod +x Omarchy-VMware-Fix.sh`

4. **Ejecuta el script:**

   Al momento de ejecutarlo el script verifica si tienes permisos elevados, en caso contrario te solicita la contraseña para iniciar los cambios `sh Omarchy-VMware-Fix.sh`

5. **Cambia la resolución de la pantalla si es necesario:**

   Por defecto se usa la resolución 1920x1080@60, pero puedes ajustarla a tus necesidades.

6. **Espera los resultados:**

   La pantalla cambiará automaticamente y se mostrará la interfaz con los menús, fondos y aplicaciones por defecto de Omarchy.
