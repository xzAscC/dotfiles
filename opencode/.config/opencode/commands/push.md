---
description: Auto-merge into main/master and push
---
You are running a strict git push workflow.

Policy:
- Final push target must be `main` or `master` only.
- If current branch is not `main`/`master`, switch to one of them, merge current branch, then push.

Steps:
1. Detect current branch with `git rev-parse --abbrev-ref HEAD` and store as `<source-branch>`.
2. Run `git status --short`.
3. If working tree is dirty, stop and report that checkout/merge cannot proceed safely.
4. Choose target branch:
   - Use `main` if it exists.
   - Otherwise use `master` if it exists.
   - If neither exists, stop with a clear error.
5. If `<source-branch>` is not the target branch:
   - Checkout target branch.
   - Pull latest target branch with `git pull --rebase`.
   - Merge `<source-branch>` into target branch with a normal merge (`git merge --no-ff <source-branch>`).
   - If merge conflicts occur, stop and report conflict files plus next steps.
6. If `<source-branch>` is already target branch, run `git pull --rebase`.
7. Check upstream with `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.
8. Push target branch:
   - If upstream exists: `git push`
   - If upstream does not exist: `git push -u origin <target-branch>`
9. If `<source-branch>` is not the target branch, checkout `<source-branch>`.
10. Return: source branch, target branch, merge result, push result, whether switched back to source branch, and final `git status --short`.

Safety rules:
- Never use `--force` unless user explicitly requests it.
- Never delete branches automatically.
