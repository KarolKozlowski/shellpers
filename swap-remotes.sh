#!/bin/bash
set -e  # Exit on error

echo "Debug: git remote output:"
git remote

# Check remotes exist (word match, ignores whitespace)
if ! git remote | grep -qw '^origin$' || ! git remote | grep -qw '^dotnot$'; then
  echo "ERROR: missing origin or dotnot remote"
  exit 1
fi

# Confirm origin is GitHub
origin_url=$(git remote get-url origin)
if [[ ! "$origin_url" =~ github ]]; then
  echo "ERROR: origin not GitHub: $origin_url"
  exit 1
fi

dotnot_url=$(git remote get-url dotnot)
current_branch=$(git branch --show-current)
echo "✅ Swapping origin<->dotnot"
echo "  origin  → github:  $origin_url"
echo "  dotnot  → origin:  $dotnot_url"
echo "  branch: $current_branch"

git remote rename origin github
git remote rename dotnot origin
git remote prune github origin 2>/dev/null || true

git branch --set-upstream-to="origin/$current_branch"

echo "✅ Complete!"
echo "Final remotes:"
git remote -v
echo "Tracking:"
git branch -vv | head -1

