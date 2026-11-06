#!/bin/bash
set -euo pipefail

# Directorio del repositorio (funciona aunque se ejecute desde otra carpeta)
ORIGEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="$HOME"
BACKUP="$HOME/.kde_mac-backup-$(date +%Y%m%d-%H%M%S)"

# Avisar de dependencias que faltan (no detiene la instalación)
for cmd in kvantummanager sddm; do
    command -v "$cmd" >/dev/null 2>&1 || echo "⚠ No se encontró '$cmd'. Revisa los requisitos del README."
done
[ -d /usr/share/icons/Papirus-Dark ] || echo "⚠ No se encontró Papirus-Dark. Instálalo con: sudo pacman -S papirus-icon-theme"

echo "Copiando configuración a: $DESTINO"
echo "Los archivos que se sobrescriban se guardarán en: $BACKUP"

for carpeta in .config .icons .local; do
    if [ ! -d "$ORIGEN/$carpeta" ]; then
        echo "✗ $carpeta no encontrada en $ORIGEN"
        continue
    fi

    # Copia de seguridad de los archivos existentes que se van a reemplazar
    (cd "$ORIGEN" && find "$carpeta" -type f -print0) | while IFS= read -r -d '' archivo; do
        if [ -e "$DESTINO/$archivo" ]; then
            mkdir -p "$BACKUP/$(dirname "$archivo")"
            cp -a "$DESTINO/$archivo" "$BACKUP/$archivo"
        fi
    done

    mkdir -p "$DESTINO/$carpeta"
    cp -rf "$ORIGEN/$carpeta/." "$DESTINO/$carpeta/"
    echo "✓ $carpeta copiada"
done

# Copiar tema SDDM
if [ -d "$ORIGEN/sddm/themes/Utterly-Nord" ]; then
    echo "Copiando tema SDDM Utterly-Nord a /usr/share/sddm/themes/ (requiere sudo)"
    sudo cp -rf "$ORIGEN/sddm/themes/Utterly-Nord" /usr/share/sddm/themes/
    echo "✓ Tema Utterly-Nord copiado"
else
    echo "✗ Carpeta sddm/themes/Utterly-Nord no encontrada en $ORIGEN"
fi

if [ -d "$BACKUP" ]; then
    echo "Copia de seguridad guardada en: $BACKUP"
else
    echo "No se sobrescribió ningún archivo existente."
fi
echo "¡Listo! Cierra sesión y vuelve a entrar para aplicar los cambios."
