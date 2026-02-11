---
description: Detect, refactor, and verify cleanup changes
---
Clean and refactor `$ARGUMENTS` (default `.`) in 3 automatic phases: Detect -> Refactor -> Verify.

Rules:
- Prefer reusing existing code over creating new helpers.
- Delete replaced or unreferenced code; do not keep dead wrappers.
- Keep diffs small and focused; avoid unrelated formatting churn.
- If a change might alter runtime behavior, stop and ask one targeted question.

Detect:
- Find dead code, duplicated logic, and obvious over-engineering.
- Make a short change plan with file paths.

Refactor:
- Apply the plan safely and incrementally.

Verify:
- Run available tests, typecheck, and lint.
- If unavailable, state what was skipped and why.

Return:
- Target path, findings, files changed, deleted/reused code, and verification results.
