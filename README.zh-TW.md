# claude-pick

[English](README.md) · [繁體中文](README.zh-TW.md)

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

編輯 `~/.config/claude-pick/config`：

```sh
# 你的專案根目錄
CLAUDE_PICK_ROOT="$HOME/Desktop/97"

# 用逗號分隔的「需要下鑽到第二層」的資料夾名稱
# 從第一層選到這些名稱時，會跳出第二層選單
CLAUDE_PICK_NESTED="config"
```

每個設定值也可用同名環境變數覆寫（環境變數優先於設定檔）。

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
