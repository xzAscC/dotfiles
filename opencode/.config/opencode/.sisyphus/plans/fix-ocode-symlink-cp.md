# Fix ocode-* "same file" error

## TL;DR

> **Quick Summary**: Add `rm -f` before each `cp` in the four `ocode-*` fish functions to prevent "are the same file" error when target is a symlink.
> 
> **Deliverables**: Fixed `config.fish` — all four ocode-* commands work regardless of whether `oh-my-opencode.json` is a symlink or regular file.
> 
> **Estimated Effort**: Quick (4 lines added)
> **Parallel Execution**: NO — single file edit
> **Critical Path**: Edit config.fish → reload fish → verify

---

## Context

### Root Cause
`opencode-model.fish` uses `ln -sf` (symlinks) to switch configs. The `ocode-*` functions in `config.fish` use `cp`. When `oh-my-opencode.json` is a symlink pointing to (e.g.) `oh-my-opencode.opus.json`, running `ocode-opus` tries to copy the file onto itself through the symlink, causing:

```
cp: '...opus.json' and '...oh-my-opencode.json' are the same file
```

Whichever model the symlink currently points to will always trigger this error for the corresponding `ocode-*` command.

### Fix
Add `rm -f ~/.config/opencode/oh-my-opencode.json` before each `cp`. This removes the symlink (or regular file) first, so `cp` always gets a clean target. Works for both symlink and regular file cases.

---

## Work Objectives

### Core Objective
Eliminate the "are the same file" cp error in all four ocode-* functions.

### Must Have
- All four functions (ocode-glm, ocode-opus, ocode-gpt, ocode-qwen) must work regardless of whether oh-my-opencode.json is currently a symlink or a regular file

### Must NOT Have
- Do NOT change the opencode-model.fish function
- Do NOT change the cp approach to symlinks

---

## TODOs

- [x] 1. Add `rm -f` before each `cp` in config.fish

  **What to do**:
  In `/home/xzascc/dotfiles/fish/.config/fish/config.fish`, add one line before EACH of the four `cp` commands inside the `ocode-*` functions:
  
  ```fish
  rm -f ~/.config/opencode/oh-my-opencode.json
  ```
  
  The four functions to modify (lines 39-64):
  - `ocode-glm` (line 40): add `rm -f` before the `cp`
  - `ocode-opus` (line 47): add `rm -f` before the `cp`
  - `ocode-gpt` (line 54): add `rm -f` before the `cp`
  - `ocode-qwen` (line 61): add `rm -f` before the `cp`

  Each function should look like:
  ```fish
  function ocode-opus
      rm -f ~/.config/opencode/oh-my-opencode.json
      cp ~/.config/opencode/oh-my-opencode.opus.json ~/.config/opencode/oh-my-opencode.json
      echo "✓ Switched to Opus mode"
      opencode $argv
  end
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **References**:
  - `fish/.config/fish/config.fish:39-64` — The four ocode-* functions to modify

  **QA Scenarios:**

  ```
  Scenario: Switching when target is a symlink (the bug case)
    Tool: Bash
    Steps:
      1. ln -sf ~/.config/opencode/oh-my-opencode.opus.json ~/.config/opencode/oh-my-opencode.json
      2. source ~/.config/fish/config.fish
      3. Run: ocode-opus (without args to avoid launching opencode)
    Expected: No "are the same file" error, prints "Switched to Opus mode"

  Scenario: All four commands work in sequence
    Tool: Bash
    Steps:
      1. ocode-glm, ocode-opus, ocode-gpt, ocode-qwen in sequence (no args)
    Expected: All four succeed with no cp errors
  ```

  **Commit**: YES
  - Message: `fix(fish): resolve cp "same file" error in ocode-* model switchers`
  - Files: `fish/.config/fish/config.fish`

---

## Success Criteria

- [x] All four ocode-* commands work when oh-my-opencode.json is a symlink
- [x] All four ocode-* commands work when oh-my-opencode.json is a regular file
- [x] Switching between any two modes in any order produces no errors
