#!/usr/bin/env zsh
set -euo pipefail

label="com.qy.codex-notifier"
plist_path="$HOME/Library/LaunchAgents/$label.plist"

/bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$plist_path" >/dev/null 2>&1 || true
rm -f "$plist_path"

print "Uninstalled $label"

