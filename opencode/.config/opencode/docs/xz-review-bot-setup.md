# xz-review GitHub bot setup

Personal accounts **cannot meaningfully review their own PRs** for branch protection (no self-approve; many rules require a different reviewer). Use a **separate bot identity**.

Two workable setups:

| Approach | Looks like | Effort | Best for |
|----------|------------|--------|----------|
| **A. Machine user + PAT** | `xz-review-bot` (normal user) | Low | Solo / few repos |
| **B. GitHub App** | `xz-review[bot]` (like cubic) | Medium | Real bot badge, many repos, Actions |

Recommended path: **A first** (today), upgrade to **B** when you want the `[bot]` badge and tighter permissions.

---

## A) Machine user + PAT (simplest)

### 1. Create a bot account

1. Register a second GitHub user, e.g. `xz-review-bot` (use a +address email).
2. Enable 2FA on that account.
3. Do **not** use this account for daily commits.

### 2. Grant repo access

For each repo the bot should review:

- **Personal repo:** Settings → Collaborators → add `xz-review-bot` with **Write** (needed to submit reviews / suggestions).
- **Org repo:** add the bot to a team with Write, or as a collaborator.

### 3. Create a fine-grained PAT (bot account)

While logged in as the bot:

1. GitHub → Settings → Developer settings → Personal access tokens → **Fine-grained tokens**
2. Resource owner: the bot (or org if applicable)
3. Repository access: only the repos you need
4. Permissions:
   - **Pull requests:** Read and write
   - **Contents:** Read-only (enough to read code; Write only if you later auto-commit)
   - **Metadata:** Read-only (automatic)
5. Generate and store the token in a password manager.

Classic PAT alternative: scope `repo` (broader — prefer fine-grained).

### 4. Use with OpenCode `/xz-review`

```bash
export XZ_REVIEW_GITHUB_TOKEN=github_pat_xxxx   # bot PAT
# optional: keep your normal gh login for other commands
/xz-review 21
```

The command posts with `GH_TOKEN=$XZ_REVIEW_GITHUB_TOKEN` and refuses to post if the token identity equals the PR author.

### 5. Optional: shell helper

```bash
# ~/.bashrc.d/xz-review.sh
export XZ_REVIEW_GITHUB_TOKEN="$(pass show github/xz-review-bot-pat)"  # or op read ...
```

Never commit the token into dotfiles.

---

## B) GitHub App (shows `xz-review[bot]`)

This is how products like cubic appear as `something[bot]`.

### 1. Create the App

1. GitHub → Settings → Developer settings → **GitHub Apps** → New GitHub App  
   (or Org settings → GitHub Apps if org-owned)
2. Suggested settings:
   - **Name:** `xz-review`
   - **Homepage URL:** your repo or docs URL
   - **Webhook:** disable for local-only; enable later for automation
   - **Permissions:**
     - Repository → **Pull requests:** Read & write
     - Repository → **Contents:** Read-only
     - Repository → **Metadata:** Read-only
     - Repository → **Checks:** Read & write (optional, for check runs)
   - **Where can this App be installed?** Only on this account (or any account)
3. Create App → note **App ID**
4. **Generate a private key** (`.pem`) — store securely
5. Optional: upload a bot avatar

### 2. Install the App

Install on the target account/org → select repos (e.g. `RobustDiM-PrefixSteering`).

Note the **Installation ID** (from the install URL or API).

### 3. Mint an installation access token

Tokens expire (~1 hour). Locally or in CI:

```bash
# Requires: App ID, Installation ID, private key path
# Example using gh + jwt (or a tiny script)

# 1) Create JWT signed with the App private key (iss=App ID, exp=+9min)
# 2) Exchange:
curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
  | jq -r .token
```

Then:

```bash
export XZ_REVIEW_GITHUB_TOKEN="<installation_token>"
/xz-review 21
```

Ready-made helpers:

- [`actions/create-github-app-token`](https://github.com/actions/create-github-app-token) (in Actions)
- `gh` extension / small scripts that wrap App JWT → installation token

### 4. Branch protection

Settings → Branches → ruleset / protection:

- Require pull request reviews
- Required reviewers: 1
- **Dismiss stale reviews** as you prefer
- Do **not** require the author; the App/bot counts as a separate actor for `COMMENT` / `REQUEST_CHANGES`

Note: **Approve** from a bot only counts if your rules allow bot reviews (org setting: “Allow specified actors to bypass…” / “Restrict who can dismiss…” — check current org policy). Many people use bot for findings (`COMMENT` / `REQUEST_CHANGES`) and humans for final approve.

---

## C) Auto-run on every PR (GitHub Actions)

After A or B works manually, add a workflow (copy from `docs/xz-review-action.example.yml`):

1. Store secrets on the repo/org:
   - Machine user: `XZ_REVIEW_BOT_PAT`
   - Or App: `XZ_REVIEW_APP_ID`, `XZ_REVIEW_APP_PRIVATE_KEY`, (installation id optional if discoverable)
2. On `pull_request` / `pull_request_target` (careful with forks): checkout PR head → run OpenCode/agent or a slim reviewer → `POST /pulls/{n}/reviews` with bot token
3. Prefer **App token** in Actions so comments show as `xz-review[bot]`

**Fork PR warning:** never expose high-privilege secrets on `pull_request` from forks. Use `pull_request_target` only with a locked-down flow, or require maintainer approval (environment protection).

---

## Sanity checks

```bash
# Who am I with the bot token?
GH_TOKEN="$XZ_REVIEW_GITHUB_TOKEN" gh api user --jq .login
# → xz-review-bot   or   (App tokens show as the app bot user)

# Can the bot see the PR?
GH_TOKEN="$XZ_REVIEW_GITHUB_TOKEN" gh pr view 21 --repo OWNER/REPO

# Dry-run review content without posting
# (in OpenCode)
/xz-review 21 --dry-run
```

Expected UI after a real post:

- Review author is the **bot**, not you
- Summary: `N issues found` + `Confidence score: S/5`
- Inline **P1/P2/P3** threads with optional **Apply suggestion**
- Each thread has **Resolve conversation**

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|--------|-----|
| `Can not approve your own pull request` | Token is the PR author | Use bot PAT/App token |
| `Resource not accessible by integration` | App missing permission or not installed on repo | Fix App perms + reinstall |
| `Unprocessable Entity` on comments | Bad `line` / `commit_id` | Re-map lines from PR head diff |
| `403` on fine-grained PAT | Repo not in token scope / missing PR write | Edit token resource access |
| Suggestions not shown | Comment not covering exact replaced lines | Align `start_line`/`line` with suggestion body |
| Branch protection still red | Rules require human approve | Keep bot on `COMMENT`/`REQUEST_CHANGES`; human approves |

---

## Minimal decision

1. Need it working **today** on your own PRs → **machine user + PAT** + `export XZ_REVIEW_GITHUB_TOKEN=...` + `/xz-review`
2. Want **`[bot]` badge** and CI → **GitHub App** + Actions example workflow
