---
name: status
description: Show current Atelier plan status
---

# /atelier:status

Display the current plan state in a compact format:

```
Plan: [project name]
Phase: running | paused | done
Round: 3/10

○ Data ingestion          (pending)
● Schema validation       (in_progress, round 3)
✓ API endpoints           (done, round 2)
⊘ Load testing            (skipped)
```

Read the plan state from the ATELIER_PLAN_STATE context block or from the shared doc file.
