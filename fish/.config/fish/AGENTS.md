# AGENTS.md

Operational guide for coding agents in this repository.
These rules apply unless the user explicitly overrides them.

## 1) Repository Snapshot
- Repo type: Fish shell configuration.
- Main file: `config.fish`.
- Startup fragments: `conf.d/*.fish`.
- Additional script: `auto-Hypr.fish`.
- No application framework detected.
- No package manager manifest detected.
- No build toolchain detected.
- No test framework detected.
- No linter/formatter config detected.

Agent implications:
- Keep edits minimal and targeted.
- Preserve existing shell behavior unless asked otherwise.
- Prefer Fish-native patterns over POSIX shell assumptions.

## 2) Rule Files Discovery
Checked and currently not found:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`

Agent behavior:
- Re-check these paths before large edits.
- If they appear later, treat them as higher-priority policy.

## 3) Build / Lint / Test Commands
There is no formal build/lint/test pipeline.
Use syntax validation and runtime smoke checks.

### Setup
- No dependency install step is required for this repo.
- Runtime commands referenced by config may include:
  - `fish`
  - `starship`
  - `eza`
  - `qs`

### Build
- Build: not applicable.
- No build script or artifact pipeline exists.

### Lint / Static Checks
- Validate syntax for edited Fish files:
  - `fish --no-execute config.fish`
  - `fish --no-execute auto-Hypr.fish`
  - `fish --no-execute conf.d/*.fish`
- Optional best-effort lint if installed:
  - `shellcheck -s sh auto-Hypr.fish`
- Note: ShellCheck targets POSIX shell and only partially helps with Fish.

### Test
- No automated tests are configured.
- Treat syntax checks and smoke checks as required verification.

### Single-Test Equivalent (Important)
Use per-file syntax checks as the “single test” workflow.

- Generic:
  - `fish --no-execute path/to/file.fish`
- Examples in this repo:
  - `fish --no-execute config.fish`
  - `fish --no-execute conf.d/fish_frozen_theme.fish`

### Runtime Smoke Checks
- Verify startup does not error:
  - `fish -i -c 'exit'`
- Verify prompt function loads:
  - `fish -c 'functions -q fish_prompt; and echo ok || echo missing'`
- Verify interactive detection behavior:
  - `fish -c 'status is-interactive; and echo interactive || echo non-interactive'`

Agent verification policy:
- Always run `fish --no-execute` for each changed `.fish` file.
- Run at least one smoke check when startup logic changes.
- If checks are skipped, explain why in the final response.

## 4) Code Style Guidelines
This repository is Fish-first. Follow these conventions.

### 4.1 File Organization
- Keep core interactive initialization in `config.fish`.
- Put isolated startup tasks in `conf.d/*.fish` when independent.
- Keep one concern per file where practical.
- Avoid editing generated Fish migration files unless requested.

### 4.2 Imports / Sourcing
- Fish has no import system like JS/Python.
- Use `source` sparingly and with explicit paths.
- Prefer existence checks before sourcing optional files.
- Prefer autoloaded functions / `conf.d` over broad manual sourcing.
- Do not add remote-fetched startup scripts unless explicitly requested.

### 4.3 Formatting
- Use UTF-8 and LF line endings.
- Use 4-space indentation in Fish blocks.
- Target readable lines (about 100 chars soft limit).
- Group related environment/path settings together.
- Avoid broad formatting-only rewrites.

### 4.4 Types
- Fish is dynamically typed; rely on explicit checks.
- Use `test`, `set -q`, and command guards for assumptions.
- For any newly added non-Fish code, prefer strict typing.

### 4.5 Naming
- Functions: descriptive snake_case (e.g., `update_prompt_theme`).
- Variables: lower snake_case.
- Environment variables: UPPER_SNAKE_CASE.
- Alias names: short but understandable.

### 4.6 Control Flow
- Use Fish-native syntax: `if ...; end`, `switch`, `and`, `or`.
- Gate interactive-only logic with `status is-interactive`.
- Use early guards for required binaries or files.
- Keep PATH edits idempotent (`contains` before prepend/append).

### 4.7 Error Handling
- Fail fast for required dependencies.
- Degrade gracefully for optional integrations.
- Provide concise, actionable failure messages.
- Do not silently ignore startup-affecting failures.

### 4.8 Security and Logging
- Avoid startup behavior that silently executes remote code.
- Never log secrets, tokens, or sensitive environment data.
- Keep startup output minimal and intentional.

### 4.9 Comments
- Add comments only for non-obvious logic.
- Keep comments short and maintenance-oriented.
- Remove stale comments when behavior changes.

## 5) Agent Workflow Expectations
- Read relevant files before editing.
- Keep diffs small and intentional.
- Preserve backward compatibility unless user requests breaking changes.
- Never revert unrelated local changes.
- Prefer compatibility-safe adjustments over broad refactors.

After editing:
- Run syntax checks on all modified `.fish` files.
- Run smoke checks if startup behavior changed.

Final response must include:
- Files changed.
- Commands executed.
- Verification status and any skipped checks.

## 6) When the Repo Evolves
If this repo later gains application code or tooling:
- Re-scan for Cursor/Copilot rule files.
- Document real build/lint/test commands from project scripts.
- Add canonical single-test commands for the chosen framework only.
- Update style guidance to match configured linters/formatters.
- Keep this file current, actionable, and concise.
