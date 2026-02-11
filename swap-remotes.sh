#!/bin/bash
set -e  # Exit on error

# Check if both remotes exist (literal grep)
if ! git remote | grep -F '^origin$' >/dev/null || ! git remote | grep -F '^dotnot$' >/dev/null; then
  echo "ERROR: missing origin or dotnot remote"
  exit 1
fi

# Check if origin points to GitHub
origin_url=$(git remote get-url origin 2>/dev/null || true)
if [[ ! "$origin_url" =~ github ]]; then
  echo "ERROR: origin not GitHub ($origin_url)"
  exit 1
fi

current_branch=$(git branch --show-current)
echo "Swapping origin<->dotnot (origin: $origin_url, branch: $current_branch)"

git remote rename origin github
git remote rename dotnot origin
git remote prune github origin 2>/dev/null || true

# Set upstream for current branch
git branch --set-upstream-to="origin/$current_branch"

echo "✅ Done!"
echo "Remotes:"
git remote -v | head -4
echo "Tracking:"
git branch -vv | grep -F '*' | awk '{print $1, $4}'

