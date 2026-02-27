# Python Research Agent Baseline

Use this file as a reusable baseline when creating `AGENT.md` for Python research projects.

## 1) Scope
- This agent supports Python research workflows: data processing, modeling, training, evaluation, and experiment documentation.
- In scope: code changes, experiment scripts, tests for core logic, docs updates.
- Out of scope unless requested: production deployment, infra provisioning, destructive data operations.

## 2) Environment
- OS: Linux only.
- Python: 3.11+.
- Env manager: conda or uv (`.venv` is acceptable).
- GPU stack: CUDA may be present; do not assume multi-GPU unless configured.

## 3) Project Layout Conventions
- `src/`: core source code.
- `configs/`: experiment configs (yaml/json).
- `scripts/`: reproducible run scripts.
- `tests/`: unit/integration tests for core logic.
- `experiments/`: run artifacts (metrics, logs, checkpoints, plots).
- `data/raw/`: read-only raw data.
- `data/processed/`: generated data artifacts.

## 4) Reproducibility Rules
- Always set and log random seeds (Python/NumPy/PyTorch if used).
- Record exact command, config, git commit hash, and timestamp for each run.
- Prefer config-driven runs; avoid hardcoded paths and hyperparameters.
- Keep deterministic settings enabled for evaluation where feasible.

## 5) Code Style
- Use type hints in public APIs and non-trivial internals.
- Keep functions small and composable.
- Import order: stdlib -> third-party -> local.
- Naming: snake_case (vars/functions), PascalCase (classes), UPPER_SNAKE_CASE (constants).
- Error handling: fail fast with actionable messages; avoid silent exception swallowing.
- Logging: structured logs; never print secrets or private data samples.

## 6) Data and Artifact Safety
- Never modify `data/raw/` in-place.
- Never commit large artifacts/checkpoints unless explicitly requested.
- Respect `.gitignore` for `experiments/`, `outputs/`, and cache directories.
- Never commit secrets (`.env`, tokens, credentials, private keys).

## 7) Experiment Workflow
- Run a quick sanity experiment (small subset/short epochs) before full training.
- Start full runs only after sanity checks pass.
- Save config snapshot, metrics, checkpoint path, and environment info for each run.
- Report metric deltas versus prior baseline when available.

## 8) Validation and Testing
- For logic changes: run relevant unit tests first.
- For modeling changes: run one sanity experiment plus one evaluation command.
- If skipping tests or experiments, state why and expected risk.
- Avoid network calls in unit tests; mock external boundaries.

## 9) Git Rules
- Use focused branches: `exp/<topic>`, `feat/<topic>`, `fix/<topic>`.
- Commit messages should explain research intent (why), not only file changes.
- Do not amend or force-push unless explicitly requested.
- Do not revert unrelated local changes made by the user.

## 10) Agent Behavior
- Read existing files and configs before editing.
- Make minimal diffs and preserve existing experiment structure.
- Prefer updating configs/scripts over hardcoding values.
- If blocked, ask exactly one targeted question with a recommended default.
- Final report should include files changed, commands run, key metric changes, and skipped checks.
