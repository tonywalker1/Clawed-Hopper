#!/usr/bin/env bash
#
# install.sh -- symlink bin/claude-hopper into a directory on PATH.
#
# Usage:
#   ./install.sh [DEST_DIR]     (default: $HOME/.local/bin)
#
# Idempotent: safe to re-run. If DEST_DIR/claude-hopper already points here,
# nothing happens. If it's a real file (not a symlink), it's backed up
# before being replaced.

set -o errexit
set -o nounset
set -o pipefail

readonly PROGNAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SRC="$REPO_ROOT/bin/claude-hopper"

DEST_DIR="${1:-$HOME/.local/bin}"
DEST="$DEST_DIR/claude-hopper"

die() {
    printf '%s: error: %s\n' "$PROGNAME" "$*" >&2
    exit 1
}

[[ -x "$SRC" ]] || die "source script not found or not executable: $SRC"

mkdir -p "$DEST_DIR"

if [[ -L "$DEST" ]]; then
    current="$(readlink "$DEST")"
    if [[ "$current" == "$SRC" ]]; then
        printf '%s: already installed: %s -> %s\n' "$PROGNAME" "$DEST" "$SRC"
        exit 0
    fi
    printf '%s: replacing existing symlink %s (was -> %s)\n' "$PROGNAME" "$DEST" "$current"
elif [[ -e "$DEST" ]]; then
    backup="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
    printf '%s: %s exists and is not a symlink; backing up to %s\n' "$PROGNAME" "$DEST" "$backup"
    mv "$DEST" "$backup"
fi

ln -sfn "$SRC" "$DEST"
printf '%s: installed %s -> %s\n' "$PROGNAME" "$DEST" "$SRC"

case ":$PATH:" in
    *":$DEST_DIR:"*) ;;
    *) printf '%s: note: %s is not on your PATH\n' "$PROGNAME" "$DEST_DIR" ;;
esac
