#!/usr/bin/env bash
# .devcontainer/setup.sh
# Prepara un entorno Flutter reproducible en Codespaces/Dev Containers.
# - Detecta el gestor de paquetes (apt, apk, dnf, yum, pacman)
# - Instala dependencias mínimas
# - Instala/actualiza Flutter (stable) en $HOME/flutter
# - Habilita soporte Web y hace precache
set -euo pipefail

log() { echo -e "\033[1;36m[setup]\033[0m $*"; }
warn() { echo -e "\033[1;33m[setup][warn]\033[0m $*" >&2; }
err()  { echo -e "\033[1;31m[setup][error]\033[0m $*" >&2; exit 1; }

# 0) Ejecutar como root o con sudo si hace falta
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    warn "No eres root y no hay 'sudo'. Intento continuar (algunas instalaciones pueden fallar)."
  fi
fi

# 1) Detectar gestor de paquetes
PM=""
if   command -v apt-get >/dev/null 2>&1; then PM="apt"
elif command -v apk     >/dev/null 2>&1; then PM="apk"
elif command -v dnf     >/dev/null 2>&1; then PM="dnf"
elif command -v yum     >/dev/null 2>&1; then PM="yum"
elif command -v pacman  >/dev/null 2>&1; then PM="pacman"
fi
log "Gestor de paquetes: ${PM:-ninguno}"

# 2) Instalar dependencias
case "$PM" in
  apt)
    $SUDO apt-get update -y
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y \
      git curl unzip xz-utils zip ca-certificates pkg-config \
      libglu1-mesa bash
    ;;
  apk)
    $SUDO apk update
    $SUDO apk add --no-cache git curl unzip xz zip bash ca-certificates mesa-glu
    $SUDO update-ca-certificates || true
    ;;
  dnf)
    $SUDO dnf install -y git curl unzip xz zip ca-certificates mesa-libGLU bash
    ;;
  yum)
    $SUDO yum install -y git curl unzip xz zip ca-certificates mesa-libGLU bash
    ;;
  pacman)
    $SUDO pacman -Sy --noconfirm git curl unzip xz zip ca-certificates glu bash
    ;;
  *)
    warn "No se detectó un gestor compatible. Continuo sin instalar dependencias del sistema."
    ;;
esac

# 3) Instalar/actualizar Flutter (stable) en $HOME/flutter
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  log "Clonando Flutter (stable) en $FLUTTER_DIR..."
  git clone --depth=1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  log "Actualizando Flutter existente en $FLUTTER_DIR..."
  git -C "$FLUTTER_DIR" fetch --depth=1 origin stable || true
  git -C "$FLUTTER_DIR" checkout stable || true
  git -C "$FLUTTER_DIR" pull --ff-only || true
fi

# 4) Añadir Flutter al PATH de forma persistente
if ! echo "$PATH" | grep -q "$FLUTTER_DIR/bin"; then
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi
for RC in "$HOME/.bashrc" "$HOME/.profile" ; do
  if [ -f "$RC" ] && ! grep -q 'flutter/bin' "$RC"; then
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$RC"
  fi
done

# 5) Preparar Flutter para Web
log "Precache + habilitar web…"
flutter --version
flutter precache --web
flutter config --enable-web

# 6) Diagnóstico
log "Doctor:"
flutter doctor -v || true

log "Listo. Puedes lanzar la app con:"
echo "  flutter pub get"
echo "  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5173"
