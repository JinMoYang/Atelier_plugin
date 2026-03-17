#!/usr/bin/env bash
# Load Atelier plan state from backend
# Used by SessionStart and PreCompact hooks

BACKEND="${ATELIER_BACKEND_URL:-http://localhost:8000}"
WORKSPACE_ID="${ATELIER_WORKSPACE_ID:-}"

if [ -z "$WORKSPACE_ID" ]; then
  WORKSPACE_ID=$(basename "$(pwd)")
fi

RESPONSE=$(curl -s --connect-timeout 2 "${BACKEND}/api/plan/by-workspace/${WORKSPACE_ID}" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
  exit 0
fi

echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    sections = data.get('sections', [])
    if not sections:
        sys.exit(0)
    meta = data.get('meta', {})
    print('ATELIER_PLAN_STATE:')
    print(f'Conversation: {data.get(\"conversation_id\", \"?\")}')
    print(f'Workspace: {data.get(\"workspace_id\", \"?\")}')
    if meta:
        print(f'Phase: {meta.get(\"phase\", \"unknown\")} | Round: {meta.get(\"round\", 0)}/{meta.get(\"max_rounds\", 0)}')
    print()
    for s in sections:
        icon = {'done': '✓', 'in_progress': '●', 'skipped': '⊘'}.get(s['status'], '○')
        extra = f' (round {s[\"round\"]})' if s['round'] > 0 else ''
        print(f'{icon} {s[\"heading\"]}{extra}')
        if s.get('body'):
            for line in s['body'].split(chr(10))[:3]:
                if line.strip():
                    print(f'  {line.strip()}')
    print()
except Exception:
    pass
" 2>/dev/null
