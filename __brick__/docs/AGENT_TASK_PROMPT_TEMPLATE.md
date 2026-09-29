# Agent Task Prompt Template

Copy-paste prompts for Codex, Claude Code, Cursor or any other coding agent working on
this project. Pick the one that fits, fill in the brackets, paste it.

| Prompt | Use it for |
| --- | --- |
| [Direct implementation](#direct-implementation) | Most tasks |
| [Planning only](#planning-only) | A plan and risks, no edits |
| [New feature](#new-feature) | A feature from scratch, spec first, on mock data |
| [Screen from a design](#screen-from-a-design) | Building a screen from images or a design file |
| [Bug fix](#bug-fix) | Root cause first, then a fix with a test |
| [Small task](#small-task) | One-line changes |

Say **what** you want and how you will judge it; leave the **how** to the agent — the
rules files already carry it.

## Direct implementation

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md

Then read what the task touches:
- .ai/flutter-ui-rules.md and DESIGN_SYSTEM.md — any UI: screens, widgets, theme, icons,
  loading / empty / error states, motion.
- .ai/architecture-rules.md — features, BLoC, repositories, data sources, models, routing, services.
- .ai/localization-rules.md — any visible text.
- docs/FEATURE_SPEC_TEMPLATE.md — a new feature.
- docs/DECISIONS.md — before changing how something established works.
- .ai/code-quality-rules.md before cleanup, .ai/final-checklist.md before calling it done.

Guides, only when relevant:
- lib/core/router/router_guide.md — navigation, routes, guards, links.
- lib/core/services/session/session_service_guide.md — auth, JWT, session.
- lib/core/services/objectbox/objectbox_service_guide.md — local storage.
- lib/common/common_folder_guide.md — before creating a reusable widget.
- lib/utils/utils_folder_guide.md — before creating a helper, extension or constant.
- test/README.md — before writing tests.
- assets/mock/README.md — before adding mock fixtures.

House rules:
- Follow the design system; no hard-coded colours, sizes or text styles.
- Loading states are skeletons (SkeletonWidget), never spinners for content.
- All visible text comes from AppStrings (assets/l10n/*.json + the generator).
- Works in Arabic (RTL) and English, light and dark, with reduced motion.
- New endpoints get mock fixtures, so the work runs with USE_MOCK=true.
- New behaviour gets tests.
- Do not commit unless asked.

In your first response, list the files you read.
Inspect similar existing code before writing new code.
Make a short plan, then implement. Do not change unrelated files.
Run the required commands from docs/COMMANDS.md.
Finish with: changed files, commands run, checklist status, and anything you could not do.

Task:
[Describe the task clearly]

Acceptance criteria:
- [Expected result 1]
- [Expected result 2]
- [Screens, APIs, files or constraints that matter]
```

## Planning only

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md

Load only the conditional rules this task needs.
In your first response, list the files you read.
Inspect related code and similar implementations.
Do not edit files yet.
Give me a short plan: affected files, required commands, risks, open questions.

Task:
[Describe the task clearly]
```

## New feature

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md
Also read .ai/flutter-ui-rules.md, .ai/architecture-rules.md, .ai/localization-rules.md,
DESIGN_SYSTEM.md and docs/FEATURE_SPEC_TEMPLATE.md.

Build a new feature: [the feature / screen]

1. Write a short spec from docs/FEATURE_SPEC_TEMPLATE.md and show it to me before coding.
2. Start from the feature generator (docs/COMMANDS.md → New Feature) with mock data.
3. Real-looking mock fixtures for every endpoint; every state handled (loading, empty,
   error, success) and each section loading on its own.
4. The page is an AppPage opened with AppNavigator.push.
5. Tests: bloc, widgets, and a skeleton height-parity line for each new SkeletonWidget.

House rules:
- Follow the design system; no hard-coded colours, sizes or text styles.
- Loading states are skeletons (SkeletonWidget), never spinners for content.
- All visible text comes from AppStrings (assets/l10n/*.json + the generator).
- Works in Arabic (RTL) and English, light and dark, with reduced motion.
- New endpoints get mock fixtures, so the work runs with USE_MOCK=true.
- New behaviour gets tests.
- Do not commit unless asked.

In your first response, list the files you read.
Inspect similar existing code before writing new code.
Make a short plan, then implement. Do not change unrelated files.
Run the required commands from docs/COMMANDS.md.
Finish with: changed files, commands run, checklist status, and anything you could not do.

What the feature does:
[Describe it: who uses it, what they see, what they can do]
```

## Screen from a design

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md
Also read .ai/flutter-ui-rules.md, DESIGN_SYSTEM.md and .ai/localization-rules.md.

Build this screen from the attached design(s): [the feature / screen]

- Match the design: layout, order, hierarchy, the details that make it recognisable.
  Where it disagrees with the design system on a small detail, follow the design system
  and tell me.
- All data through the mock layer with realistic fixtures, never hard-coded in widgets.
- Reusable pieces go in the shared widgets; screen-specific pieces stay with the feature.

House rules:
- Follow the design system; no hard-coded colours, sizes or text styles.
- Loading states are skeletons (SkeletonWidget), never spinners for content.
- All visible text comes from AppStrings (assets/l10n/*.json + the generator).
- Works in Arabic (RTL) and English, light and dark, with reduced motion.
- New endpoints get mock fixtures, so the work runs with USE_MOCK=true.
- New behaviour gets tests.
- Do not commit unless asked.

In your first response, list the files you read.
Inspect similar existing code before writing new code.
Make a short plan, then implement. Do not change unrelated files.
Run the required commands from docs/COMMANDS.md.
Finish with: changed files, commands run, checklist status, and anything you could not do.

Attached images:
1. [What image 1 shows]
2. [What image 2 shows]
```

## Bug fix

```text
You are working in this Flutter project.

Before editing any file, read and follow:
- .ai/project-rules.md
- .ai/task-workflow.md
- docs/PROJECT_MAP.md
- docs/COMMANDS.md
Load only the conditional rules the fix touches.

Fix this bug. First reproduce it and find the root cause; tell me the cause before
changing code if the fix is not obvious. Add a test that fails without the fix.
Do not refactor around it.

In your first response, list the files you read.
Inspect similar existing code before writing new code.
Make a short plan, then implement. Do not change unrelated files.
Run the required commands from docs/COMMANDS.md.
Finish with: changed files, commands run, checklist status, and anything you could not do.

Bug:
[What happens, what should happen, steps, screen/app, logs if any]
```

## Small task

```text
Read .ai/project-rules.md, .ai/task-workflow.md, docs/PROJECT_MAP.md and docs/COMMANDS.md first,
then only the rules the task needs.
List the files you read, check similar code, make a short plan, implement, run the checks,
and summarise. Do not commit.

Task:
[Your task]
```
