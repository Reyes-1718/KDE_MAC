# KDE Plasma Theme 
![KDE_MAC.png](KDE_MAC.png)

Dotfiles para dar a KDE Plasma 6 un aspecto estilo macOS (tema Utterly-Nord).

Distribuciones soportadas:

| Distribución | Plasma | Estado |
|---|---|---|
| Arch Linux | 6.x (última) | Completo |
| Debian 13 (Trixie) | 6.3 | Completo, salvo el efecto de cristal (ver abajo) |

## Requisitos previos

Necesitas **KDE Plasma 6** instalado.

**Arch Linux**

```bash
sudo pacman -Syu
sudo pacman -S plasma-meta
```

**Debian 13 (Trixie)**

```bash
sudo apt update && sudo apt full-upgrade
sudo apt install kde-plasma-desktop
```

SDDM **no es obligatorio**: el tema funciona con cualquier gestor de inicio de sesión.

## Instalación

```bash
git clone https://github.com/CodigoCristo/KDE_MAC.git
cd KDE_MAC
chmod +x install.sh
./install.sh
```

El script:

1. Detecta si estás en Arch o Debian e instala las dependencias (Papirus, Kvantum, plasmoides de KDE y kirigami-addons) con `pacman` o `apt`.
2. Copia `.config`, `.icons` y `.local` a tu home. Antes de sobrescribir un archivo, guarda una copia en `~/.kde_mac-backup-FECHA`, así que puedes volver atrás restaurándola.
3. Si no tienes `kwin-effects-glass`, activa el blur nativo de KWin en su lugar.
4. Si SDDM está instalado, copia su tema a `/usr/share/sddm/themes/`.

Opciones:

```
./install.sh --sin-sddm           # no instala el tema de SDDM
./install.sh --sddm               # lo instala aunque no se detecte SDDM
./install.sh --sin-dependencias   # no instala paquetes
```

Después de ejecutar el script, **cierra sesión y vuelve a entrar** para aplicar los cambios.

## Efecto de cristal (opcional)

`kwin-effects-glass` da la transparencia y el blur estilo macOS. Sin él, el script usa el blur nativo de KWin, que se parece menos pero funciona en todas partes.

**Arch Linux** (AUR):

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

**Debian 13**: no está en los repositorios. Se puede compilar desde el código fuente del proyecto (enlazado en la [página del AUR](https://aur.archlinux.org/packages/kwin-effects-glass-git)) con `kwin-dev` y `cmake`, pero debe coincidir con la versión de KWin instalada y puede romperse al actualizar. Si lo instalas, actívalo en *Preferencias del sistema > Efectos de escritorio*.

## Diferencias en Debian

- El plasmoide **Window Buttons** (`org.kde.windowbuttons`) no se copia: trae una librería compilada para Arch que no carga en Debian. El panel por defecto no lo usa.
- Debian 13 trae Plasma 6.3, más antiguo que Arch. Algún ajuste pensado para versiones más nuevas puede ignorarse sin causar errores.
