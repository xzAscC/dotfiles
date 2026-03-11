# Plan: Add Qwen 3.5 9B Model Configuration

## TL;DR

> **Quick Summary**: Create a new `oh-my-opencode.qwen.json` config by copying the GLM config template and replacing all `zai-coding-plan/glm-5` references with `lmstudio/qwen/qwen3.5-9b` (local LMStudio model). Also add `ocode-qwen` shell command and update model switcher.
>
> **Deliverables**:
> - New `oh-my-opencode.qwen.json` config file
> - Updated `config.fish` with `ocode-qwen` function
> - Updated `opencode-model.fish` with `qwen` option
>
> **Estimated Effort**: Quick (~10 minutes)
> **Parallel Execution**: YES - 2 waves (Task 1 alone, then Tasks 2+3 parallel)
> **Critical Path**: Task 1 → Tasks 2+3 (parallel)

---

## Context

### Original Request
User wants to add a Qwen 3.5 9B config profile for OpenCode, served via local LMStudio. The config should follow the same pattern as the existing GLM config with model IDs swapped. Fish shell commands should be updated to include the new profile.

### Interview Summary
**Key Discussions**:
- LMStudio is running locally with model `qwen/qwen3.5-9b` (confirmed via `curl http://localhost:1234/v1/models`)
- Three existing configs exist: glm, gpt, opus — none must be modified
- GLM config is the template — replace 13 instances of `zai-coding-plan/glm-5`, keep 5 other model refs as-is
- Fish config has two switch mechanisms: `ocode-*` functions (cp-based) in config.fish and `opencode-model` function (symlink-based) in opencode-model.fish

