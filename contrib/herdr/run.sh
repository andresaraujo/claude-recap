#!/bin/sh
# herdr action → bin/recap. Shows a toast while the recap is prepared (~10 s), then the result.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
HERDR="${HERDR_BIN_PATH:-herdr}"
RECAP="${HERDR_PLUGIN_ROOT:-$(cd "$(dirname "$0")" && pwd)}/../../bin/recap"

case "${1:-play}" in
  stop) python3 "$RECAP" --stop ;;
  play)
    # the pane the user is looking at; plugin actions may not carry HERDR_PANE_ID
    PANE=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("focused_pane_id",""))
except Exception: pass' 2>/dev/null)
    PANE=${PANE:-${HERDR_PANE_ID:-}}
    "$HERDR" notification show "Recap" --body "Preparing recap…" --sound none >/dev/null 2>&1
    if out=$(python3 "$RECAP" ${PANE:+--pane "$PANE"} 2>&1); then
      "$HERDR" notification show "Recap" --body "$out" --sound none >/dev/null 2>&1
    else
      "$HERDR" notification show "Recap failed" --body "$out" --sound none >/dev/null 2>&1
    fi ;;
esac
