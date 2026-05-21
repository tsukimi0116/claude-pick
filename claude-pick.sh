#!/usr/bin/env bash
# claude-pick — interactive project picker that prints the chosen path to stdout.
# Designed to be called from a shell function so that `cd` + `claude` run in the caller's shell.

set -uo pipefail

CONFIG_FILE="${CLAUDE_PICK_CONFIG:-$HOME/.config/claude-pick/config}"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi

PROJECTS_ROOT="${CLAUDE_PICK_ROOT:-$HOME/Desktop/97}"
NESTED="${CLAUDE_PICK_NESTED:-config}"

err() { printf '%s\n' "$*" >&2; }

require_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        err "fzf is required. Install it first:"
        err "  macOS:  brew install fzf"
        err "  Linux:  see https://github.com/junegunn/fzf#installation"
        exit 1
    fi
}

list_dirs() {
    local dir="$1"
    [ -d "$dir" ] || return 1
    find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -exec basename {} \; 2>/dev/null | LC_ALL=C sort
}

pick() {
    local prompt="$1"
    local header="$2"
    fzf \
        --prompt="$prompt ❯ " \
        --header="$header" \
        --height=60% \
        --reverse \
        --border=rounded \
        --info=inline \
        --pointer="▶" \
        --no-mouse
}

is_nested() {
    local name="$1"
    local IFS=','
    local arr
    read -ra arr <<< "$NESTED"
    for n in "${arr[@]}"; do
        [ "$(printf '%s' "$n" | tr -d ' ')" = "$name" ] && return 0
    done
    return 1
}

main() {
    require_fzf

    if [ ! -d "$PROJECTS_ROOT" ]; then
        err "Projects root not found: $PROJECTS_ROOT"
        err "Set CLAUDE_PICK_ROOT, or edit $CONFIG_FILE"
        exit 1
    fi

    local projects
    projects=$(list_dirs "$PROJECTS_ROOT") || { err "Cannot read $PROJECTS_ROOT"; exit 1; }
    [ -z "$projects" ] && { err "No project folders in $PROJECTS_ROOT"; exit 1; }

    local picked
    picked=$(printf '%s\n' "$projects" | pick "Project" "type to filter · ↑↓ to move · enter to open · esc to cancel")
    [ -z "$picked" ] && exit 0

    if is_nested "$picked"; then
        local sub
        sub=$(list_dirs "$PROJECTS_ROOT/$picked") || { err "Cannot read $picked"; exit 1; }
        [ -z "$sub" ] && { err "No sub-folders in $picked"; exit 1; }
        local picked_sub
        picked_sub=$(printf '%s\n' "$sub" | pick "$picked" "drill into $picked · esc to cancel")
        [ -z "$picked_sub" ] && exit 0
        printf '%s\n' "$PROJECTS_ROOT/$picked/$picked_sub"
    else
        printf '%s\n' "$PROJECTS_ROOT/$picked"
    fi
}

main "$@"
