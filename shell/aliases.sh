#!/usr/bin/env bash
#
# Optional. Source this from your shell rc (~/.bashrc, ~/.zshrc) to route a
# bare `claude` invocation through claude-hopper instead of the real client.
# That way you can't accidentally launch claude outside of a profile and end
# up talking to the default, unmanaged ~/.claude config.
#
#   claude              -> lists profiles (claude-hopper with no args)
#   claude work [args]  -> claude-hopper work [args]
#
# Requires claude-hopper on PATH; see install.sh.

alias claude='claude-hopper'
