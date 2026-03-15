# 创建 GPT 版本配置文件 + Fish 切换命令

## TL;DR

> **Quick Summary**: 创建 oh-my-opencode.gpt.json 配置文件（主 agent 使用 GPT-5.4 high），禁用 GPT 限制钩子，并创建 fish 命令切换配置
>
> **Deliverables**:
> - `~/.config/opencode/oh-my-opencode.gpt.json` - GPT 版本的配置文件
> - `~/.config/fish/functions/opencode-model.fish` - 切换配置的 fish 命令
>
> **Estimated Effort**: Quick
> **Parallel Execution**: YES - 2 个独立任务
> **Critical Path**: 创建配置文件 → 创建切换命令

---

## Context

### Original Request
用户希望创建一个 GPT 版本的 oh-my-opencode 配置文件，将主要 agent（GLM 配置中使用 GLM-5 的）改为 GPT-5.4 high。同时创建 fish 命令来切换配置。

### Interview Summary
**Key Discussions**:
- 模型选择：主要 agent 使用 `gpt-5.4` + `variant: high`
- 钩子限制：需要禁用 `no-sisyphus-gpt` 和 `no-hephaestus-non-gpt` 钩子
- Hephaestus 特殊处理：继续使用 GPT-5.3-codex，并设置 `allow_non_gpt_model: true`
- Fish 命令：创建 `opencode-model` 命令支持 glm/gpt/opus 切换

**Research Findings**:
- 现有配置结构：GLM 版本使用 `zai-coding-plan/glm-5`，Opus 版本使用 `anthropic/claude-opus-4-6`
- GLM 配置中 GLM-5 的 agent：sisyphus, librarian, explore, prometheus, metis, atlas
- 钩子定义：从 oh-my-opencode 的 hooks schema 中找到了限制 GPT 的钩子
- Fish functions 目录：`~/.config/fish/functions/` 已存在

### Metis Review
**Identified Gaps** (addressed):
- 无（需求明确）

---

## Work Objectives

### Core Objective
创建 GPT 版本的 oh-my-opencode 配置文件，将 GLM 配置中使用 GLM-5 的 agent 改为 GPT-5.4 high，并创建 fish 命令方便切换。

### Concrete Deliverables
- `~/.config/opencode/oh-my-opencode.gpt.json` - GPT 版本的配置文件
- `~/.config/fish/functions/opencode-model.fish` - 切换配置的 fish 命令

### Definition of Done
- [ ] GPT 配置文件创建成功
- [ ] 所有 agent 配置使用正确的 GPT 模型
- [ ] 禁用的钩子已正确配置
- [ ] Fish 命令可正常切换配置
- [ ] JSON 格式正确

### Must Have
- `disabled_hooks` 包含 `no-sisyphus-gpt` 和 `no-hephaestus-non-gpt`
- Hephaestus 使用 `gpt-5.3-codex` 并设置 `allow_non_gpt_model: true`
- 主要 agent（sisyphus, prometheus, metis, librarian, explore, atlas）使用 `gpt-5.4` + `variant: high`
- Fish 命令支持 `glm`, `gpt`, `opus` 三种配置切换
- Fish 命令无参数时显示当前配置

### Must NOT Have (Guardrails)
- 不要修改现有的 GLM 或 Opus 配置文件
- 不要遗漏任何 agent 配置
- 不要破坏现有的 fish functions 目录结构

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None
- **Framework**: none

