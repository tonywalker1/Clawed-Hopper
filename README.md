# Clawed-Hopper

Manage multiple Claude Code "profiles" — isolated `~/.claude`-style config
directories (auth, settings, sessions) that share a common `CLAUDE.md`,
skills, commands, and agents via symlinks.

## Layout

```
~/.claude/
  shared/                     content common to every profile (sync this)
    CLAUDE.md  skills/  commands/  agents/
  work/                       a profile
    .claude-hopper            marker: this directory is a profile
    CLAUDE.md -> ../shared/CLAUDE.md
    skills    -> ../shared/skills
    settings.json             real file, profile-specific
    .credentials.json         real file, local only
    projects/ todos/ ...      per-session state
  home/                       another profile
```

Every top-level entry in `shared/` is symlinked into each profile. Per-profile
state (credentials, sessions, settings) is never linked out of `shared/`.

## Install

```sh
./install.sh              # symlinks bin/claude-hopper into ~/.local/bin
./install.sh /some/dir    # or another directory on your PATH
```

## Usage

```sh
claude-hopper                    # list profiles
claude-hopper work [args...]     # launch claude with the "work" profile
claude-hopper --relink [NAME]    # repair shared links only (no launch)
claude-hopper --adopt NAME       # mark an existing directory as a profile
claude-hopper --path NAME        # print the resolved config dir
```

See `bin/claude-hopper` for the full layout, options, and environment
variables (`CLAUDE_HOPPER_ROOT`, `CLAUDE_HOPPER_SHARED`, `CLAUDE_HOPPER_BIN`).
