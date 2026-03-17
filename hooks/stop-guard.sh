#!/usr/bin/env bash
# Check for pending plan sections before Claude Code stops

BACKEND="${ATELIER_BACKEND_URL:-http://localhost:8000}"
WORKSPACE_ID="${ATELIER_WORKSPACE_ID:-$(basename "$(pwd)")}"

PENDING=$(curl -s --connect-timeout 2 "${BACKEND}/api/plan/by-workspace/${WORKSPACE_ID}" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    pending = [s for s in data.get('sections', []) if s['status'] == 'pending']
    if pending:
        names = ', '.join(s['heading'] for s in pending[:3])
        more = f' (+{len(pending)-3} more)' if len(pending) > 3 else ''
        print(f'Note: {len(pending)} pending plan section(s): {names}{more}')
except Exception:
    pass
" 2>/dev/null)

if [ -n "$PENDING" ]; then
  echo "$PENDING"
fi
