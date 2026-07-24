#!/bin/bash
# GLI Auto-Push — run once in Terminal, auto-pushes on every file change
REPO="/Users/daviddettmer/Desktop/Database/Great Lakes Invitational"
WATCH="$REPO/index.html"
LAST=$(md5 -q "$WATCH" 2>/dev/null)

echo "👀 Watching for changes... (Ctrl+C to stop)"

while true; do
  CURRENT=$(md5 -q "$WATCH" 2>/dev/null)
  if [ "$CURRENT" != "$LAST" ]; then
    LAST="$CURRENT"
    cd "$REPO"
    git add index.html manifest.json 404.html .nojekyll login-bg.jpg 2>/dev/null
    MSG="Auto-push $(date '+%b %d %H:%M')"
    git commit -m "$MSG" 2>/dev/null && git push origin main && echo "✅ Pushed: $MSG"
  fi
  sleep 4
done
