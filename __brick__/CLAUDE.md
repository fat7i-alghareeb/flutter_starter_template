# {{project_title}} — instructions for Claude Code

@.ai/project-rules.md

The file above is the project digest: rules, stack, the "what to read for which task" table, commands. It is already in your
context — do not open it again.

## Token discipline (every chat)

Every chat starts empty and everything loaded is paid for on every turn, so: load little, load once, load on demand.

- **Never re-read what you know.** A file you already read in this chat is not read again unless `git status` / `git diff` shows it
  changed. A fact that is in this file, the digest above, or memory is not looked up again. Read before you act, once.
- **Read narrowly.** `grep` / a line range first; open a whole file only when you must edit it or the structure matters. Never read
  generated files (`*.freezed.dart`, `*.g.dart`, `injectable.config.dart`, `assets.gen.dart`, `lib/utils/gen/app_strings.g.dart`):
  find an `AppStrings` getter with `grep -n "'the.key'" lib/utils/gen/app_strings.g.dart` (getter = camelCase of the key).
- **Details load on demand.** Path-scoped rules in `.claude/rules/` load themselves when you touch matching files. The long guides
  (`docs/`, `lib/**/*_guide.md`) are read only when the task needs them — use the digest's task table to pick, not a sweep.
- **Delegate noise.** Wide exploration, log reading and long test output go to a subagent; only its summary comes back.
- **Pick the model once, at the start**, and do not switch mid-task (a switch rebuilds the cache). Default: Sonnet, medium effort;
  Opus / high effort only for architecture or a hard bug; Haiku for simple subagents.
- **One task per chat.** When a task is done and the next is unrelated, say so and suggest `/clear`. `/compact` only at a natural break.
- **Do not trade correctness for tokens.** Always run the checks (`flutter analyze`, the relevant tests). Use plan mode for changes that
  touch several files or when unsure of the approach; skip it for a one-line fix.

## Building features (every time)

- **Reference feature:** `lib/features/showcase_feed/` (the owner changes this line to promote another). Before coding a feature, find
  the closest finished one, read it, and copy its shape: folders, names, state, tests. `docs/CODE_STYLE.md` records how the owner writes
  code; follow it, and add a line when the owner corrects you.
- **Before building any widget or helper:** `dart run tool/widget_catalog.dart <word>` (`--all` adds feature widgets). A match → use it
  or add a parameter. Two near-duplicates, or about to write a second copy → **ask the owner** (merge / add a parameter / keep both)
  with the options; never silently duplicate, never silently refactor shared code.
- **A new design (Figma or not)** becomes a rule: new component, token or visual rule → `DESIGN_SYSTEM.md`, and the widget with its
  Figma node link → `lib/common/common_folder_guide.md`.
- **When a feature or a new UI element is done** (not for a bug fix): run `/finish` yourself — it updates only the docs that changed,
  `CODE_STYLE.md` and memory, then reports in five lines.

## Memory

- Save to auto memory only what the repo cannot tell you: a decision and its reason, a preference, an external fact. One fact per file.
- When you verify something on the web (a package, an API, a store rule), save the answer as a `reference` memory with the source URL
  so it is never searched twice. Check memory before searching.
- Do not save code structure, file paths or anything in git history.

## How to work with me

- **Ask, with options.** When a decision is mine (design, naming, scope, a package, a trade-off), ask with the question tool: 2–4
  options, your recommendation first, batched in one set of questions. Do not guess a decision that is mine; do not ask about
  things the digest already answers.
- **Verify on the web before you implement anything about a package, platform or store.** Official docs first; cite the source in your
  reply. Never rely on memory for versions, APIs or platform rules.
- **Do not commit** unless I ask. Never push.
- **Reports are short:** files changed, commands run with pass/fail, what needs my decision. No recap of the work, no restating the task.
- Reply in the language I write in.

## First time in a new project

This project came from a brick, so Claude has not been set up for it yet. Run **`/first-run`** once: it checks the platform folders,
asks the project questions (with options), records the answers in the section below and in memory, and gives me the manual
checklist. Until that section is filled in, remind me to run it.

## This project (filled in by `/first-run`)

_Not set up yet — run `/first-run`._

## Compact instructions

When compacting, keep: the files changed and why, the exact test/analyze commands and their last result, decisions made and their
reasons, and anything I still have to decide. Drop file contents, command output and exploration.
