# Task workflow

How to carry out any task in this repository. Follow it in order.

## Decide the mode

| The request says… | Mode | You may edit files? |
| --- | --- | --- |
| a plan, a design, "what would you do", a review, an explanation | **Plan only** | No |
| build, add, fix, change, refactor, update | **Implement** | Yes, after the short plan |
| "plan first, then wait" | **Plan, then wait** | Only after the person approves |

If you cannot tell, ask one short question instead of guessing.

## Steps

1. **Read.** `project-rules.md`, then the files its table sends you to for this task. List them in your first reply.
2. **Inspect.** Read the files directly involved and the closest existing example. Search for something that already does
   what you need (`lib/common/common_folder_guide.md`, `lib/utils/utils_folder_guide.md`, `docs/PROJECT_MAP.md`).
   Prefer an existing pattern to a new abstraction.
3. **Plan.** A few lines: files you will change, commands you will run, anything risky or undecided. Task-sized, not an essay.
4. **Implement.** Change only what the task needs. No drive-by refactors, no unrelated formatting. Keep each change small enough
   to review.
5. **Run.** The commands in `docs/COMMANDS.md`, only the ones the change calls for (strings generator after editing `l10n`,
   `build_runner` after changing generated-code inputs, then analyze and tests).
6. **Clean up.** `code-quality-rules.md`.
7. **Check.** `final-checklist.md`.
8. **Report.** What changed (files), which commands you ran and their result, anything you skipped and why, anything the person
   must decide. If a check failed, say so with the failing line — do not describe a partial result as done.

## Before you edit anything, confirm

- The change belongs in this file and layer (`.ai/architecture-rules.md` → "Where a thing goes").
- Nothing already exists that does the same job (widget, helper, extension, form, route pattern).
- You know which rule files apply (UI, architecture, localisation).
- You can say how you will verify it.

## Debugging

Reproduce first. Find the cause before you change code; if the fix is not obvious, say what the cause is. Add a test that
fails without the fix. Do not refactor around the bug.

## Things that need a person's decision

Deleting a feature or a dependency, changing the auth mode, changing a route or a stored key (users have data), changing
signing, release or CI configuration, anything irreversible or visible outside the repository. Propose it; do not do it.
