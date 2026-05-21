# claude-pick

[Claude Code](https://claude.com/claude-code) 的互動式專案選單。輸入一個指令，從你的專案資料夾以 fuzzy filter 挑一個專案，腳本會在當前 shell 自動 `cd` 過去並啟動 `claude`。

支援第二層下鑽（例如 `config/` 資料夾底下還有各站台的 config 子專案）。

## 需求

- macOS 或 Linux
- `PATH` 中已有 `claude` CLI
- [`fzf`](https://github.com/junegunn/fzf) — 選單必要依賴（macOS：`brew install fzf`）
- `nvm`（選用）— 若專案內有 `.nvmrc` 會自動 `nvm use`

## 安裝

一行安裝：

```bash
curl -fsSL https://raw.githubusercontent.com/tsukimi0116/claude-pick/main/install.sh | bash
```

或 clone 之後執行：

```bash
git clone https://github.com/tsukimi0116/claude-pick.git
cd claude-pick
./install.sh
```

接著重新載入 shell：

```bash
source ~/.zshrc   # 或 ~/.bashrc
```

### 安裝程式做了什麼

1. 把 `claude-pick.sh` 複製到 `~/.local/bin/`
2. 在 `~/.config/claude-pick/config` 建立預設設定檔
3. 在 rc 檔（`.zshrc` / `.bashrc`）加入 `~/.local/bin` 到 `PATH`，並注入 `cdc`、`cdo` 兩個 shell function（用 sentinel 註解包起來，方便日後移除）

採用 shell function 而非普通腳本的原因：只有 function 才能讓 `cd` 生效在當前 shell。

## 設定

用你習慣的編輯器打開設定檔：

```bash
code ~/.config/claude-pick/config   # VS Code
nano ~/.config/claude-pick/config   # nano（Ctrl-O 存、Ctrl-X 離開）
open -e ~/.config/claude-pick/config # macOS 文字編輯器
```

預設內容：

```sh
# 你的專案根目錄
CLAUDE_PICK_ROOT="$HOME/Desktop/97"

# 用逗號分隔的「需要下鑽到第二層」的資料夾名稱
# 從第一層選到這些名稱時，會跳出第二層選單
CLAUDE_PICK_NESTED="config"

# `cdc` 在 cd 完成後實際執行的指令，預設就是 `claude`。
# 想加 flag 或包 caffeinate 防止睡眠時改這裡，不用動 .zshrc。
# CLAUDE_PICK_LAUNCH="caffeinate -ims claude --dangerously-skip-permissions"
```

每個設定值也可用同名環境變數覆寫（環境變數優先於設定檔）。

**改完馬上生效**，不用 `source ~/.zshrc` 也不用重開終端機 — 每次跑 `cdc` / `cdo` 都會重新讀設定檔。

### 範例

換到不同的專案根目錄：

```sh
CLAUDE_PICK_ROOT="$HOME/work/projects"
```

多個需要下鑽的資料夾（逗號分隔，不要加空白）：

```sh
CLAUDE_PICK_NESTED="config,clients,sites"
```

→ 之後選到 `config`、`clients`、或 `sites` 都會跳第二層。

把 `cdc` 改成「防睡眠 + 跳過權限提示」版本：

```sh
CLAUDE_PICK_LAUNCH="caffeinate -ims claude --dangerously-skip-permissions"
```

→ 之後打 `cdc` 就等同於 `caffeinate -ims claude --dangerously-skip-permissions`。

只想暫時用別的根目錄試試（不改設定檔）：

```bash
CLAUDE_PICK_ROOT="$HOME/personal" cdc
```

### 改指令名稱

預設為 `cdc`。若想改名，兩種方式擇一：

- 安裝時帶環境變數：`CLAUDE_PICK_CMD=mycmd ./install.sh`
- 直接編輯 rc 檔內的 function 名稱

## 用法

安裝後會有兩個指令，共用同一個選單：

| 指令 | 行為 |
|---|---|
| `cdc`  | 當前 shell `cd` 到所選專案 → 若有 `.nvmrc` 跑 `nvm use` → 啟動 `claude` |
| `cdo`  | 當前 shell `cd` 到所選專案（不跑 nvm、不啟動 claude） |

選單操作：直接打字即可 fuzzy filter，`↑↓` 移動、`Enter` 確認、`Esc` 取消。被列入 `CLAUDE_PICK_NESTED` 的資料夾選到時會跳出第二層選單。

## 解除安裝

刪除 rc 檔內 sentinel 區塊：

```
# >>> claude-pick >>>
...
# <<< claude-pick <<<
```

接著：

```bash
rm ~/.local/bin/claude-pick.sh
rm -rf ~/.config/claude-pick
```

## 運作原理

`claude-pick.sh` 只做一件事：把選到的絕對路徑印到 stdout，其他什麼都不輸出。shell function 用 `$(...)` 抓取結果，在當前 shell 跑 `cd` + `claude`。`fzf` 的選單介面直接渲染在終端機上，不會污染 stdout，所以路徑抓取一直是乾淨的。

## 授權

MIT

---

# claude-pick (English)

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
3. Adds `~/.local/bin` to `PATH` and `cdc` / `cdo` shell functions to your rc file (wrapped in sentinel comments so it's easy to remove)

The shell function (rather than a plain script) is what lets `cd` persist in your current terminal.

## Configuration

Open the config file in your editor of choice:

```bash
code ~/.config/claude-pick/config    # VS Code
nano ~/.config/claude-pick/config    # nano (Ctrl-O to save, Ctrl-X to exit)
open -e ~/.config/claude-pick/config # macOS TextEdit
```

Default contents:

```sh
# Path containing your project folders
CLAUDE_PICK_ROOT="$HOME/Desktop/97"

# Comma-separated folder names that should drill into sub-folders.
# Picking one of these from the first list opens a second list.
CLAUDE_PICK_NESTED="config"

# Command run by `cdc` after cd-ing into the project. Defaults to `claude`.
# Use this to add flags or wrap with caffeinate without touching .zshrc.
# CLAUDE_PICK_LAUNCH="caffeinate -ims claude --dangerously-skip-permissions"
```

Every value can also be overridden by an environment variable of the same name (env takes precedence over config).

**Changes apply immediately** — no need to `source ~/.zshrc` or restart your terminal. `cdc` / `cdo` reads the config on every run.

### Examples

Point to a different projects folder:

```sh
CLAUDE_PICK_ROOT="$HOME/work/projects"
```

Drill into multiple folders (comma-separated, no spaces):

```sh
CLAUDE_PICK_NESTED="config,clients,sites"
```

→ Picking `config`, `clients`, or `sites` from the first list opens a second list of their sub-folders.

Make `cdc` run claude with sleep-prevention and skip-permissions flags:

```sh
CLAUDE_PICK_LAUNCH="caffeinate -ims claude --dangerously-skip-permissions"
```

→ Typing `cdc` is now equivalent to running the full command above.

Try a different root once without editing the config:

```bash
CLAUDE_PICK_ROOT="$HOME/personal" cdc
```

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

`claude-pick.sh` prints the selected absolute path to stdout and nothing else. The shell function captures it with `$(...)` and runs `cd` + `claude` in your current shell. The `fzf` picker UI renders directly on the terminal, not on stdout, so the capture stays clean.

## License

MIT
