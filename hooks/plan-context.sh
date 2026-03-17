#!/usr/bin/env bash
# Load Atelier plan state from the local plan file
# Used by SessionStart and PreCompact hooks
#
# Detection order:
# 1. File with <!-- plan:meta --> marker (active plan)
# 2. .atelier config file pointing to plan path
# 3. Most recent file with ## headings (asks user to confirm)

PLAN_FILE=""

# Strategy 1: Find file with plan:meta marker
find_meta_plan() {
  local dirs=("." "notes" "docs/superpowers/plans" "docs/superpowers/specs" "docs")
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || continue
    local found
    found=$(grep -rl '<!-- plan:meta' "$dir" --include='*.md' 2>/dev/null | head -1)
    if [ -n "$found" ]; then
      echo "$found"
      return
    fi
  done
}

# Strategy 2: Read from .atelier config
read_config_plan() {
  if [ -f ".atelier" ]; then
    local path
    path=$(grep '^plan:' .atelier 2>/dev/null | sed 's/^plan:[[:space:]]*//')
    if [ -n "$path" ] && [ -f "$path" ]; then
      echo "$path"
    fi
  fi
}

# Strategy 3: Most recent .md file with ## headings
find_recent_plan() {
  local dirs=("docs/superpowers/plans" "notes" "docs" ".")
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || continue
    local found
    found=$(grep -rl '^## ' "$dir" --include='*.md' 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
    if [ -n "$found" ]; then
      echo "$found"
      return
    fi
  done
}

# Try each strategy in order
PLAN_FILE=$(find_meta_plan)
if [ -z "$PLAN_FILE" ]; then
  PLAN_FILE=$(read_config_plan)
fi
if [ -z "$PLAN_FILE" ]; then
  PLAN_FILE=$(find_recent_plan)
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
