---
description: Polish scientific LaTeX writing with concise, precise prose
---

Polish the scientific writing identified by `$ARGUMENTS`.

The argument may be a file path, a passage, or an instruction that points to content already present in the conversation. If it is a file path, read the file before editing. If the target cannot be identified reliably, ask one concise clarifying question.

This is a polishing task only. Do not answer the text, translate it, summarize it, fact-check it, add new claims, or expand its scope.

Writing goals:
- Make the prose concise, precise, clear, and natural.
- Preserve the author's voice and a recognizably human rhythm.
- Remove redundancy, inflated phrasing, filler, canned transitions, and AI-like language.
- Prefer direct wording and concrete verbs. Use active or passive voice according to scientific convention and context, not as a mechanical rule.
- Improve grammar, syntax, logical flow, and paragraph cohesion without making the prose ornate.

Scientific and LaTeX constraints:
- Preserve the scientific meaning, degree of certainty, argument, evidence, and scope exactly.
- Do not alter technical terms, symbols, variable names, numbers, units, equations, code, URLs, citation keys, cross-reference keys, labels, or bibliography entries.
- Preserve all LaTeX commands, environments, comments, braces, math delimiters, and document structure. Polish only human-readable prose.
- Never invent citations, results, explanations, or connective reasoning.
- Keep established abbreviations and terminology consistent with the source.

Output requirements:
- Do not modify files directly.
- Return only a unified diff that contains the proposed prose changes.
- Keep the diff minimal: do not reformat untouched LaTeX or change line wrapping solely for style.
- If no meaningful improvement is needed, say `No changes needed.` instead of manufacturing edits.
