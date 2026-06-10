# Agent Task Prompt Template

Use this template when asking Codex, Claude Code, Cursor, or another coding agent to work on this project.

Copy the prompt below, replace the placeholders, and paste it into the agent.

## Direct Implementation Prompt

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md

Then decide which conditional rule files are relevant:
- .ai/flutter-ui-rules.md if touching UI/widgets/screens/theme/assets/loading/error/empty states/animations.
- .ai/architecture-rules.md if touching features/BLoC/repositories/datasources/models/entities/forms/routing/services.
- .ai/localization-rules.md if adding or changing visible text.
- .ai/code-quality-rules.md before final cleanup.
- .ai/final-checklist.md before declaring the task complete.

Also read these guides only if relevant:
- lib/core/services/objectbox/objectbox_service_guide.md when touching storage/ObjectBox.
- lib/core/router/router_guide.md when touching navigation/routes/guards.
- lib/core/services/session/session_service_guide.md when touching auth/JWT/session.
- lib/common/common_folder_guide.md before creating reusable widgets.
- lib/utils/utils_folder_guide.md before creating utilities/helpers/extensions/constants.

In your first response, list the files you read.
Inspect similar existing implementations before coding.
Make a short plan, then implement directly.
Do not change unrelated files.
Run the required commands from docs/COMMANDS.md.
Summarize changed files, commands run, and checklist status at the end.

Task:
[Describe the task clearly here]

Acceptance criteria:
- [Expected behavior/result 1]
- [Expected behavior/result 2]
- [Any specific files, screens, APIs, or constraints]
```

## Planning Only Prompt

Use this when you want the agent to analyze and propose a plan without editing files.

```text
You are working in this Flutter project.

Read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md

Load only the conditional rule files relevant to this task.
In your first response, list the files you read.
Inspect related files and similar existing implementations.
Do not edit files yet.
Give me a short implementation plan with affected files, required commands, and risks.

Task:
[Describe the task clearly here]
```

## Quick Example

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md

This task touches UI, architecture, and visible text, so also read:
- .ai/flutter-ui-rules.md
- .ai/architecture-rules.md
- .ai/localization-rules.md
- .ai/code-quality-rules.md

Read .ai/final-checklist.md before finishing.
In your first response, list the files you read.
Inspect similar existing implementations before coding.
Make a short plan, then implement directly.

Task:
Add a profile details screen that displays the current user's name, phone number, and account status.

Acceptance criteria:
- The screen uses AppScaffold and declares pagePath/pageName.
- All visible strings use AppStrings.
- Text uses AppTextStyles and semantic colors.
- The route is registered using the existing router pattern.
- Loading/error/empty states use the platform widgets.
```

## Small Task Shortcut

For tiny tasks, you can use this shorter version:

```text
Read .ai/project-rules.md, .ai/task-workflow.md, docs/PROJECT_MAP.md, and docs/COMMANDS.md first.
Then load only the relevant conditional rules.
List the files read, inspect similar code, make a short plan, implement, run required checks, and summarize.

Task:
[Your task here]
```
