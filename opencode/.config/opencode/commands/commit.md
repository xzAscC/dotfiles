---
description: Stage and create a safe git commit
---
Run a strict commit workflow with auto-commit squashing.

Goals:
1. Review repo state.
2. Stage only intended changes.
3. Squash consecutive auto-commits at `HEAD` into one quality commit when present.
4. Otherwise, create one quality commit from current changes.

Rules:
- First run: `git status --short`, `git diff`, `git diff --staged`, `git log -5 --oneline`.
- Auto-commits are subjects starting with `chore(opencode): auto-commit after assistant edits`.
- If `HEAD` has consecutive auto-commits, find the base commit before the earliest one, inspect `git diff <base>..HEAD` (and subjects), then squash (for example `git reset --soft <base>` + new commit).
- During squash and normal flow, exclude disallowed files from index only (for example `git restore --staged -- <file>`) so local files remain.
- Disallowed files: secrets/sensitive env (`.env`, `.env.*`, `*.pem`, `*.key`, credentials/token files) and large model/checkpoint artifacts (`*.ckpt`, `*.pt`, `*.pth`, `*.safetensors`, `*.onnx`, very large binaries).
- If disallowed files are local/generated artifacts, keep them untracked and add precise `.gitignore` patterns; never add broad risky rules or use `.gitignore` to hide already tracked files.
- If no tracked/untracked changes exist, stop and report clearly.
- Commit message: use `$ARGUMENTS` when provided; otherwise write 1-2 concise sentences focused on why.
- Prefer `git add <explicit files>`; use `git add -A` only when clearly intended.
- Run commit and show final status; if hooks fail, report exact error and stop.

Return to user:
- Whether auto-commits were detected/squashed and the squash range/base (if any).
- What was staged.
- Any `.gitignore` entries added (and why).
- Commit message, commit hash, and final `git status --short`.
