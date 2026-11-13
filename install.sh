#!/usr/bin/env bash
set -euo pipefail
say(){ printf '==> %s\n' "$*"; }
fail(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$BASE/src/boveda" ]] || fail 'Ejecuta install.sh desde el proyecto completo.'
command -v python3 >/dev/null || fail 'Falta Python 3 (>= 3.9).'
python3 -c 'import sys; assert sys.version_info >= (3,9), "Se requiere Python >=3.9"' || fail 'Python obsoleto.'
OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS" in
 Darwin)
  if ! command -v brew >/dev/null; then
    [[ -x /opt/homebrew/bin/brew ]] && export PATH="/opt/homebrew/bin:$PATH"
    [[ -x /usr/local/bin/brew ]] && export PATH="/usr/local/bin:$PATH"
  fi
  command -v brew >/dev/null || fail 'Instala Homebrew desde https://brew.sh'
  if ! command -v age >/dev/null || ! command -v fido2-token >/dev/null; then brew install age libfido2; fi
  target_os=darwin ;;
 Linux)
  command -v apt-get >/dev/null || fail 'Linux soportado: Debian/Ubuntu con apt-get.'
  if ! command -v age >/dev/null || ! command -v fido2-token >/dev/null || ! command -v curl >/dev/null; then
    say 'Instalando dependencias con APT (puede pedir sudo)'
    sudo apt-get update
    sudo apt-get install -y age libfido2-1 libfido2-dev fido2-tools curl ca-certificates python3
  fi
  target_os=linux ;;
 *) fail 'Sistema soportado: macOS, Debian y Ubuntu.' ;;
esac
case "$ARCH" in
 arm64|aarch64) target_arch=arm64 ;;
 x86_64|amd64) target_arch=amd64 ;;
 *) fail "Arquitectura no soportada: $ARCH" ;;
esac
BIN="$HOME/.local/bin"
mkdir -p "$BIN" "$HOME/.local/share/zsh/site-functions" "$HOME/.local/share/bash-completion/completions"
chmod 700 "$BIN"
if [[ ! -x "$BIN/age-plugin-fido2-hmac" ]] && ! command -v age-plugin-fido2-hmac >/dev/null 2>&1; then
  say 'Descargando el plugin FIDO2 experimental v0.5.0 desde su release oficial'
  command -v curl >/dev/null || fail 'Falta curl'
  t="$(mktemp -d)"; trap 'rm -rf "$t"' EXIT
  url="https://github.com/olastor/age-plugin-fido2-hmac/releases/download/v0.5.0/age-plugin-fido2-hmac-v0.5.0-${target_os}-${target_arch}.tar.gz"
  curl --fail --location --show-error --silent --proto '=https' --tlsv1.2 "$url" -o "$t/plugin.tar.gz"
  tar -tzf "$t/plugin.tar.gz" | grep -qx 'age-plugin-fido2-hmac/age-plugin-fido2-hmac' || fail 'Estructura inesperada de plugin.'
  tar -xzf "$t/plugin.tar.gz" -C "$t" age-plugin-fido2-hmac/age-plugin-fido2-hmac
  install -m 755 "$t/age-plugin-fido2-hmac/age-plugin-fido2-hmac" "$BIN/age-plugin-fido2-hmac"
  say 'ADVERTENCIA: binario de tercero sin hash/firma verificados; audita la release si usas datos sensibles.'
fi
[[ ! -f "$BIN/boveda" ]] || cp -p "$BIN/boveda" "$BIN/boveda.backup-$(date +%Y%m%d-%H%M%S)"
install -m 700 "$BASE/src/boveda" "$BIN/boveda"
install -m 644 "$BASE/completions/_boveda" "$HOME/.local/share/zsh/site-functions/_boveda"
install -m 644 "$BASE/completions/boveda.bash" "$HOME/.local/share/bash-completion/completions/boveda"
# Shell-specific installation (idempotent markers)
if [[ -f "$HOME/.zshrc" ]] || command -v zsh >/dev/null 2>&1; then
  touch "$HOME/.zshrc"
  if ! grep -Fq '# >>> boveda fido2 >>>' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" <<'EOF'

# >>> boveda fido2 >>>
export PATH="$HOME/.local/bin:$PATH"
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
autoload -Uz compinit
compinit
# <<< boveda fido2 <<<
EOF
  fi
fi
if [[ -f "$HOME/.bashrc" ]] || [[ "$OS" == Linux ]]; then
  touch "$HOME/.bashrc"
  if ! grep -Fq '# >>> boveda fido2 >>>' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# >>> boveda fido2 >>>
export PATH="$HOME/.local/bin:$PATH"
if [[ -r "$HOME/.local/share/bash-completion/completions/boveda" ]]; then
  source "$HOME/.local/share/bash-completion/completions/boveda"
fi
# <<< boveda fido2 <<<
EOF
  fi
fi
say 'Instalación terminada. Abre una terminal nueva o ejecuta:'
printf '  export PATH="$HOME/.local/bin:$PATH"\n  boveda estado\n'
say 'En una instalación nueva: boveda configurar'
say 'Para conservar tus claves previas, NO borres ~/BovedaFIDO2'