### QA Policy
- 验证 JSON 格式正确
- 验证所有必需字段存在
- 验证禁用的钩子配置正确
- 验证 fish 命令语法正确
- 验证切换功能正常

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — 并行执行):
├── Task 1: 创建 GPT 配置文件 [quick]
└── Task 2: 创建 fish 切换命令 [quick]
```

### Dependency Matrix

- **1**: — — None
- **2**: — — None

### Agent Dispatch Summary

- **1**: **1** — T1 → `quick`
- **2**: **1** — T2 → `quick`

---

## TODOs

- [ ] 1. 创建 oh-my-opencode.gpt.json 配置文件

  **What to do**:
  - 创建 `~/.config/opencode/oh-my-opencode.gpt.json` 文件
  - 配置 `disabled_hooks` 禁用 GPT 限制钩子
  - 主要 agent 使用 `openai/gpt-5.4` + `variant: high`
  - Hephaestus 使用 GPT-5.3-codex 并设置 `allow_non_gpt_model: true`

  **配置详情**:

  | Agent | Model | Variant |
  |-------|-------|---------|
  | sisyphus | openai/gpt-5.4 | high |
  | prometheus | openai/gpt-5.4 | high |
  | metis | openai/gpt-5.4 | high |
  | oracle | openai/gpt-5.4 | high |
  | momus | openai/gpt-5.4 | xhigh |
  | librarian | openai/gpt-5.4 | high |
  | explore | openai/gpt-5.4 | high |
  | atlas | openai/gpt-5.4 | high |
  | hephaestus | openai/gpt-5.3-codex | medium + allow_non_gpt_model: true |
  | multimodal-looker | openai/gpt-5.4 | medium |

  | Category | Model | Variant |
  |----------|-------|---------|
  | visual-engineering | openai/gpt-5.4 | high |
  | ultrabrain | openai/gpt-5.3-codex | xhigh |
  | deep | openai/gpt-5.3-codex | medium |
  | artistry | openai/gpt-5.4 | high |
  | quick | openai/gpt-5.4 | high |
  | unspecified-low | openai/gpt-5.4 | high |
  | unspecified-high | openai/gpt-5.4 | high |
  | writing | openai/gpt-5.4 | medium |

  **Must NOT do**:
  - 修改现有配置文件
  - 遗漏任何 agent 配置

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 简单的文件创建任务
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References** (existing code to follow):
  - `~/.config/opencode/oh-my-opencode.glm.json` - GLM 版本配置格式参考
  - `~/.config/opencode/oh-my-opencode.opus.json` - Opus 版本配置格式参考

  **WHY Each Reference Matters**:
  - GLM 和 Opus 配置文件展示了正确的 JSON 结构和字段命名

  **Acceptance Criteria**:
  - [ ] 文件存在于 `~/.config/opencode/oh-my-opencode.gpt.json`
  - [ ] JSON 格式正确（可通过 `jq . file` 验证）
  - [ ] `disabled_hooks` 包含 `no-sisyphus-gpt` 和 `no-hephaestus-non-gpt`
  - [ ] 所有 agent 配置存在且使用 GPT 模型

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: [验证 JSON 格式]
    Tool: Bash
    Preconditions: 配置文件已创建
    Steps:
      1. jq . ~/.config/opencode/oh-my-opencode.gpt.json
    Expected Result: 命令成功执行，无语法错误
    Failure Indicators: jq 报告 JSON 语法错误
    Evidence: .sisyphus/evidence/task-1-json-valid.txt

  Scenario: [验证禁用的钩子]
    Tool: Bash
    Preconditions: 配置文件已创建
    Steps:
      1. jq '.disabled_hooks' ~/.config/opencode/oh-my-opencode.gpt.json
    Expected Result: 输出包含 "no-sisyphus-gpt" 和 "no-hephaestus-non-gpt"
    Failure Indicators: 缺少必需的钩子配置
    Evidence: .sisyphus/evidence/task-1-disabled-hooks.txt

  Scenario: [验证 Hephaestus 配置]
    Tool: Bash
    Preconditions: 配置文件已创建
    Steps:
      1. jq '.agents.hephaestus' ~/.config/opencode/oh-my-opencode.gpt.json
    Expected Result: model 为 "openai/gpt-5.3-codex"，allow_non_gpt_model 为 true
    Failure Indicators: 配置不正确
    Evidence: .sisyphus/evidence/task-1-hephaestus-config.txt

  Scenario: [验证主要 agent 使用 gpt-5.4 high]
    Tool: Bash
    Preconditions: 配置文件已创建
    Steps:
      1. jq '.agents | to_entries[] | select(.key == "sisyphus" or .key == "prometheus" or .key == "metis" or .key == "oracle") | .value.model' ~/.config/opencode/oh-my-opencode.gpt.json
    Expected Result: 所有输出为 "openai/gpt-5.4"
    Failure Indicators: 有 agent 使用了其他模型
    Evidence: .sisyphus/evidence/task-1-main-agents.txt
  ```

  **Commit**: YES
  - Message: `feat(config): add GPT version oh-my-opencode configuration`
  - Files: `~/.config/opencode/oh-my-opencode.gpt.json`

