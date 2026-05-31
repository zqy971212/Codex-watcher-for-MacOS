#!/usr/bin/env zsh
set -euo pipefail

repo_dir="${0:A:h}"

scripts=(
  "$repo_dir/install.sh"
  "$repo_dir/uninstall.sh"
  "$repo_dir/bin/notify-done"
  "$repo_dir/bin/codex-watcher"
)

for script in "${scripts[@]}"; do
  if [[ ! -f "$script" ]]; then
    print -u2 "Missing script: $script"
    exit 1
  fi

  chmod 0755 "$script"
done

print "Executable permissions fixed."
