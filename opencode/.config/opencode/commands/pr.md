---
description: Create a GitHub pull request using repo's PR template
---
Create a pull request following GitHub PR template conventions.

Goals:
1. Gather branch context and changes to be included in PR.
2. Fetch PR template from the repository (if available).
3. Create a well-structured PR with proper title and body.

Steps:
1. **Check current state**:
   - Run `git status --short` to see working tree state
   - Run `git rev-parse --abbrev-ref HEAD` to get current branch
   - If working tree is dirty, ask user whether to commit changes first or proceed
   - Ensure current branch is not `main`/`master` (create feature branch if needed)

2. **Push branch to remote**:
   - Check if branch has upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - If no upstream, push with `-u origin <branch-name>`
   - If upstream exists but behind, run `git push` (never force push without explicit user request)

3. **Fetch PR template**:
   - Try to fetch template via `gh api repos/{owner}/{repo}/contents/.github/PULL_REQUEST_TEMPLATE.md`
   - Also check `.github/PULL_REQUEST_TEMPLATE` (no extension) and `PULL_REQUEST_TEMPLATE.md` at root
   - If template found, decode from base64 and use as PR body structure
   - If no template, use default structure (see below)

4. **Analyze changes for PR**:
   - Get base branch (default `main` or `master`)
   - Run `git log {base}..HEAD --oneline` to see commits in this PR
   - Run `git diff {base}...HEAD --stat` for change summary
   - If commits > 10, suggest squashing before creating PR

5. **Draft PR content**:
   - Title: Use `$ARGUMENTS` if provided, otherwise derive from branch name or primary commit
   - Body: Follow template structure or default format
   - Default PR body structure:
     ```markdown
     ## Summary
     <!-- 1-3 bullet points of what this PR accomplishes -->

     ## Changes
     <!-- List of key changes -->

     ## Testing
     <!-- How to verify these changes work -->

     ## Checklist
     - [ ] Code compiles correctly
     - [ ] Tests pass (if applicable)
     - [ ] Documentation updated (if applicable)
     ```

6. **Create the PR**:
   - Use `gh pr create` with the prepared title and body
   - If draft PR preferred, use `--draft` flag
   - Include `--base` flag if targeting non-default branch

7. **Report results**:
   - PR URL
   - Title used
   - Base branch
   - Whether template was found/used

Safety rules:
- Never force push without explicit user request
- Stop and ask if there are merge conflicts
- Warn if PR contains secrets or sensitive files
- Ask for confirmation before creating PR if > 10 commits