- [ ] 2. 创建 fish 切换命令

  **What to do**:
  - 创建 `~/.config/fish/functions/opencode-model.fish` 文件
  - 支持切换 glm/gpt/opus 配置
  - 无参数时显示当前配置
  - 提供帮助信息

  **命令功能**:
  - `opencode-model glm` - 切换到 GLM 配置
  - `opencode-model gpt` - 切换到 GPT 配置
  - `opencode-model opus` - 切换到 Opus 配置
  - `opencode-model` - 显示当前配置和使用帮助

  **Must NOT do**:
  - 删除现有 fish functions
  - 使用不兼容的 fish 语法

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 简单的文件创建任务
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References** (existing code to follow):
  - Fish shell 文档：https://fishshell.com/docs/current/cmds/function.html

  **WHY Each Reference Matters**:
  - 确保 fish 函数语法正确

  **Acceptance Criteria**:
  - [ ] 文件存在于 `~/.config/fish/functions/opencode-model.fish`
  - [ ] Fish 语法正确（可通过 `fish -n file` 验证）
  - [ ] 命令支持 glm/gpt/opus 参数
  - [ ] 无参数时显示当前配置

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: [验证 fish 语法]
    Tool: Bash
    Preconditions: fish 文件已创建
    Steps:
      1. fish -n ~/.config/fish/functions/opencode-model.fish
    Expected Result: 无语法错误输出
    Failure Indicators: fish 报告语法错误
    Evidence: .sisyphus/evidence/task-2-fish-syntax.txt

  Scenario: [验证命令帮助]
    Tool: Bash
    Preconditions: fish 文件已创建
    Steps:
      1. fish -c 'source ~/.config/fish/functions/opencode-model.fish; opencode-model'
    Expected Result: 显示使用帮助或当前配置
    Failure Indicators: 命令执行失败
    Evidence: .sisyphus/evidence/task-2-help-output.txt

  Scenario: [验证切换功能]
    Tool: Bash
    Preconditions: fish 文件已创建，GPT 配置文件已创建
    Steps:
      1. fish -c 'source ~/.config/fish/functions/opencode-model.fish; opencode-model gpt'
      2. cat ~/.config/opencode/oh-my-opencode.json | head -3
    Expected Result: 配置文件内容与 gpt.json 相同
    Failure Indicators: 切换失败或配置不正确
    Evidence: .sisyphus/evidence/task-2-switch-gpt.txt
  ```

  **Commit**: YES
  - Message: `feat(fish): add opencode-model command for config switching`
  - Files: `~/.config/fish/functions/opencode-model.fish`

---

## Final Verification Wave (MANDATORY)

- [ ] F1. **Plan Compliance Audit** — `quick`
  验证 GPT 配置文件存在，JSON 格式正确，所有必需字段存在。验证 fish 命令存在且语法正确。
  Output: `GPT Config [YES] | Fish Command [YES] | Format [PASS/FAIL] | Hooks [2/2] | Agents [10/10] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Function Test** — `quick`
  测试 fish 命令切换功能：切换到 GPT 配置，验证 oh-my-opencode.json 内容正确；切换回 GLM，验证恢复正确。
  Output: `Switch to GPT [PASS/FAIL] | Switch to GLM [PASS/FAIL] | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **1**: `feat(config): add GPT version oh-my-opencode configuration` — oh-my-opencode.gpt.json
- **2**: `feat(fish): add opencode-model command for config switching` — opencode-model.fish

---

## Success Criteria

### Verification Commands
```bash
# 验证 GPT 配置 JSON 格式
jq . ~/.config/opencode/oh-my-opencode.gpt.json

# 验证禁用的钩子
jq '.disabled_hooks' ~/.config/opencode/oh-my-opencode.gpt.json

# 验证 Hephaestus 配置
jq '.agents.hephaestus' ~/.config/opencode/oh-my-opencode.gpt.json

# 验证主要 agent 使用 gpt-5.4
jq '.agents.sisyphus, .agents.prometheus, .agents.metis' ~/.config/opencode/oh-my-opencode.gpt.json

# 验证 fish 命令语法
fish -n ~/.config/fish/functions/opencode-model.fish

# 测试 fish 命令切换
opencode-model gpt && cat ~/.config/opencode/oh-my-opencode.json | jq '.agents.sisyphus.model'
opencode-model glm && cat ~/.config/opencode/oh-my-opencode.json | jq '.agents.sisyphus.model'
```

### Final Checklist
- [ ] GPT 配置文件创建成功
- [ ] JSON 格式正确
- [ ] 禁用的钩子配置正确
- [ ] 所有 agent 配置正确
- [ ] Hephaestus 使用 GPT-5.3-codex 并允许非 GPT 模型
- [ ] Fish 命令语法正确
- [ ] Fish 命令可正常切换配置
