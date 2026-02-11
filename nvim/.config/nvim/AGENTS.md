# AGENTS.md

Guidance for agentic coding tools working in this repository.
Apply these rules unless a user request explicitly overrides them.

## 1) Repository Snapshot

- Project type: Neovim user configuration (Lua), built on NvChad.
- Entry point: `init.lua`.
- Main code lives in `lua/` modules:
  - `lua/options.lua`
  - `lua/mappings.lua`
  - `lua/autocmds.lua`
  - `lua/configs/*.lua`
  - `lua/plugins/init.lua`
- Plugin manager: `lazy.nvim`.
- Lockfile: `lazy-lock.json`.
- Primary language: Lua (no TypeScript/Python/etc. in active source).

## 2) Rule Files Discovered

Checked paths:

- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`

Current status:
- No Cursor rule files found.
- No Copilot instruction file found.
- Re-check these paths before major edits; if found later, treat as higher-priority guidance.

## 3) Build / Lint / Test Commands

This repo does not currently define a formal build/lint/test pipeline.

### 3.1 Environment / Setup

- Sync plugins interactively: open Neovim and run `:Lazy sync`.
- Sync plugins headless:
  `nvim --headless "+Lazy! sync" +qa`

### 3.2 Build

- Build step: not applicable (configuration repo, no artifact build).
- Equivalent health/smoke checks:
  - `nvim --headless +qa`
  - `nvim --headless "+checkhealth" +qa` (informational diagnostics)

### 3.3 Lint / Format

- No dedicated linter is configured in-repo.
- Formatting is configured through Conform using `stylua` for Lua.
- If `stylua` is installed locally, use:
  - Entire repo: `stylua .`
  - Single file: `stylua lua/mappings.lua`

If lint tooling is added later (for example `luacheck` or `selene`),
prefer project-level wrapper commands and document them here.

### 3.4 Test

- No automated test suite is currently present.
- There is no `tests/` directory or test runner config at this time.

### 3.5 Single-Test Execution (Important)

Since tests are not configured yet, there is no active single-test command.
If tests are introduced, use the command that matches the chosen framework:

- Plenary-based tests (common for Neovim Lua):
  - Run all tests file: `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }" -c qa`
  - Run a single test file: `nvim --headless -c "PlenaryBustedFile tests/path/to/file_spec.lua" -c qa`

- Busted CLI:
  - Run all: `busted tests`
  - Run one file: `busted tests/path/to/file_spec.lua`
  - Run one test name: `busted tests/path/to/file_spec.lua --filter "name pattern"`

Agent expectation:
- When adding a test framework, add canonical commands in this section.
- Prefer a scriptable command that can run in CI/headless contexts.

## 4) Code Style and Engineering Conventions

No enforced formatter/linter config is committed yet, so follow these defaults.

### 4.1 Module / Import Style

- Use Lua modules with `require` and explicit `return` tables.
- Prefer local module imports at top of file when reused.
- Keep module boundaries clear:
  - plugin specs in `lua/plugins/init.lua`
  - plugin config in `lua/configs/*.lua`
  - editor behavior in `lua/options.lua`, `lua/mappings.lua`, `lua/autocmds.lua`
- Avoid global variables except Neovim-intended globals (`vim.g.*`).

### 4.2 Formatting

- Use UTF-8 and LF line endings.
- Prefer 2-space indentation in Lua source.
- Keep lines reasonably short (target around 100 chars).
- Use trailing commas in multiline tables.
- Preserve existing formatting in touched files; avoid unrelated mass reformatting.

### 4.3 Types / Annotations

- Lua is dynamically typed; use EmmyLua annotations sparingly when helpful.
- Keep function contracts explicit through names and guard clauses.
- Validate inputs from external boundaries (filesystem, shell commands, user commands).

### 4.4 Naming

- File names: lowercase kebab/flat style already used (`options.lua`, `nvimtree.lua`).
- Module tables: `local M = {}` pattern when exporting structured config.
- Local variables/functions: `snake_case` or clear lower-case names consistent with file.
- Constants: upper snake case only when true constants improve clarity.

### 4.5 Error Handling

- Fail fast for invalid state and return early.
- Use `vim.notify(..., vim.log.levels.<LEVEL>)` for user-facing errors/warnings.
- Include actionable context in messages (what failed and which file/path).
- Check executable/tool availability before use (`vim.fn.executable`).

### 4.6 Plugin Specs and Config Layout

- Keep plugin declarations declarative in `lua/plugins/init.lua`.
- Put option tables into `lua/configs/*.lua` and reference via `opts = require "..."`.
- Keep plugin-specific keymaps near mappings, not scattered across files.
- Avoid duplicate behavior between NvChad defaults and local overrides.

### 4.7 Performance / UX

- Prefer lazy-loading where appropriate.
- Avoid expensive work on startup unless necessary.
- Use autocommands narrowly scoped by event/filetype to minimize overhead.

### 4.8 Backwards Compatibility
- Preserve existing keymaps and expected UX unless a change is requested.
- For behavioral changes, document the new behavior in `README.md` when relevant.

## 5) Agent Workflow Expectations

- Read relevant files before editing.
- Make minimal, targeted diffs.
- Do not rewrite unrelated style/formatting.
- When adding tools (lint/test), document commands in this file.
- After edits, run the most relevant verification command available.
- In final notes, include:
  - files changed,
  - commands run,
  - skipped checks and why.

## 6) If the Repository Evolves

When new tooling/config appears, update this document promptly:

- Add concrete build/lint/test commands.
- Add canonical single-test commands for the selected test framework.
- Re-scan and incorporate Cursor/Copilot rule files.
- Replace provisional guidance with project-enforced rules.
