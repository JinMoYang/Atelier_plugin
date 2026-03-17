---
name: go
description: Execute pending plan sections (or specific ones)
---

# /go [section names...]

Start executing plan sections.

## Usage

- `/go` — execute all pending sections in priority order
- `/go "Data ingestion"` — execute only that section
- `/go "Data ingestion" "Validation"` — execute those two sections

## Behavior

1. Read the current plan state from the ATELIER_PLAN_STATE context block
2. Identify target sections (all pending, or the named ones)
3. For each target section in priority order:
   a. Announce: "Working on: ## {heading}"
   b. Read the section body for implementation details
   c. Implement the section (write code, run tests)
   d. When done, report what was accomplished
4. After completing a section, move to the next

## Rules

- Focus on one section at a time
- Do not modify code related to other sections
- If you hit ambiguity, ask the user instead of guessing
- Commit after each section
