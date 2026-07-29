#!/usr/bin/env bash
#
# install.sh - Installer for the `openshift` CLI wizard.
#
# Copies the `openshift` script into a directory on the user's PATH,
# preferring ~/.local/bin and falling back to /usr/local/bin (which may
# require sudo). Installs a standalone copy (not a symlink), so this repo
# can be safely moved or deleted afterward -- rerun this script to pick up
# future changes to the source script.
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_PATH="$SCRIPT_DIR/openshift"
readonly BIN_NAME="openshift"

# Brand color palette (green heading, blue info, teal success, pink warn,
# orange error), with a safe fallback when not a TTY. Mirrors the main
# `openshift` script's UI so install/uninstall look consistent with it.
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  if [[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]]; then
    C_BRAND="$(printf '\033[38;2;0;102;51m')"     # #006633
    C_INFO="$(printf '\033[38;2;0;167;225m')"     # #00A7E1
    C_SUCCESS="$(printf '\033[38;2;22;224;189m')" # #16E0BD
    C_WARN="$(printf '\033[38;2;246;92;162m')"    # #F65CA2
    C_ERROR="$(printf '\033[38;2;242;79;0m')"     # #F24F00
  else
    C_BRAND="$(tput setaf 2)"
    C_INFO="$(tput setaf 4)"
    C_SUCCESS="$(tput setaf 6)"
    C_WARN="$(tput setaf 5)"
    C_ERROR="$(tput setaf 1)"
  fi
  C_BOLD="$(tput bold)"; C_RESET="$(tput sgr0)"
else
  C_BRAND=""; C_INFO=""; C_SUCCESS=""; C_WARN=""; C_ERROR=""; C_BOLD=""; C_RESET=""
fi

info()    { printf '%s%s%s\n' "$C_INFO" "$*" "$C_RESET"; }
success() { printf '%s%s%s\n' "$C_SUCCESS" "$*" "$C_RESET"; }
warn()    { printf '%s%s%s\n' "$C_WARN" "$*" "$C_RESET"; }
error()   { printf '%s%s%s\n' "$C_ERROR" "$*" "$C_RESET" >&2; }
heading() { printf '%s%s%s\n' "$C_BOLD$C_BRAND" "$*" "$C_RESET"; }

heading "Installing $BIN_NAME"

if [[ ! -f "$SOURCE_PATH" ]]; then
  error "Error: could not find '$SOURCE_PATH'. Run this installer from within the repo."
  exit 1
fi

chmod +x "$SOURCE_PATH"

target_dir="$HOME/.local/bin"
if [[ ! -d "$target_dir" ]]; then
  mkdir -p "$target_dir" 2>/dev/null || target_dir="/usr/local/bin"
fi

target_path="$target_dir/$BIN_NAME"

if [[ -w "$target_dir" ]]; then
  cp "$SOURCE_PATH" "$target_path"
else
  info "Elevated permissions required to write to $target_dir"
  sudo cp "$SOURCE_PATH" "$target_path"
fi
chmod +x "$target_path" 2>/dev/null || true

success "Installed: $target_path (standalone copy of $SOURCE_PATH)"

case ":$PATH:" in
  *":$target_dir:"*)
    info "You're all set. Run '$BIN_NAME' from anywhere."
    ;;
  *)
    warn "Warning: $target_dir is not on your PATH."
    warn "Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    warn "  export PATH=\"$target_dir:\$PATH\""
    ;;
esac
