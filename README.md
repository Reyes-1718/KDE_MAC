# KDE Plasma Theme 
![KDE_MAC.png](KDE_MAC.png)

Dotfiles para transformar Arch Linux con KDE Plasma

## Requisitos Previos

Debes tener **KDE Plasma instalado** en Arch Linux. Si aún no lo tienes:

```bash
sudo pacman -S plasma-meta kde-applications sddm
sudo systemctl enable sddm
```

## Dependencias del tema

Instala el tema de iconos Papirus y Kvantum (motor de estilos que usa el tema `Utterly-Nord`):

```bash
sudo pacman -S papirus-icon-theme kvantum
```

## Actualiza el sistema

```bash
sudo pacman -Syu
yay -Syu
```

## Instalación

```bash
git clone https://github.com/CodigoCristo/KDE_MAC.git
cd KDE_MAC
chmod +x install.sh
./install.sh
```

El script copia las carpetas `.config`, `.icons` y `.local` a tu directorio home, fusionando el contenido con lo que ya exista. Antes de sobrescribir un archivo, guarda una copia en `~/.kde_mac-backup-FECHA`, así que puedes volver atrás restaurándola. También copia el tema SDDM a `/usr/share/sddm/themes/` (pide `sudo`).

Después de ejecutar el script, **reinicia tu sesión** para aplicar todos los cambios.

## Instalar kwin-effects-glass

Este efecto es necesario para los efectos de transparencia y blur estilo macOS. Instálalo desde AUR con `yay`:

```bash
yay -S kwin-effects-glass-git
```

> Si no tienes `yay` instalado:
> ```bash
> sudo pacman -S --needed git base-devel
> git clone https://aur.archlinux.org/yay.git
> cd yay
> makepkg -si
> ```

Reinicia tu sesión para aplicar los cambios.