**Research Findings**:
- OpenCode's `parseModel` splits on first `/`: `lmstudio/qwen/qwen3.5-9b` → provider=`lmstudio`, model=`qwen/qwen3.5-9b` ✅
- `zai-coding-plan` provider works without explicit opencode.json entry — built-in provider resolution handles it
- LMStudio is similarly a built-in provider (user confirms it's configured)

### Metis Review
**Identified Gaps** (addressed):
- LMStudio provider not in opencode.json → resolved: built-in provider, same as `zai-coding-plan`
- `cp` vs `ln -sf` inconsistency in fish → out of scope, follow existing patterns per file
- No `disabled_hooks`/`_migrations` needed → GLM template doesn't have them

---

## Work Objectives

### Core Objective
Add a Qwen 3.5 9B model profile to OpenCode's model switcher system, using LMStudio as the local inference provider.

### Concrete Deliverables
- `/home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json`
- Updated `/home/xzascc/dotfiles/fish/.config/fish/config.fish` (new `ocode-qwen` function)
- Updated `/home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish` (new `qwen` case + help text)

### Definition of Done
- [ ] `jq empty oh-my-opencode.qwen.json` → exit code 0
- [ ] `grep -c 'lmstudio/qwen/qwen3.5-9b' oh-my-opencode.qwen.json` → `13`
- [ ] `grep -c 'zai-coding-plan' oh-my-opencode.qwen.json` → `0`
- [ ] Existing configs unchanged (sha256sum matches before/after)
- [ ] `fish -n config.fish` → exit code 0
- [ ] `fish -n opencode-model.fish` → exit code 0

### Must Have
- Exactly 13 model ID replacements from `zai-coding-plan/glm-5` to `lmstudio/qwen/qwen3.5-9b`
- 5 model references preserved as-is (hephaestus, multimodal-looker, visual-engineering, artistry, writing)
- `ocode-qwen` function using `cp` pattern (matches existing ocode-glm/opus/gpt)
- `opencode-model` function updated with `qwen` case using `ln -sf` pattern

### Must NOT Have (Guardrails)
- NO modifications to `oh-my-opencode.glm.json`, `oh-my-opencode.gpt.json`, or `oh-my-opencode.opus.json`
- NO modifications to `opencode.json`
- NO modifications to `oh-my-opencode.json` (active config)
- NO `disabled_hooks` or `_migrations` fields (not in GLM template)
- NO `variant` fields (9B local model doesn't support thinking levels)
- NO backup files (git is version control)
- NO changes to existing fish functions (`ocode-glm`, `ocode-opus`, `ocode-gpt`)
- NO refactoring of `cp` vs `ln -sf` inconsistency (out of scope)

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (config files only)
- **Automated tests**: None
- **Framework**: N/A
- **Agent-Executed QA**: YES — jq, grep, fish -n, sha256sum, diff

### QA Policy
Every task includes agent-executed QA scenarios using Bash commands.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

- **JSON configs**: Use `jq` for validation and field extraction
- **Fish scripts**: Use `fish -n` for syntax checking
- **File integrity**: Use `sha256sum` for before/after comparison

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — create qwen config):
└── Task 1: Create oh-my-opencode.qwen.json [quick]

Wave 2 (After Wave 1 — fish updates, parallel):
├── Task 2: Add ocode-qwen to config.fish [quick]
└── Task 3: Update opencode-model.fish with qwen option [quick]

Wave FINAL (After ALL tasks — verification):
├── F1: Config integrity check [quick]
└── F2: Fish syntax validation [quick]

Critical Path: Task 1 → Tasks 2+3 (parallel) → F1+F2 (parallel)
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|-----------|--------|------|
| 1 | — | 2, 3, F1 | 1 |
| 2 | 1 | F2 | 2 |
| 3 | 1 | F2 | 2 |
| F1 | 1 | — | FINAL |
| F2 | 2, 3 | — | FINAL |

### Agent Dispatch Summary

- **Wave 1**: 1 task — T1 → `quick`
- **Wave 2**: 2 tasks — T2 → `quick`, T3 → `quick`
- **FINAL**: 2 tasks — F1 → `quick`, F2 → `quick`

---

## TODOs

- [x] 1. Create oh-my-opencode.qwen.json

  **What to do**:
  - Copy the GLM config from `/home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.glm.json`
  - Replace ALL 13 instances of `"zai-coding-plan/glm-5"` with `"lmstudio/qwen/qwen3.5-9b"`
  - Keep these 5 model references UNCHANGED:
    - `agents.hephaestus.model`: `"openai/gpt-5.3-codex"` (line 8)
    - `agents.multimodal-looker.model`: `"google/gemini-3-flash-preview"` (line 21)
    - `categories.visual-engineering.model`: `"google/gemini-3-flash-preview"` (line 38)
    - `categories.artistry.model`: `"google/gemini-3.1-pro-preview"` (line 47)
    - `categories.writing.model`: `"openai/gpt-5.4"` (line 59)
  - Save as `/home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json`

  **Exact replacement map** (13 replacements):

  | Location | Field | Old | New |
  |----------|-------|-----|-----|
  | agents | sisyphus.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | oracle.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | librarian.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | explore.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | prometheus.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | metis.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | momus.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | agents | atlas.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | categories | ultrabrain.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | categories | deep.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | categories | quick.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | categories | unspecified-low.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |
  | categories | unspecified-high.model | `zai-coding-plan/glm-5` | `lmstudio/qwen/qwen3.5-9b` |

  **Must NOT do**:
  - Do NOT modify the GLM config file
  - Do NOT add `variant`, `disabled_hooks`, or `_migrations` fields
  - Do NOT change the `$schema` URL
  - Do NOT change hephaestus variant (`"medium"`)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single file creation via copy-and-replace, minimal complexity
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `git-master`: No git operations in this task

  **Parallelization**:
  - **Can Run In Parallel**: NO (first task, foundation)
  - **Parallel Group**: Wave 1 (solo)
  - **Blocks**: Tasks 2, 3
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `/home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.glm.json` — TEMPLATE: Copy this file and do replacements. Exact 62-line structure to preserve.

  **API/Type References**:
  - LMStudio model ID confirmed via `curl http://localhost:1234/v1/models` → `qwen/qwen3.5-9b`

  **External References**:
  - OpenCode model format: `provider/model-id` where first `/` separates provider from model

  **WHY Each Reference Matters**:
  - GLM config is the exact template — structure, field order, non-GLM models must be byte-identical
  - LMStudio API confirms the exact model ID string to use

  **Acceptance Criteria**:
  - [ ] File exists at `/home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json`
  - [ ] `jq empty oh-my-opencode.qwen.json` → exit code 0 (valid JSON)
  - [ ] `grep -c 'lmstudio/qwen/qwen3.5-9b' oh-my-opencode.qwen.json` → `13`
  - [ ] `grep -c 'zai-coding-plan' oh-my-opencode.qwen.json` → `0` (no GLM remnants)
  - [ ] `grep -c 'gpt-5.3-codex' oh-my-opencode.qwen.json` → `1` (hephaestus preserved)
  - [ ] `grep -c 'gemini-3-flash-preview' oh-my-opencode.qwen.json` → `2` (multimodal-looker + visual-engineering)
  - [ ] `grep -c 'gemini-3.1-pro-preview' oh-my-opencode.qwen.json` → `1` (artistry preserved)
  - [ ] `grep -c 'gpt-5.4' oh-my-opencode.qwen.json` → `1` (writing preserved)

  **QA Scenarios (MANDATORY)**:

  ```
  Scenario: JSON file is valid and has correct model count
    Tool: Bash (jq + grep)
    Preconditions: oh-my-opencode.qwen.json created
    Steps:
      1. Run: jq empty /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
      2. Run: grep -c 'lmstudio/qwen/qwen3.5-9b' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
      3. Run: grep -c 'zai-coding-plan' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
    Expected Result: Step 1 exit code 0, Step 2 outputs `13`, Step 3 outputs `0`
    Failure Indicators: Non-zero exit code, wrong counts
    Evidence: .sisyphus/evidence/task-1-qwen-json-valid.txt

  Scenario: Non-qwen models preserved correctly
    Tool: Bash (grep)
    Preconditions: oh-my-opencode.qwen.json created
    Steps:
      1. Run: grep -c 'gpt-5.3-codex' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
      2. Run: grep -c 'gemini-3-flash-preview' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
      3. Run: grep -c 'gemini-3.1-pro-preview' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
      4. Run: grep -c 'gpt-5.4' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json
    Expected Result: Step 1 → `1`, Step 2 → `2`, Step 3 → `1`, Step 4 → `1`
    Failure Indicators: Wrong counts indicate accidental replacement
    Evidence: .sisyphus/evidence/task-1-preserved-models.txt

  Scenario: GLM config was NOT modified
    Tool: Bash (sha256sum)
    Preconditions: Both files exist
    Steps:
      1. Run: sha256sum /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.glm.json
    Expected Result: Hash matches the pre-task hash (capture before starting)
    Failure Indicators: Hash mismatch
    Evidence: .sisyphus/evidence/task-1-glm-unchanged.txt
  ```

  **Commit**: YES (groups with Tasks 2, 3)
  - Message: `feat(config): add Qwen 3.5 9B model profile and shell commands`
  - Files: `oh-my-opencode.qwen.json`, `config.fish`, `opencode-model.fish`
  - Pre-commit: `jq empty oh-my-opencode.qwen.json`

---

- [x] 2. Add ocode-qwen function to config.fish

  **What to do**:
  - Edit `/home/xzascc/dotfiles/fish/.config/fish/config.fish`
  - Add `ocode-qwen` function after the existing `ocode-gpt` function (after line 57, before `alias ls`)
  - Follow the exact pattern of `ocode-glm`, `ocode-opus`, `ocode-gpt`
  - The function should:
    1. Copy `oh-my-opencode.qwen.json` to `oh-my-opencode.json`
    2. Echo confirmation message
    3. Forward `$argv` to `opencode`

  **Exact code to insert** (after line 57, before `    alias ls`):

  ```fish
    # Switch to Qwen mode (all glm-5 → qwen3.5-9b via LMStudio)
    function ocode-qwen
        cp ~/.config/opencode/oh-my-opencode.qwen.json ~/.config/opencode/oh-my-opencode.json
        echo "✓ Switched to Qwen mode"
        opencode $argv
    end
  ```

  **Must NOT do**:
  - Do NOT modify existing `ocode-glm`, `ocode-opus`, or `ocode-gpt` functions
  - Do NOT change the `cp` pattern to `ln -sf` (follow existing convention)
  - Do NOT add the function outside the `if status is-interactive` block
  - Do NOT reorder existing functions or aliases

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single insertion into existing file, clear pattern to follow
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (parallel with Task 3)
  - **Parallel Group**: Wave 2 (with Task 3)
  - **Blocks**: F2
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `/home/xzascc/dotfiles/fish/.config/fish/config.fish:39-43` — `ocode-glm` function pattern (cp + echo + opencode $argv)
  - `/home/xzascc/dotfiles/fish/.config/fish/config.fish:46-50` — `ocode-opus` function pattern
  - `/home/xzascc/dotfiles/fish/.config/fish/config.fish:53-57` — `ocode-gpt` function pattern (insert AFTER this)

  **WHY Each Reference Matters**:
  - These 3 functions define the exact pattern to replicate — cp source to target, echo confirmation, pass args to opencode

  **Acceptance Criteria**:
  - [ ] `grep -c 'function ocode-qwen' config.fish` → `1`
  - [ ] `grep 'oh-my-opencode.qwen.json' config.fish` → match found
  - [ ] `fish -n /home/xzascc/dotfiles/fish/.config/fish/config.fish` → exit code 0
  - [ ] Existing functions unchanged: `grep -c 'function ocode-glm' config.fish` → `1`, same for opus and gpt

  **QA Scenarios (MANDATORY)**:

  ```
  Scenario: ocode-qwen function exists and config.fish is valid
    Tool: Bash (grep + fish)
    Preconditions: config.fish edited
    Steps:
      1. Run: grep -c 'function ocode-qwen' /home/xzascc/dotfiles/fish/.config/fish/config.fish
      2. Run: grep 'oh-my-opencode.qwen.json' /home/xzascc/dotfiles/fish/.config/fish/config.fish
      3. Run: fish -n /home/xzascc/dotfiles/fish/.config/fish/config.fish
    Expected Result: Step 1 → `1`, Step 2 → matching line, Step 3 → exit code 0
    Failure Indicators: Count != 1, no match, syntax error
    Evidence: .sisyphus/evidence/task-2-fish-config-valid.txt

  Scenario: Existing functions not modified
    Tool: Bash (grep)
    Preconditions: config.fish edited
    Steps:
      1. Run: grep -c 'function ocode-glm' /home/xzascc/dotfiles/fish/.config/fish/config.fish
      2. Run: grep -c 'function ocode-opus' /home/xzascc/dotfiles/fish/.config/fish/config.fish
      3. Run: grep -c 'function ocode-gpt' /home/xzascc/dotfiles/fish/.config/fish/config.fish
    Expected Result: All output `1`
    Failure Indicators: Any output != `1`
    Evidence: .sisyphus/evidence/task-2-existing-functions-intact.txt
  ```

  **Commit**: YES (groups with Tasks 1, 3)
  - Message: `feat(config): add Qwen 3.5 9B model profile and shell commands`
  - Files: `oh-my-opencode.qwen.json`, `config.fish`, `opencode-model.fish`

---

- [x] 3. Update opencode-model.fish with qwen option

  **What to do**:
  - Edit `/home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish`
  - Add `case qwen` to the switch block (after `case opus` at line 31, before `case '*'` at line 32)
  - Add help text line for qwen (after line 21, the opus help line)
  - Update the error message to include qwen in available models list (line 34)

  **Three specific edits**:

  1. **Add help text** — after line 21 (`"  opus - Use Opus configuration"`):
     ```
         echo "  qwen - Use Qwen configuration (LMStudio local)"
     ```

  2. **Add case** — after line 31 (`set source_config $config_dir/oh-my-opencode.opus.json`), before `case '*'`:
     ```fish
         case qwen
             set source_config $config_dir/oh-my-opencode.qwen.json
     ```

  3. **Update error message** — change line 34 from:
     ```
             echo "Available models: glm, gpt, opus"
     ```
     to:
     ```
             echo "Available models: glm, gpt, opus, qwen"
     ```

  **Must NOT do**:
  - Do NOT change existing case handlers (glm, gpt, opus)
  - Do NOT change the symlink mechanism (`ln -sf`)
  - Do NOT reorder existing cases

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Three small insertions/edits in one file, clear pattern
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (parallel with Task 2)
  - **Parallel Group**: Wave 2 (with Task 2)
  - **Blocks**: F2
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `/home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish:26-31` — existing `case glm`, `case gpt`, `case opus` pattern
  - `/home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish:19-21` — help text pattern for available models
  - `/home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish:32-35` — wildcard case with error message

  **WHY Each Reference Matters**:
  - Case block shows exact structure to follow: `case <name>` → `set source_config $config_dir/oh-my-opencode.<name>.json`
  - Help text shows formatting pattern to follow
  - Error message must list all available models

  **Acceptance Criteria**:
  - [ ] `grep -c 'case qwen' opencode-model.fish` → `1`
  - [ ] `grep 'oh-my-opencode.qwen.json' opencode-model.fish` → match found
  - [ ] `grep 'qwen' opencode-model.fish | grep -c 'Available models'` → `1`
  - [ ] `fish -n /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish` → exit code 0
  - [ ] Existing cases unchanged: `grep -c 'case glm' opencode-model.fish` → `1`

  **QA Scenarios (MANDATORY)**:

  ```
  Scenario: qwen case added and function is valid
    Tool: Bash (grep + fish)
    Preconditions: opencode-model.fish edited
    Steps:
      1. Run: grep -c 'case qwen' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
      2. Run: grep 'oh-my-opencode.qwen.json' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
      3. Run: fish -n /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
    Expected Result: Step 1 → `1`, Step 2 → matching line, Step 3 → exit code 0
    Failure Indicators: Count != 1, no match, syntax error
    Evidence: .sisyphus/evidence/task-3-model-fish-valid.txt

  Scenario: Help text includes qwen and error message updated
    Tool: Bash (grep)
    Preconditions: opencode-model.fish edited
    Steps:
      1. Run: grep 'qwen - Use Qwen' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
      2. Run: grep 'Available models.*qwen' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
    Expected Result: Both commands produce matching output
    Failure Indicators: No match for either
    Evidence: .sisyphus/evidence/task-3-help-text.txt

  Scenario: Existing cases not modified
    Tool: Bash (grep)
    Preconditions: opencode-model.fish edited
    Steps:
      1. Run: grep -c 'case glm' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
      2. Run: grep -c 'case gpt' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
      3. Run: grep -c 'case opus' /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish
    Expected Result: All output `1`
    Failure Indicators: Any output != `1`
    Evidence: .sisyphus/evidence/task-3-existing-cases-intact.txt
  ```

  **Commit**: YES (groups with Tasks 1, 2)
  - Message: `feat(config): add Qwen 3.5 9B model profile and shell commands`
  - Files: `oh-my-opencode.qwen.json`, `config.fish`, `opencode-model.fish`

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 2 review agents run in PARALLEL. ALL must APPROVE. Rejection → fix → re-run.

- [x] F1. **Config Integrity Check** — `quick`
  Verify `oh-my-opencode.qwen.json` has valid JSON, correct model counts (13 qwen, 0 glm, 5 preserved), and correct `$schema`. Verify ALL existing configs are byte-identical to their pre-task state using sha256sum: `oh-my-opencode.glm.json`, `oh-my-opencode.gpt.json`, `oh-my-opencode.opus.json`, `opencode.json`. Verify LMStudio connectivity: `curl -s http://localhost:1234/v1/models | jq '.data[] | select(.id == "qwen/qwen3.5-9b") | .id'` → `"qwen/qwen3.5-9b"`.
  Output: `JSON [VALID/INVALID] | Qwen refs [13/N] | GLM refs [0/N] | Preserved [5/N] | Existing configs [INTACT/MODIFIED] | LMStudio [UP/DOWN] | VERDICT: APPROVE/REJECT`

- [x] F2. **Shell Script Validation** — `quick`
  Run `fish -n` on both modified fish files. Verify `ocode-qwen` function exists in config.fish. Verify `case qwen` exists in opencode-model.fish. Verify help text and error message include `qwen`. Verify existing functions/cases are unchanged (grep counts for glm, gpt, opus = 1 each).
  Output: `config.fish syntax [PASS/FAIL] | opencode-model.fish syntax [PASS/FAIL] | ocode-qwen [EXISTS/MISSING] | case qwen [EXISTS/MISSING] | Existing functions [INTACT/MODIFIED] | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **1**: `feat(config): add Qwen 3.5 9B model profile and shell commands` — oh-my-opencode.qwen.json, config.fish, opencode-model.fish, `jq empty oh-my-opencode.qwen.json && fish -n config.fish && fish -n opencode-model.fish`

---

## Success Criteria

### Verification Commands
```bash
# Verify qwen config is valid JSON
jq empty /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json  # Expected: exit 0

# Verify correct model count
grep -c 'lmstudio/qwen/qwen3.5-9b' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json  # Expected: 13

# Verify no GLM remnants
grep -c 'zai-coding-plan' /home/xzascc/dotfiles/opencode/.config/opencode/oh-my-opencode.qwen.json  # Expected: 0

# Verify fish syntax
fish -n /home/xzascc/dotfiles/fish/.config/fish/config.fish  # Expected: exit 0
fish -n /home/xzascc/dotfiles/fish/.config/fish/functions/opencode-model.fish  # Expected: exit 0

# Verify LMStudio is reachable
curl -s http://localhost:1234/v1/models | jq '.data[].id'  # Expected: "qwen/qwen3.5-9b"
```

### Final Checklist
- [ ] `oh-my-opencode.qwen.json` created with 13 qwen model refs
- [ ] No GLM model references remain in qwen config
- [ ] 5 non-GLM model references preserved unchanged
- [ ] `ocode-qwen` function added to config.fish
- [ ] `case qwen` added to opencode-model.fish
- [ ] Help text and error message updated
- [ ] All existing configs untouched (glm, gpt, opus, opencode.json)
- [ ] All fish scripts pass syntax check
