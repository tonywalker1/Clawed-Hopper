#!/usr/bin/env bash
#
# check-paths.sh -- fail if tracked files contain an absolute home directory
# path (/home/<user>/... or /Users/<user>/...). Those are machine-specific and
# must not be committed; use $HOME, a resolved $BASH_SOURCE, or a documented
# placeholder such as /path/to/Clawed-Hopper instead.
#
# Usage:
#   tools/check-paths.sh [FILE...]     (default: every tracked file)
#
# Run automatically by .githooks/pre-commit; see README for how to enable it.

set -o errexit
set -o nounset
set -o pipefail

readonly PROGNAME="${0##*/}"

# /home/<user>/ and /Users/<user>/, but not the literal placeholders we allow.
readonly PATTERN='(/home|/Users)/[A-Za-z0-9._-]+/'
readonly ALLOWED='/(home|Users)/(<[A-Za-z]+>|\.\.\.|USER|user)/'

files=("$@")
if ((${#files[@]} == 0)); then
    mapfile -t files < <(git ls-files)
fi

status=0
for file in "${files[@]}"; do
    # Skip this checker and the hook: both legitimately contain the pattern.
    case "$file" in
        tools/check-paths.sh | .githooks/*) continue ;;
    esac
    [[ -f "$file" ]] || continue
    grep -Iq . "$file" 2>/dev/null || continue  # binary

    while IFS= read -r hit; do
        printf '%s: %s\n' "$PROGNAME" "$hit" >&2
        status=1
    done < <(grep -nE "$PATTERN" "$file" 2>/dev/null | grep -vE "$ALLOWED" | sed "s|^|$file:|")
done

if ((status != 0)); then
    printf '%s: error: absolute home paths found; use $HOME or a relative/resolved path\n' "$PROGNAME" >&2
fi

exit "$status"
