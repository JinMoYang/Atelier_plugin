#!/usr/bin/env bash
# Load Atelier plan state from the local plan file
# Used by SessionStart and PreCompact hooks
# No backend connection needed — reads the file directly

# Find plan file in current project
PLAN_FILE=""
for f in doc-*.md plan.md; do
  if [ -f "notes/$f" ]; then
    PLAN_FILE="notes/$f"
    break
  fi
done

# Also check workspace root
if [ -z "$PLAN_FILE" ]; then
  for f in doc-*.md plan.md; do
    if [ -f "$f" ]; then
      PLAN_FILE="$f"
      break
    fi
  done
fi

if [ -z "$PLAN_FILE" ] || [ ! -f "$PLAN_FILE" ]; then
  exit 0
fi

python3 -c "
import sys, re

try:
    with open('$PLAN_FILE', 'r') as f:
        content = f.read()

    # Parse plan meta
    meta_match = re.search(r'<!--\s*plan:meta\s+(.*?)\s*-->', content)
    meta = {}
    if meta_match:
        for m in re.finditer(r'(\w+)=([\w./-]+)', meta_match.group(1)):
            meta[m.group(1)] = m.group(2)

    # Parse sections
    sections = []
    for m in re.finditer(r'^##\s+(.+)$', content, re.MULTILINE):
        heading = re.sub(r'\s*\[done\]\s*', '', m.group(1), flags=re.IGNORECASE).strip()
        # Look for section meta on next line
        pos = m.end()
        rest = content[pos:pos+200]
        sm = re.search(r'<!--\s*section:meta\s+(.*?)\s*-->', rest)
        status = 'pending'
        rnd = '0'
        if sm:
            kvs = dict(re.findall(r'(\w+)=([\w./-]+)', sm.group(1)))
            status = kvs.get('status', 'pending')
            rnd = kvs.get('round', '0')
        elif '[done]' in m.group(1).lower():
            status = 'done'
        sections.append((heading, status, rnd))

    if not sections:
        sys.exit(0)

    print('ATELIER_PLAN_STATE:')
    if meta:
        print(f'Phase: {meta.get(\"phase\", \"unknown\")} | Round: {meta.get(\"round\", \"0\")}/{meta.get(\"max_rounds\", \"0\")}')
    print(f'File: $PLAN_FILE')
    print()
    for heading, status, rnd in sections:
        icon = {'done': '✓', 'in_progress': '●', 'skipped': '⊘'}.get(status, '○')
        extra = f' (round {rnd})' if rnd != '0' else ''
        print(f'{icon} {heading}{extra}')
    print()
except Exception:
    pass
" 2>/dev/null
