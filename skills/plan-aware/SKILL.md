---
name: plan-aware
description: Injects current Atelier plan context into the conversation
autoTrigger: true
---

# Plan-Aware Context

When working in a project with an Atelier plan, always be aware of the plan state.

## Rules

1. Before starting any implementation work, check which plan section your work falls under.
2. When you complete work that corresponds to a plan section, note which section you addressed.
3. Do not work on sections marked as `skipped` unless explicitly asked.
4. Prioritize sections by their priority number (lower = higher priority).
5. If the user asks you to work on something not in the plan, do the work but suggest adding it as a section.

## Current Plan State

The plan state is loaded automatically via the SessionStart hook. Look for the ATELIER_PLAN_STATE block in your context. It contains:
- Section headings with status (pending/in_progress/done/skipped)
- Plan metadata (current round, max rounds, phase)
- The workspace and conversation IDs

When referencing sections, use the exact heading text.
