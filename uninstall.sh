#!/usr/bin/env bash
#
# uninstall.sh - Removes the `openshift` CLI wizard from this machine.
#
# Only removes files that were installed by install.sh / `openshift --install`
# (i.e. symlinks pointing back at this repo's `openshift` script). It never
# touches unrelated files, your oc kubeconfig, or any oc contexts.
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_PATH="$SCRIPT_DIR/openshift"
readonly BIN_NAME="openshift"
readonly CANDIDATE_DIRS=("$HOME/.local/bin" "/usr/local/bin")

# Brand color palette (green heading, blue info, teal success, pink warn),
# with a safe fallback when not a TTY. Mirrors the main `openshift` script's
# UI so install/uninstall look consistent with it.
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  if [[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]]; then
    C_BRAND="$(printf '\033[38;2;0;102;51m')"     # #006633
    C_INFO="$(printf '\033[38;2;0;167;225m')"     # #00A7E1
    C_SUCCESS="$(printf '\033[38;2;22;224;189m')" # #16E0BD
    C_WARN="$(printf '\033[38;2;246;92;162m')"    # #F65CA2
  else
    C_BRAND="$(tput setaf 2)"
    C_INFO="$(tput setaf 4)"
    C_SUCCESS="$(tput setaf 6)"
    C_WARN="$(tput setaf 5)"
  fi
  C_BOLD="$(tput bold)"; C_RESET="$(tput sgr0)"
else
  C_BRAND=""; C_INFO=""; C_SUCCESS=""; C_WARN=""; C_BOLD=""; C_RESET=""
fi

info()    { printf '%s%s%s\n' "$C_INFO" "$*" "$C_RESET"; }
success() { printf '%s%s%s\n' "$C_SUCCESS" "$*" "$C_RESET"; }
warn()    { printf '%s%s%s\n' "$C_WARN" "$*" "$C_RESET"; }
heading() { printf '%s%s%s\n' "$C_BOLD$C_BRAND" "$*" "$C_RESET"; }

heading "Uninstalling $BIN_NAME"

removed_any=0

for dir in "${CANDIDATE_DIRS[@]}"; do
  candidate="$dir/$BIN_NAME"

  # Only act on this path if it actually exists.
  [[ -e "$candidate" || -L "$candidate" ]] || continue

  # Safety check: only remove it if it's a symlink pointing at *our* script.
  # This avoids deleting an unrelated file some other tool may have placed
  # at the same path.
  if [[ -L "$candidate" ]]; then
    link_target="$(readlink "$candidate")"
    if [[ "$link_target" != "$SOURCE_PATH" ]]; then
      warn "Skipping $candidate: it does not point to this repo's 'openshift' script (points to '$link_target')."
      continue
    fi
  else
    warn "Skipping $candidate: it is a regular file, not a symlink created by this installer."
    continue
  fi

  if [[ -w "$dir" ]]; then
    rm -f "$candidate"
  else
    info "Elevated permissions required to remove $candidate"
    sudo rm -f "$candidate"
  fi

  success "Removed: $candidate"
  removed_any=1
done

if [[ "$removed_any" -eq 0 ]]; then
  warn "Nothing to uninstall: no 'openshift' wizard symlink found in ${CANDIDATE_DIRS[*]}."
else
  info "Uninstall complete. The repository files themselves were left untouched."
fi
