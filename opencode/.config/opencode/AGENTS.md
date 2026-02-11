# AGENTS.md

This file guides autonomous coding agents working in this repository.
Follow these rules unless a user request explicitly overrides them.

## 1) Repository Snapshot

- Package manager: `bun` (`bun.lock` is present).
- Manifest: `package.json` only includes dependencies, no scripts yet.
- Current direct dependency: `@opencode-ai/plugin`.
- No application source files were found outside `node_modules`.
- No test, lint, or formatter config files were found.
- No monorepo/workspace tool config was found.

## 2) Rule Files Discovered

- Cursor rules in `.cursor/rules/`: not found.
- Root `.cursorrules`: not found.
- Copilot rules in `.github/copilot-instructions.md`: not found.

Implication for agents:
- There are no extra IDE-level policy files to apply right now.
- Re-check these paths before large edits in case they are added later.

## 3) Build / Lint / Test Commands

Because there are no scripts in `package.json`, use direct Bun commands.

### Setup

- Install dependencies: `bun install`
- Reproducible install from lockfile: `bun install --frozen-lockfile`

### Build

- Current status: no build pipeline is configured.
- If a build script is added later, prefer: `bun run build`

### Lint

- Current status: no lint tool is configured.
- If ESLint is added later, prefer: `bun run lint`

### Test

- Current status: no test files/config are present.
- If Bun test is adopted, run all tests with: `bun test`

### Single-Test Execution (Important)

Use the command that matches the framework introduced in the repo.

- Bun test, by file:
  `bun test path/to/file.test.ts`
- Bun test, by test name pattern:
  `bun test --test-name-pattern "should do thing"`
- Bun test, file + name pattern:
  `bun test path/to/file.test.ts --test-name-pattern "case name"`

- Vitest (if added), by file:
  `bun run vitest path/to/file.test.ts`
- Vitest, by name:
  `bun run vitest -t "case name"`

- Jest (if added), by file:
  `bun run jest path/to/file.test.ts`
- Jest, by name:
  `bun run jest -t "case name"`

Agent behavior:
- Prefer project scripts (`bun run test`, `bun run lint`) once they exist.
- Until scripts exist, document the exact command used in your final note.

## 4) Code Style and Engineering Conventions

There is no enforced linter/formatter yet, so follow these defaults.

### 4.1 Imports

- Use ESM imports/exports, not CommonJS `require`.
- Group imports in this order:
  1) Node built-ins,
  2) third-party packages,
  3) internal modules.
- Keep one blank line between import groups.
- Prefer named exports over default exports for shared modules.
- Avoid deep imports unless package docs recommend them.

### 4.2 Formatting

- Use UTF-8 text and LF line endings.
- Keep lines readable; target ~100 chars soft limit.
- Use semicolons consistently within a file.
- Use trailing commas where valid in multiline literals.
- Keep functions short and focused; extract helpers when needed.
- Avoid adding comments for obvious code.

### 4.3 Types (TypeScript-first guidance)

- Prefer TypeScript for new source files (`.ts`/`.tsx`).
- Avoid `any`; use `unknown` + narrowing when needed.
- Model domain data with explicit interfaces/types.
- Encode nullable states explicitly (`T | null`, `T | undefined`).
- Prefer discriminated unions for variant states.
- Validate untrusted input at boundaries (e.g., with `zod`).
- Export types close to where they are used.

### 4.4 Naming

- Variables/functions: `camelCase`.
- Types/classes/components: `PascalCase`.
- Constants/env keys: `UPPER_SNAKE_CASE`.
- Files: `kebab-case` for modules, `PascalCase` for components.
- Test files: `*.test.ts` or `*.spec.ts` consistently.
- Use descriptive names; avoid single-letter identifiers except loop indices.

### 4.5 Error Handling

- Fail fast on invalid input.
- Throw typed/domain-specific errors where useful.
- Do not swallow errors silently.
- Add actionable context to error messages.
- At process boundaries (CLI/API), catch and map to user-safe output.
- Preserve original error as `cause` when wrapping.

### 4.6 Logging

- Prefer structured logs over ad-hoc strings.
- Never log secrets or tokens.
- Keep high-volume debug logs behind flags.

### 4.7 Testing Expectations

- Add or update tests for behavior changes.
- Cover happy path, edge cases, and failure paths.
- Keep tests deterministic and isolated.
- Avoid network calls in unit tests; mock boundaries.

## 5) Agent Workflow Expectations

- Read existing files before editing.
- Make minimal, targeted diffs.
- Preserve backwards compatibility unless asked otherwise.
- If introducing a new tool (lint/test/build), add `package.json` scripts.
- If scripts are added, update this `AGENTS.md` command section.
- After edits, run the most relevant verification commands available.
- In final responses, include:
  - files changed,
  - commands run,
  - any skipped verification and why.

## 6) When the Repo Evolves

When real source code is added, agents should immediately:

- Re-scan for `.cursor/rules/`, `.cursorrules`, and `.github/copilot-instructions.md`.
- Re-scan for lint/test/build config files.
- Replace provisional guidance in this file with concrete project rules.
- Add canonical single-test examples for the chosen framework only.

Until then, treat this document as the operational baseline.
