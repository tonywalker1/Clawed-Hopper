#!/usr/bin/env bash
#
# install.sh -- symlink bin/claude-hopper onto PATH, and (if ~/.bashrc.d
# exists) the optional `claude` alias drop-in into it.
#
# Usage:
#   ./install.sh [DEST_DIR]     (default: $HOME/.local/bin)
#
# Idempotent: safe to re-run. If a destination already points at the repo,
# nothing happens. If it's a real file (not a symlink), it's backed up
# before being replaced.

set -o errexit
set -o nounset
set -o pipefail

readonly PROGNAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEST_DIR="${1:-$HOME/.local/bin}"

die() {
    printf '%s: error: %s\n' "$PROGNAME" "$*" >&2
    exit 1
}

# link_into SRC DEST -- create/repair a symlink, backing up a real file.
link_into() {
    local src="$1" dest="$2"

    if [[ -L "$dest" ]]; then
        local current
        current="$(readlink "$dest")"
        if [[ "$current" == "$src" ]]; then
            printf '%s: already installed: %s -> %s\n' "$PROGNAME" "$dest" "$src"
            return 0
        fi
        printf '%s: replacing existing symlink %s (was -> %s)\n' "$PROGNAME" "$dest" "$current"
    elif [[ -e "$dest" ]]; then
        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        printf '%s: %s exists and is not a symlink; backing up to %s\n' "$PROGNAME" "$dest" "$backup"
        mv "$dest" "$backup"
    fi

    ln -sfn "$src" "$dest"
    printf '%s: installed %s -> %s\n' "$PROGNAME" "$dest" "$src"
}

src="$REPO_ROOT/bin/claude-hopper"
dest="$DEST_DIR/claude-hopper"
[[ -x "$src" ]] || die "source script not found or not executable: $src"
mkdir -p "$DEST_DIR"
link_into "$src" "$dest"

case ":$PATH:" in
    *":$DEST_DIR:"*) ;;
    *) printf '%s: note: %s is not on your PATH\n' "$PROGNAME" "$DEST_DIR" ;;
esac

if [[ -d "$HOME/.bashrc.d" ]]; then
    link_into "$REPO_ROOT/shell/bashrc.d/claude-aliases" "$HOME/.bashrc.d/claude-aliases"
fi
