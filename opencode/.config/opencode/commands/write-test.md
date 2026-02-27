---
description: Write matching Python test files with pytest
---
You are running a strict Python test-authoring workflow for `$ARGUMENTS`.

Goal:
Create or update the corresponding `pytest` test file for the target Python module/function with minimal, runnable coverage.

Environment rules:
- Python commands must use `uv run`.
- Do not call `python`, `pytest`, `ruff`, or `mypy` directly.

Input handling:
- If `$ARGUMENTS` contains a file path under `src/`, treat it as the target module.
- If `$ARGUMENTS` contains a symbol name, locate its defining file first.
- If `$ARGUMENTS` is empty, use changed Python files from git status and pick the most relevant one in `src/`.

Test file mapping:
- Map `src/.../foo.py` -> `tests/.../test_foo.py`.
- Keep package-relative structure under `tests/`.
- Create missing test directories/files as needed.

Authoring rules:
- Use `pytest` style tests.
- Cover at least: one happy path, one edge case, one failure path (if behavior supports it).
- Avoid network and filesystem side effects in unit tests; mock external boundaries.
- Keep tests deterministic and small.
- Do not edit production code unless strictly required to enable testability; if required, keep diffs minimal.

Validation:
- Run the smallest relevant test command first: `uv run pytest <new-or-updated-test-file>`.
- If available and inexpensive, also run: `uv run ruff check <new-or-updated-test-file>`.
- Report failures with actionable reasons.

Return to user:
- Target analyzed.
- Test file path created/updated.
- Scenarios covered.
- Exact commands run and outcomes.
- Any skipped checks and why.
