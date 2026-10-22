# Agent task prompts

Copy-paste prompts for Claude Code, Codex, Cursor or any other coding agent working in this project. Pick one, fill the
brackets, paste it.

The rules are **not** repeated here. `.ai/project-rules.md` is the single source — every prompt sends the agent to it, so a
rule changed there is changed everywhere. Say **what** you want and **how you will judge it**; leave the how to the agent.

| Prompt | Use it for |
| --- | --- |
| [Implement](#implement) | Most tasks |
| [Plan only](#plan-only) | A plan and the risks, no edits |
| [New feature](#new-feature) | A feature from scratch: spec first, on mock data |
| [Screen from a design](#screen-from-a-design) | A screen built from images or a design file |
| [Bug fix](#bug-fix) | Root cause first, then a fix with a test |
| [Review](#review) | A review of a change, no edits |
| [Small task](#small-task) | A one-line change |

A good request names: the **goal**, the **screens or files** involved, the **acceptance criteria** (what you will check), and
the **constraints** (what must not change).

## Implement

```text
Work in this Flutter project. Read .ai/project-rules.md first and follow it, then read only what it points to for this task.
List the files you read. Look at similar existing code, make a short plan, then implement. Do not change unrelated files.
Run the checks (analyze, tests) and walk .ai/final-checklist.md. Do not commit.

Task:
[What to build or change, and why]

Acceptance criteria:
- [What I will check 1]
- [What I will check 2]

Constraints:
- [What must not change / what to reuse]
```

## Plan only

```text
Work in this Flutter project. Read .ai/project-rules.md first, then what it points to for this task. List the files you read.
Do NOT edit anything. Give me a short plan: the files you would change, the commands, the risks, and any question you
need answered first.

Task:
[What I am thinking of doing]
```

## New feature

```text
Work in this Flutter project. Read .ai/project-rules.md first and follow it, plus docs/FEATURE_SPEC_TEMPLATE.md.

Build a new feature: [name — who uses it, what they see, what they can do]

1. Write the spec from docs/FEATURE_SPEC_TEMPLATE.md and show it to me BEFORE you code. Wait for my answer.
2. Start from the generator: dart run tool/generate_feature.dart <name> --mock (docs/COMMANDS.md).
3. Mock fixtures for every endpoint; every state handled (loading, empty, error, success), sections loading on their own.
4. The page is an AppPage opened with AppNavigator.push; it adapts to compact, medium and expanded windows (spec §2.6).
5. Tests: bloc, widgets at 320dp and 1280dp in both themes and both directions, and a skeleton parity line per .loading().

List the files you read, then plan and implement. Walk .ai/final-checklist.md. Do not commit.
```

## Screen from a design

```text
Work in this Flutter project. Read .ai/project-rules.md first and follow it.

Build this screen from the attached design(s): [screen name]

- Match the layout, order and hierarchy. Where a detail disagrees with the design system (DESIGN_SYSTEM.md), follow the design
  system and tell me what you changed and why.
- Show what it does on a phone and in a wide window — the design shows [compact only / both]; if only compact, propose the wide
  layout and tell me.
- Data through the mock layer with realistic fixtures, never hard-coded in widgets.
- Reusable pieces go in lib/common/widgets; screen-specific pieces stay in the feature.

Attached images:
1. [What image 1 shows]
2. [What image 2 shows]

List the files you read, plan, implement, walk .ai/final-checklist.md. Do not commit.
```

## Bug fix

```text
Work in this Flutter project. Read .ai/project-rules.md first, then only the rule files the fix touches.

Fix this bug. First reproduce it and find the root cause; tell me the cause before you change code if the fix is not obvious.
Add a test that FAILS without the fix. Do not refactor around it.

Bug:
[What happens, what should happen, the steps, which screen / platform / window size, logs or a screenshot]

List the files you read. Finish with: the cause, the changed files, the test, and the commands you ran. Do not commit.
```

## Review

```text
Work in this Flutter project. Read .ai/project-rules.md and .ai/final-checklist.md.

Review [this diff / these files / branch]. Do NOT edit anything. For each problem: file and line, what is wrong, why it
matters, and the fix. Order by severity. Check against the rules (text, look, layout, architecture, tests), not just
whether it works. Say plainly if you find nothing.
```

## Small task

```text
Read .ai/project-rules.md, then only what this task needs. List the files you read, look at similar code, make the change,
run analyze and the relevant tests, and summarise. Do not commit.

Task:
[Your task]
```
