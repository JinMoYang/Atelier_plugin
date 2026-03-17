---
name: plan
description: Create or view the Atelier plan for this conversation
---

# /atelier:plan

Create a plan for the current conversation, or show the existing plan.

## If no plan exists

Interview the user before writing any headings:

1. Ask 3-5 targeted clarifying questions about the most ambiguous parts of what they want
2. If a question can be answered by exploring the codebase, explore first instead of asking
3. Walk through design branches: dependencies, edge cases, scope
4. Only after thorough understanding, say "I have enough context to draft the plan"
5. Write ## headings with one-sentence descriptions into the shared doc

## If a plan already exists

Display the current plan sections with their status:
- ○ pending
- ● in_progress
- ✓ done
- ⊘ skipped

Ask the user what they'd like to do: edit sections, elaborate, or execute.
