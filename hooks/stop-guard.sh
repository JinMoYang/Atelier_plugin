#!/usr/bin/env bash
# Check for pending plan sections before Claude Code stops
# Reads the plan file directly — no backend needed

PLAN_FILE=""
for f in doc-*.md plan.md; do
  if [ -f "notes/$f" ]; then
    PLAN_FILE="notes/$f"
    break
  fi
done

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
import re, sys
try:
    with open('$PLAN_FILE', 'r') as f:
        content = f.read()
    pending = []
    for m in re.finditer(r'^##\s+(.+)$', content, re.MULTILINE):
        heading = re.sub(r'\s*\[done\]\s*', '', m.group(1), flags=re.IGNORECASE).strip()
        pos = m.end()
        rest = content[pos:pos+200]
        sm = re.search(r'<!--\s*section:meta\s+(.*?)\s*-->', rest)
        status = 'pending'
        if sm:
            kvs = dict(re.findall(r'(\w+)=([\w./-]+)', sm.group(1)))
            status = kvs.get('status', 'pending')
        elif '[done]' in m.group(1).lower():
            status = 'done'
        if status == 'pending':
            pending.append(heading)
    if pending:
        names = ', '.join(pending[:3])
        more = f' (+{len(pending)-3} more)' if len(pending) > 3 else ''
        print(f'Note: {len(pending)} pending plan section(s): {names}{more}')
except Exception:
    pass
" 2>/dev/null
