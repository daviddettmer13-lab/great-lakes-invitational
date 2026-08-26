#!/bin/bash
# GLI Backup — snapshot the live Firebase database to a timestamped JSON file.
# Run any time:  ./backup.sh          (e.g. after the draft, between rounds)
REPO="/Users/daviddettmer/Desktop/Database/Great Lakes Invitational"
DB="https://gli-2026-default-rtdb.firebaseio.com/gli26.json"
OUT="$REPO/gli-backup-$(date +%Y%m%d-%H%M%S).json"

curl -s --max-time 60 "$DB" -o "$OUT" || { echo "❌ Could not reach Firebase"; exit 1; }

# Refuse to keep an empty or malformed snapshot
if ! python3 -c "import json,sys; d=json.load(open('$OUT')); sys.exit(0 if d and d.get('players') else 1)" 2>/dev/null; then
  echo "❌ Backup looked empty or invalid — deleting, nothing was saved"
  rm -f "$OUT"; exit 1
fi

python3 - "$OUT" << 'PY'
import json, sys, os
f = sys.argv[1]
d = json.load(open(f))
p = d.get('players', {})
teams = {}
for v in p.values():
    teams[v.get('team', '?')] = teams.get(v.get('team', '?'), 0) + 1
print("✅ Saved %s (%.1f KB)" % (os.path.basename(f), os.path.getsize(f) / 1024))
print("   players: %d   teams: %s" % (len(p), teams))
for k in ('matchups', 'scores', 'ctp', 'completedMatches', 'bets', 'messages'):
    v = d.get(k)
    print("   %-17s %s" % (k, 'empty' if not v else '%d entries' % len(v)))
PY
