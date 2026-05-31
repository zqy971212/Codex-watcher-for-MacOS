#!/usr/bin/env zsh
set -euo pipefail

repo_dir="${0:A:h}"
label="com.qy.codex-notifier"
bin_dir="$HOME/.local/bin"
state_dir="$HOME/.local/state/codex-notifier"
launch_agent_dir="$HOME/Library/LaunchAgents"
plist_path="$launch_agent_dir/$label.plist"

mkdir -p "$bin_dir" "$state_dir" "$launch_agent_dir"

install -m 0755 "$repo_dir/bin/notify-done" "$bin_dir/notify-done"
install -m 0755 "$repo_dir/bin/codex-watcher" "$bin_dir/codex-watcher"
install -m 0644 "$repo_dir/launchagents/$label.plist" "$plist_path"

/bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$plist_path" >/dev/null 2>&1 || true
/bin/launchctl bootstrap "gui/$(/usr/bin/id -u)" "$plist_path"
/bin/launchctl enable "gui/$(/usr/bin/id -u)/$label"
/bin/launchctl kickstart -k "gui/$(/usr/bin/id -u)/$label"

print "Installed and started $label"

