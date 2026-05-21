# claude-pick

An interactive project picker for [Claude Code](https://claude.com/claude-code). Type one command, fuzzy-pick a project from your projects folder, and the script will `cd` into it and launch `claude` in your current shell.

Optional second-level drill-down for "folders of folders" (e.g. a `config/` directory that holds per-site configs).

## Requirements

- macOS or Linux
- `claude` CLI on `PATH`
- [`fzf`](https://github.com/junegunn/fzf) — required for the picker (`brew install fzf` on macOS)
- `nvm` (optional) — used automatically if a project has `.nvmrc`

## Install

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/tsukimi0116/claude-pick/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/tsukimi0116/claude-pick.git
cd claude-pick
./install.sh
```

Then reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

### What the installer does

1. Copies `claude-pick.sh` to `~/.local/bin/`
2. Creates a default config at `~/.config/claude-pick/config`
3. Adds `~/.local/bin` to `PATH` and a `cdc` shell function to your rc file (wrapped in sentinel comments so it's easy to remove)

The shell function (rather than a plain script) is what lets `cd` persist in your current terminal.

## Configuration

Edit `~/.config/claude-pick/config`:

```sh
# Path containing your project folders
CLAUDE_PICK_ROOT="$HOME/Desktop/97"

# Comma-separated folder names that should drill into sub-folders.
# Picking one of these from the first list opens a second list.
CLAUDE_PICK_NESTED="config"
```

Every value can also be overridden by an environment variable of the same name (env takes precedence over config).

### Change the command name

Default command is `cdc`. To use a different name, either:

- Pass `CLAUDE_PICK_CMD=mycmd ./install.sh` at install time, or
- Edit the function name directly in your rc file

## Usage

Two commands are installed; both share the same picker:

| Command | What it does |
|---|---|
| `cdc`  | `cd` into the picked project in the current shell, run `nvm use` if `.nvmrc` exists, then launch `claude` |
| `cdo`  | `cd` into the picked project in the current shell — no `nvm`, no `claude` |

In both, you can type to fuzzy-filter, `↑↓` to move, `Enter` to confirm, `Esc` to cancel. Folders listed in `CLAUDE_PICK_NESTED` open a second picker for their sub-folders.

## Uninstall

Delete the sentinel block in your rc file:

```
# >>> claude-pick >>>
...
# <<< claude-pick <<<
```

Then:

```bash
rm ~/.local/bin/claude-pick.sh
rm -rf ~/.config/claude-pick
```

## How it works

`claude-pick.sh` prints the selected absolute path to stdout and nothing else. The shell function captures it with `$(...)` and runs `cd` + `claude` in your current shell. The picker UI (fzf or the macOS dialog) renders on the terminal/screen directly, not on stdout, so capture stays clean.

## License

MIT
