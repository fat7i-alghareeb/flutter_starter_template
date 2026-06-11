# Task Workflow

Use this workflow for every coding-agent task.

## Standard Flow

1. Read required docs.
   - Always read `.ai/project-rules.md`, `.ai/task-workflow.md`, `docs/PROJECT_MAP.md`, and `docs/COMMANDS.md`.
   - Load conditional rule files based on the touched layer.
2. Understand the task.
   - Identify whether it is planning-only, implementation, review, debugging, or documentation.
3. Inspect related files only.
   - Read the files directly involved and their closest examples.
4. Search for similar implementations.
   - Prefer existing app patterns over new abstractions.
   - Audit `lib/common/common_folder_guide.md` before creating reusable UI.
   - Audit `lib/utils/utils_folder_guide.md` before creating helpers, constants, or extensions.
5. Create a short plan before editing code.
   - Mention likely files and commands.
   - Keep the plan practical and task-sized.
6. Implement.
   - Ask for approval before editing when the user requested a plan first.
   - If the user explicitly asked for direct implementation, proceed after the short plan.
   - If the user asked for planning only, stop before editing.
7. Run required commands.
   - Use `docs/COMMANDS.md`.
   - Run generation only when the related files changed.
8. Final cleanup.
   - Remove unused imports, dead code, debug leftovers, and duplicate patterns.
   - Read `.ai/code-quality-rules.md` before final cleanup.
9. Confirm completion.
   - Read `.ai/final-checklist.md`.
   - Summarize changed files, verification commands, and any skipped checks.

## Planning Only Mode

Use this mode when the user asks for a plan, design, explanation, review, or "what would you do?"

- Read the relevant docs and files.
- Explain the implementation approach.
- List affected files and commands.
- Do not edit files.

## Implementation Mode

Use this mode when the user asks to build, fix, refactor, update, or otherwise change the project.

- Read the required docs.
- Make a short plan.
- Edit only the necessary files.
- Run the required command or explain why it could not be run.
- Update docs when the change creates or changes reusable behavior.

## Before Editing

Always verify:

- The requested change belongs in the file or layer you plan to edit.
- A similar implementation does not already exist.
- The edit will not duplicate common widgets, helpers, form definitions, request models, or route patterns.
- The relevant localization, UI, architecture, and code-quality rules are loaded.
