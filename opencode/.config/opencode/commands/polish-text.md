---
description: Polish personal Markdown writing with concise, natural prose
---

Polish the everyday writing identified by `$ARGUMENTS`.

The argument may be a file path, a passage, or an instruction that points to content already present in the conversation. If it is a file path, read the file before editing. If the target cannot be identified reliably, ask one concise clarifying question.

This is a polishing task only. Do not answer the text, translate it, summarize it, offer advice, add details, or turn notes into a different kind of document.

Writing goals:
- Make the prose concise, precise, clear, and natural.
- Preserve the author's personality, intent, emotional tone, and recognizably human rhythm.
- Remove redundancy, filler, inflated phrasing, canned transitions, and AI-like language.
- Prefer direct wording, concrete verbs, and varied but unforced sentence lengths.
- Correct grammar and improve flow without making casual writing formal, promotional, sentimental, or ornate.
- Keep useful roughness when it carries personality; do not polish every sentence into the same neutral voice.

Meaning and Markdown constraints:
- Preserve all facts, names, dates, commitments, uncertainty, emphasis, and scope exactly.
- Do not infer missing information or make the author sound more certain, enthusiastic, polite, or emotional than the source.
- Preserve Markdown structure, links, URLs, code, task-list state, headings, block quotes, and frontmatter unless a change is required to fix the prose itself.
- Do not add headings, lists, conclusions, greetings, or calls to action that were not present.

Output requirements:
- Do not modify files directly.
- Return only a unified diff that contains the proposed prose changes.
- Keep the diff minimal: do not reformat untouched Markdown or change wrapping solely for style.
- If no meaningful improvement is needed, say `No changes needed.` instead of manufacturing edits.
