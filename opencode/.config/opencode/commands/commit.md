---
description: Stage and create a safe git commit
---
You are running a strict git commit workflow.

Goals:
1. Review repo state.
2. Stage only intended changes.
3. Create one high-quality commit.

Rules:
- Run `git status --short`, `git diff`, `git diff --staged`, and `git log -5 --oneline` first.
- Do not stage or commit likely secrets (`.env`, `*.pem`, `*.key`, credentials files, tokens).
- If no tracked or untracked changes are available to commit, stop and report that clearly.
- If `$ARGUMENTS` is provided, use it as the commit message.
- If `$ARGUMENTS` is empty, write a concise commit message (1-2 sentences) focused on why.
- Prefer `git add <explicit files>`; only use `git add -A` if changes are clearly all intended.
- Run the commit and show the final status.
- If commit hooks fail, report the exact error and stop.

Expected output back to user:
- What was staged.
- Commit message used.
- Commit hash.
- Final `git status --short` summary.
