# Games777 (Cocos2d-x + Lua)

Mobile casino/arcade game client — Lua source for bootstrap, login, lobby, slot games, and fish arcade modules. This repository contains **Lua logic only** (~1000 files); the Cocos2d-x native shell, art assets, and backend servers live elsewhere.

## Repository layout

| Directory | Purpose |
|-----------|---------|
| `bootstrap/` | App entry, navigation config fetch, loading screen |
| `packagelua/` | Login, hot-update downloader, TCP networking |
| `hall/` | Lobby UI, user/VIP, game list, SDK wrappers |
| `FGame*/` | Individual FairyGUI slot game modules |
| `FGameCommon/` | Shared slot framework |
| `fish2/` | Fish-shooting arcade client |
| `cocos/` | Vendored Cocos2d-x Lua bindings |
| `scripts/dev/` | Headless validation tooling (syntax, lint, smoke tests) |

## Development tooling

This repo has no npm/Cargo/Gradle build. Local development uses **Lua 5.1**, **LuaJIT**, and **luacheck** for static validation.

### Run all checks

```bash
./scripts/dev/run_dev_checks.sh
```

This runs:

1. **Syntax check** — `luajit -bl` on all `.lua` files (supports `goto` / labels used in networking code)
2. **Luacheck** — static analysis (warnings are expected for Cocos globals)
3. **Smoke tests** — loads `BuildConfig.json`, exercises `ApkCfg` mapping, Cocos `class()` helpers
4. **Navigation API probe** — optional HTTP GET to the configured navigation endpoint

### Individual commands

```bash
# Smoke tests only
lua5.1 scripts/dev/validate.lua

# Lint entire tree
luacheck .

# Syntax-check one file
luajit -bl bootstrap/src/main.lua
```

## Running the full application

The game **cannot** be launched from this repo alone. End-to-end runtime requires:

1. **Cocos2d-x native app** (Android/iOS) with `gNet`, FairyGUI, Spine, WebView
2. **Navigation HTTP API** — configured in `bootstrap/src/BuildConfig.json`
3. **Asset CDN** — hot-update downloads from `login_download_url`
4. **TCP game gateway** — login/lobby on port from navigation config (often 20000–21000)
5. **Per-game backend** — slot/fish server for the selected game ID

Entry flow: `bootstrap/src/main.lua` → fetch nav config → `packagelua/src/PackageMain.lua` → login → `hall/` lobby → individual game module.

## Cursor Cloud specific instructions

- **No long-running dev server** — there is nothing to `npm run dev`. Validation is the primary local workflow: `./scripts/dev/run_dev_checks.sh`.
- **LuaJIT is required for syntax checks**, not plain Lua 5.1 — many files under `packagelua/src/base/` and `hall/src/pkgs/` use `goto` and `::label::` syntax.
- **Luacheck exits 1 on warnings** — the dev script treats exit codes 0–1 as success; only exit code > 1 indicates hard errors.
- **Navigation API is live** — `BuildConfig.json` points at production navigation hosts. The dev probe performs a read-only GET; do not modify remote state.
- **Full GUI testing** needs the native Cocos2d-x build on a device/emulator with backend credentials — not available in this cloud VM.
