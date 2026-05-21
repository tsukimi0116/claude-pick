#!/usr/bin/env bash
# claude-pick installer
# Usage:
#   Local:  ./install.sh
#   Remote: curl -fsSL https://raw.githubusercontent.com/tsukimi0116/claude-pick/main/install.sh | bash

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/claude-pick"
SCRIPT_NAME="claude-pick.sh"
TARGET_SCRIPT="$BIN_DIR/$SCRIPT_NAME"
CMD_NAME="${CLAUDE_PICK_CMD:-cdc}"

REMOTE_URL="${CLAUDE_PICK_REMOTE:-https://raw.githubusercontent.com/tsukimi0116/claude-pick/main/$SCRIPT_NAME}"

SENTINEL="# >>> claude-pick >>>"
SENTINEL_END="# <<< claude-pick <<<"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31mx\033[0m %s\n' "$*" >&2; }

detect_rc() {
    case "$(basename "${SHELL:-}")" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) [ -f "$HOME/.bashrc" ] && echo "$HOME/.bashrc" || echo "$HOME/.bash_profile" ;;
        *)    echo "$HOME/.profile" ;;
    esac
}

install_script() {
    mkdir -p "$BIN_DIR"
    local here
    here="$(cd "$(dirname "$0")" 2>/dev/null && pwd || pwd)"
    if [ -f "$here/$SCRIPT_NAME" ]; then
        info "Copying $SCRIPT_NAME from $here"
        cp "$here/$SCRIPT_NAME" "$TARGET_SCRIPT"
    else
        info "Downloading $SCRIPT_NAME from $REMOTE_URL"
        if ! curl -fsSL "$REMOTE_URL" -o "$TARGET_SCRIPT"; then
            err "Download failed. Set CLAUDE_PICK_REMOTE or run from a local clone."
            exit 1
        fi
    fi
    chmod +x "$TARGET_SCRIPT"
}

write_config() {
    mkdir -p "$CONFIG_DIR"
    local cfg="$CONFIG_DIR/config"
    if [ -f "$cfg" ]; then
        info "Config already exists at $cfg — leaving as is"
        return
    fi
    info "Creating default config at $cfg"
    cat > "$cfg" <<'EOF'
# claude-pick configuration

# Path containing your project folders.
CLAUDE_PICK_ROOT="$HOME/Desktop/97"

# Comma-separated folder names that should drill into sub-folders.
# Picking one of these from the first list opens a second list.
CLAUDE_PICK_NESTED="config"

# Command run by `cdc` after cd-ing into the project. Defaults to plain `claude`.
# Use this to add flags or wrap with caffeinate.
# Example: CLAUDE_PICK_LAUNCH="caffeinate -ims claude --dangerously-skip-permissions"
# CLAUDE_PICK_LAUNCH="claude"
EOF
}

write_shell_function() {
    local rc="$1"
    if grep -q "$SENTINEL" "$rc" 2>/dev/null; then
        info "Shell hook already present in $rc — skipping"
        return
    fi
    info "Adding shell function '$CMD_NAME' to $rc"
    cat >> "$rc" <<EOF

$SENTINEL
export PATH="\$HOME/.local/bin:\$PATH"
$CMD_NAME() {
    local target
    target=\$(claude-pick.sh) || return
    [ -z "\$target" ] && return
    cd "\$target" || return
    if [ -f .nvmrc ] && command -v nvm >/dev/null 2>&1; then
        nvm use >/dev/null
    fi
    [ -f "\$HOME/.config/claude-pick/config" ] && source "\$HOME/.config/claude-pick/config"
    eval "\${CLAUDE_PICK_LAUNCH:-claude}"
}
${CMD_NAME}o() {
    local target
    target=\$(claude-pick.sh) || return
    [ -z "\$target" ] && return
    cd "\$target" || return
}
$SENTINEL_END
EOF
}

check_deps() {
    if ! command -v fzf >/dev/null 2>&1; then
        warn "fzf is required but not installed. The '$CMD_NAME' command will fail until you install it:"
        if [ "$(uname)" = "Darwin" ]; then
            warn "  brew install fzf"
        else
            warn "  see https://github.com/junegunn/fzf#installation"
        fi
    fi
    if ! command -v claude >/dev/null 2>&1; then
        warn "'claude' CLI not found in PATH — install it before running '$CMD_NAME'."
    fi
}

main() {
    install_script
    write_config
    local rc
    rc="$(detect_rc)"
    write_shell_function "$rc"
    check_deps
    echo
    info "Installed."
    echo "  Script:  $TARGET_SCRIPT"
    echo "  Config:  $CONFIG_DIR/config"
    echo "  Command: $CMD_NAME"
    echo
    echo "Reload your shell:  source $rc"
    echo "Then run:           $CMD_NAME"
}

main "$@"
