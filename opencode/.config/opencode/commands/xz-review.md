---
description: xz-review GitHub PR bot — confidence score, P1/P2/P3 inline findings, suggested fixes
---

# xz-review — GitHub PR review bot

Run an **xz-review** pull-request review and **post it to GitHub** (as a **bot identity**, not the PR author) so reviewers get:

1. A **summary** with issue count + **confidence score (N/5)**
2. **Inline review comments** on the exact lines, labeled **P1 / P2 / P3**
3. Optional **suggested changes** (` ```suggestion ` blocks) so GitHub shows “Apply suggestion”
4. Native GitHub **Resolve conversation** on each thread (automatic for PR review comments — do not invent a custom button)

Target from `$ARGUMENTS` (any of):

- Full PR URL: `https://github.com/OWNER/REPO/pull/N`
- `OWNER/REPO#N` or `OWNER/REPO N`
- Bare PR number `N` (use the current git remote)
- Empty → resolve PR for the current branch via `gh pr view`
- Optional flags anywhere in args:
  - `--dry-run` — analyze and print the planned review JSON; **do not post**
  - `--event COMMENT` (default) | `REQUEST_CHANGES` | `APPROVE`
  - `--max N` — cap inline comments (default `25`; still list overflow in the summary)
  - `--base BRANCH` — only if `gh` cannot infer the base
  - `--as-bot` — **required for posting** unless `XZ_REVIEW_GITHUB_TOKEN` / `GH_BOT_TOKEN` is already exported (see Auth below)

If the target cannot be resolved, ask **one** short clarifying question.

---

## Why a bot (not your personal account)

GitHub blocks or degrades **self-reviews**:

- PR **authors cannot Approve** their own PR
- Branch protection often requires a review from **someone other than the author**
- Reviews posted as the author look like self-comments, not an independent bot (cubic shows `cubic-dev-ai[bot]`)

So **all posts must use a non-author identity**: machine user PAT or GitHub App installation token.

### Auth (mandatory for post)

1. Prefer env var (never print the token, never commit it):
   - `XZ_REVIEW_GITHUB_TOKEN` (preferred), or
   - `GH_BOT_TOKEN`, or
   - `GITHUB_TOKEN` **only** inside GitHub Actions with a bot/App token (not the PR author’s PAT)
2. Every `gh` / `gh api` call that **writes** the review must use:

```bash
export GH_TOKEN="${XZ_REVIEW_GITHUB_TOKEN:-${GH_BOT_TOKEN:-}}"
# fail closed if empty when not --dry-run
```

3. Before posting, verify the actor is **not** the PR author:

```bash
BOT_LOGIN=$(GH_TOKEN="$GH_TOKEN" gh api user --jq .login)
PR_AUTHOR=$(gh pr view <N|URL> --json author --jq .author.login)
# If BOT_LOGIN == PR_AUTHOR → STOP and tell the user to configure a bot token
```

4. Read-only fetch may use the user’s normal `gh` auth; **submit review only with bot token**.
5. If token missing and not `--dry-run`: explain how to set the bot up (machine user or GitHub App) and offer `--dry-run` only. Do not fall back to the user’s personal token for `POST .../reviews`.

---

## Hard rules

- **Do not** modify local source files to “fix” the PR unless the user separately asks. This command is review-only.
- **Do** use `gh api` for the multi-comment review payload, authenticated as the **bot**.
- **Do not** spam: one review submission per run (summary body + all inline comments in a single `POST .../pulls/{n}/reviews`).
- **Do not** invent bugs. Every finding must cite concrete code from the PR diff (or clearly adjacent context you read).
- Prefer **actionable** defects over style nits. Skip pure formatting/taste unless it causes real risk.
- Severity must be honest:
  - **P1** — correctness / security / data-loss / wrong experiment attribution / broken core path; should block merge
  - **P2** — real bug, fragility, silent wrongness, reproducibility gap, misleading metrics; should fix before merge when cheap
  - **P3** — missing tests, docs/deps hygiene, maintainability; nice-to-have before merge
- Confidence score **1–5** = merge readiness of *this* PR (not model self-confidence):
  - **5** — clean or only trivial P3s
  - **4** — minor P2s, easy fixes
  - **3** — several P2s or one contained P1 with clear fix
  - **2** — multiple P1/P2s that undermine trust in results or runtime
  - **1** — severe breakage, security, or invalidates main claims
- Inline comments need valid **RIGHT** (or **LEFT** for deletions-only) line anchors on the **PR head commit**. If a line cannot be anchored safely, put it in the summary only.
- Suggested patches must apply cleanly to the commented line range. If unsure, omit the suggestion and describe the fix in prose.

---

## Workflow

### 1) Resolve PR identity

```bash
# Parse $ARGUMENTS; examples:
gh pr view <N|URL> --json number,url,title,baseRefName,headRefName,headRefOid,files,additions,deletions,author,body,commits
gh pr diff <N|URL>
gh api repos/{owner}/{repo}/pulls/{n}/files --paginate
```

Record: `owner`, `repo`, `pull_number`, `head_sha` (`headRefOid`), title, file list, `author.login`.

### 2) Gather review context

- Full unified diff (`gh pr diff`)
- Changed file patches (`pulls/.../files`) for accurate paths + patches
- PR description and linked issues if present
- Skim surrounding source for changed symbols when the hunk alone is ambiguous (read local files or `gh api` contents at `head_sha`)
- Ignore generated lockfile noise unless the change itself is harmful (e.g. accidental secrets, huge unrelated churn)

### 3) Analyze (xz-review / cubic-style)

Hunt for, in priority order:

1. Logic bugs, off-by-one, wrong branch, inverted conditions
2. API/contract mismatches, broken CLI, shell quoting, path injection
3. Incorrect metrics/plots/labels that flip scientific conclusions
4. Security (injection, secret leak, unsafe deserialization, authz)
5. Concurrency/races, resource leaks
6. Silent data drop, non-determinism vs claimed seeds
7. Missing validation / fail-open behavior
8. Test gaps on new critical paths (usually P3 unless the path is dangerous)
9. Dependency bloat or footguns introduced by the PR

For each real issue produce:

| Field | Meaning |
|--------|---------|
| `severity` | `P1` \| `P2` \| `P3` |
| `path` | repo-relative path |
| `start_line` / `line` | inclusive range on the **new** file (RIGHT), or LEFT for pure deletions |
| `side` | `RIGHT` default |
| `title_line` | one sentence starting with `P1:` / `P2:` / `P3:` |
| `body` | why it matters + concrete fix direction |
| `suggestion` | optional full replacement text for the line range |
| `agent_prompt` | short fix brief for coding agents |

Deduplicate. Merge related nits. Cap at `--max` strongest findings for inline threads; remainder stays summary-only.

### 4) Build GitHub markdown

#### Summary review body

```markdown
<!-- xz-review:summary:start -->
<!-- xz-review:confidence-score:S/5 -->
**K issues found** across F files

Confidence score: **S/5**

- In `path/to/file.py`, <problem>—<fix direction>.
- `path/other.py` <problem>—<fix direction>.
- …
<!-- xz-review:summary:end -->

<details>
<summary>Prompt for AI agents (unresolved issues)</summary>

```text
Check if these issues are valid — if so, understand the root cause of each and fix them. If appropriate, use sub-agents to investigate and fix each issue separately.

<file name="path/to/file.py">
<violation number="1" location="path/to/file.py:LINE">
P1: …</violation>
</file>
```

</details>

<sub>Reviewed by <b>xz-review</b></sub>
```

- Lead bullets: **top 3–6** highest-impact issues only.
- Full inventory lives in the collapsible agent prompt + inline threads.
- If **zero** issues: say so, confidence **5/5**, and either skip posting or post a brief LGTM summary (still use `COMMENT` unless user asked `APPROVE` **and** bot ≠ author).

#### Each inline comment body

```markdown
P2: <one-sentence problem and impact>. <fix direction with concrete symbols/APIs>.

<details>
<summary>Prompt for AI agents</summary>

```text
Check if this issue is valid — if so, understand the root cause and fix it. At path/to/file.py, line N:

<comment>...</comment>

<file context>
@@ ... @@
// only the relevant hunk, trimmed
</file context>
```

</details>
```

If you have a safe patch, append a GitHub suggested change:

````markdown
```suggestion
replacement lines exactly as they should appear
```
````

Rules for suggestions:

- Body is the **full new text** of the commented range (not a unified diff)
- Line range of the comment must equal the lines being replaced
- No fences inside the suggestion payload
- Prefer small, surgical replacements

### 5) Map lines correctly

From each file’s `patch`:

- Track new-file line numbers on `+` / context lines (RIGHT)
- Track old-file line numbers on `-` / context lines (LEFT)
- Comment on a `+` or context line on RIGHT whenever the issue is about new/kept code
- Use `start_line` + `line` for multi-line ranges; single-line → only `line`
- `commit_id` **must** be the PR head SHA
- If GitHub would reject the anchor (line not part of the diff), drop that inline comment and keep the finding in the summary

### 6) Post the review (bot token only)

**Dry-run:** print:

1. Human-readable summary (score, counts by P1/P2/P3)
2. Bot login that would post (or `missing-token`)
3. Each inline comment (path, lines, body, suggestion yes/no)
4. The exact JSON body you would POST

**Post** (default when not `--dry-run`):

```bash
GH_TOKEN="$XZ_REVIEW_GITHUB_TOKEN" gh api \
  --method POST \
  repos/{owner}/{repo}/pulls/{pull_number}/reviews \
  --input - <<'EOF'
{
  "commit_id": "<head_sha>",
  "body": "<summary markdown>",
  "event": "COMMENT",
  "comments": [
    {
      "path": "scripts/experiments/plot_sweep_heatmaps.sh",
      "side": "RIGHT",
      "line": 52,
      "start_line": 44,
      "start_side": "RIGHT",
      "body": "P2: ...\n\n<details>...\n\n```suggestion\n...\n```\n"
    }
  ]
}
EOF
```

Notes:

- Omit `start_line` / `start_side` for single-line comments
- `event` from flag; default `COMMENT`. Use `REQUEST_CHANGES` only if there is ≥1 **P1** and the user did not forbid it — if unsure, stick to `COMMENT`
- Never `APPROVE` if bot cannot satisfy branch rules or user did not ask
- On API error: show the error, fix payload (usually line anchors), retry **once**; if still failing, post summary-only review and list dropped inline items locally
- After success, print the review URL from the POST response `html_url`

### 7) Final report to the user

```text
PR: <url>
Posted as: <bot_login>
Confidence: S/5
Issues: K total (P1=a, P2=b, P3=c) across F files
Posted: yes|dry-run|summary-only-fallback|blocked-no-bot-token
Review: <url or n/a>
Top findings:
- P1 ...
- P2 ...
```

---

## Quality bar

Before posting, verify:

- [ ] Summary has **K issues found across F files** and **Confidence score: S/5**
- [ ] Every inline thread starts with **`P1:` / `P2:` / `P3:`**
- [ ] Findings are specific (file + symbol + failure mode)
- [ ] Suggestions are valid replacements for the anchored range (or omitted)
- [ ] Agent prompt blocks exist on summary + each inline comment
- [ ] Poster identity ≠ PR author
- [ ] No local code edits; no force-push

---

## Example invocation

```text
/xz-review https://github.com/xzAscC/RobustDiM-PrefixSteering/pull/21
/xz-review 21 --dry-run
/xz-review --event REQUEST_CHANGES
```

Bot token (local shell, once per session):

```bash
export XZ_REVIEW_GITHUB_TOKEN=ghp_xxxxxxxx   # machine-user PAT, or App-derived token
/xz-review 21
```

Begin now with `$ARGUMENTS`.
