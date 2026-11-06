#!/bin/bash
# Instalador del tema KDE_MAC para Arch Linux y Debian 13 (Trixie).
set -euo pipefail

uso() {
    cat <<'EOF'
Uso: ./install.sh [opciones]

  --sddm               Instala el tema de SDDM (por defecto: solo si SDDM está instalado)
  --sin-sddm           No instala el tema de SDDM
  --sin-dependencias   No instala paquetes con pacman/apt
  -h, --help           Muestra esta ayuda
EOF
}

SDDM="auto"
DEPENDENCIAS=1
for arg in "$@"; do
    case "$arg" in
        --sddm) SDDM="si" ;;
        --sin-sddm) SDDM="no" ;;
        --sin-dependencias) DEPENDENCIAS=0 ;;
        -h|--help) uso; exit 0 ;;
        *) echo "Opción desconocida: $arg"; uso; exit 1 ;;
    esac
done

# Directorio del repositorio (funciona aunque se ejecute desde otra carpeta)
ORIGEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="$HOME"
BACKUP="$HOME/.kde_mac-backup-$(date +%Y%m%d-%H%M%S)"

# --- Detectar distribución ---------------------------------------------------
DISTRO="desconocida"
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case " ${ID:-} ${ID_LIKE:-} " in
        *" arch "*) DISTRO="arch" ;;
        *" debian "*|*" ubuntu "*) DISTRO="debian" ;;
    esac
fi
echo "Distribución detectada: ${PRETTY_NAME:-$DISTRO}"

if [ "$DISTRO" = "debian" ] && [ "${ID:-}" = "debian" ] && [ "${VERSION_ID:-0}" -lt 13 ] 2>/dev/null; then
    echo "⚠ Este tema necesita Plasma 6 (Debian 13 Trixie o superior). Tu versión es ${VERSION_ID}."
fi

# --- Dependencias -------------------------------------------------------------
if [ "$DEPENDENCIAS" -eq 1 ]; then
    case "$DISTRO" in
        arch)
            echo "Instalando dependencias con pacman..."
            sudo pacman -S --needed papirus-icon-theme kvantum kdeplasma-addons kirigami-addons \
                || echo "⚠ No se pudieron instalar todas las dependencias."
            ;;
        debian)
            echo "Instalando dependencias con apt..."
            sudo apt-get install papirus-icon-theme qt6-style-kvantum plasma-widgets-addons \
                qml6-module-org-kde-kirigamiaddons-components libkf6config-bin \
                || echo "⚠ No se pudieron instalar todas las dependencias."
            ;;
        *)
            echo "⚠ Distribución no soportada: instala a mano Papirus y Kvantum (ver README)."
            ;;
    esac
fi

# --- Copiar configuración -------------------------------------------------------
# Archivos que no se copian en esta distribución
EXCLUIR=()
if [ "$DISTRO" != "arch" ]; then
    # Trae una librería (.so) compilada para el Qt de Arch; en otras distros no carga.
    EXCLUIR+=(".local/share/plasma/plasmoids/org.kde.windowbuttons")
fi

excluido() {
    local ruta
    for ruta in "${EXCLUIR[@]+"${EXCLUIR[@]}"}"; do
        case "$1" in "$ruta"|"$ruta"/*) return 0 ;; esac
    done
    return 1
}

echo "Copiando configuración a: $DESTINO"
echo "Los archivos que se sobrescriban se guardarán en: $BACKUP"

for carpeta in .config .icons .local; do
    if [ ! -d "$ORIGEN/$carpeta" ]; then
        echo "✗ $carpeta no encontrada en $ORIGEN"
        continue
    fi

    while IFS= read -r -d '' archivo; do
        excluido "$archivo" && continue
        if [ -e "$DESTINO/$archivo" ]; then
            mkdir -p "$BACKUP/$(dirname "$archivo")"
            cp -a "$DESTINO/$archivo" "$BACKUP/$archivo"
        fi
        mkdir -p "$DESTINO/$(dirname "$archivo")"
        cp -a "$ORIGEN/$archivo" "$DESTINO/$archivo"
    done < <(cd "$ORIGEN" && find "$carpeta" \( -type f -o -type l \) -print0)

    echo "✓ $carpeta copiada"
done

# --- Efecto de cristal de KWin --------------------------------------------------
# kwin-effects-glass solo está en el AUR. Si no está instalado, se usa el blur
# nativo de KWin para que las ventanas y paneles no queden sin desenfoque.
if ! find /usr/lib /usr/lib64 -path '*kwin/effects/plugins/*glass*' -print -quit 2>/dev/null | grep -q .; then
    echo "kwin-effects-glass no está instalado: se activa el blur nativo de KWin."
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kwinrc --group Plugins --key glassEnabled false
        kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    elif [ -f "$DESTINO/.config/kwinrc" ]; then
        # Sin kwriteconfig6: editar solo la sección [Plugins] del kwinrc copiado
        sed -i '/^\[Plugins\]/,/^\[/{s/^glassEnabled=.*/glassEnabled=false/;s/^blurEnabled=.*/blurEnabled=true/}' \
            "$DESTINO/.config/kwinrc"
    fi
fi

# --- Tema SDDM (opcional) -------------------------------------------------------
if [ "$SDDM" = "auto" ]; then
    if command -v sddm >/dev/null 2>&1; then SDDM="si"; else SDDM="no"; fi
fi

if [ "$SDDM" = "si" ]; then
    if [ -d "$ORIGEN/sddm/themes/Utterly-Nord" ]; then
        echo "Copiando tema SDDM Utterly-Nord a /usr/share/sddm/themes/ (requiere sudo)"
        sudo mkdir -p /usr/share/sddm/themes
        sudo cp -rf "$ORIGEN/sddm/themes/Utterly-Nord" /usr/share/sddm/themes/
        echo "✓ Tema SDDM copiado. Actívalo en Preferencias del sistema > Pantalla de inicio de sesión (SDDM)."
    else
        echo "✗ Carpeta sddm/themes/Utterly-Nord no encontrada en $ORIGEN"
    fi
else
    echo "Tema SDDM omitido (SDDM no está instalado o se usó --sin-sddm)."
fi

if [ -d "$BACKUP" ]; then
    echo "Copia de seguridad guardada en: $BACKUP"
else
    echo "No se sobrescribió ningún archivo existente."
fi
echo "¡Listo! Cierra sesión y vuelve a entrar para aplicar los cambios."
