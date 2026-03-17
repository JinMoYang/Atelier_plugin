---
name: go
description: Execute pending plan sections (or specific ones)
---

# /go [section names...]

Execute plan sections. Atelier auto-detects the active plan file.

## Plan Detection

The active plan is found automatically:
1. Any `.md` file with `<!-- plan:meta -->` marker (set by Atelier when you hit Go)
2. Path in `.atelier` config file (`plan: path/to/plan.md`)
3. Most recent `.md` with `## ` headings in `docs/superpowers/plans/`, `notes/`, or project root

Check the ATELIER_PLAN_STATE block in your context — it shows the detected plan and sections.

## Usage

- `/go` — execute all pending sections in priority order
- `/go "Data ingestion"` — execute only that section
- `/go "Data ingestion" "Validation"` — execute those two sections

## Behavior

1. Read the plan file (from ATELIER_PLAN_STATE or auto-detect)
2. If the plan has no `<!-- plan:meta -->` marker, add one (this marks it as the active plan)
3. Identify target sections (all pending, or the named ones)
4. For each target section in priority order:
   a. Update section status to `in_progress` in the plan file: add/update `<!-- section:meta status=in_progress -->`
   b. Announce: "Working on: ## {heading}"
   c. Read the section body for implementation details
   d. Implement the section (write code, run tests)
   e. Update section status to `done`: update `<!-- section:meta status=done -->`
   f. Report what was accomplished
5. After completing a section, commit and move to the next

## Rules

- Focus on one section at a time
- Do not modify code related to other sections
- If you hit ambiguity, ask the user instead of guessing
- Commit after each section
- Always update the plan file with section status changes — this is how the companion app tracks progress
