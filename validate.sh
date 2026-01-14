#!/bin/bash
set -e

echo "🔍 Fetching all branches..."
git fetch origin '+refs/heads/*:refs/remotes/origin/*' --quiet

# Get remote branches
BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin)

PATH_BRANCH=$(echo "$BRANCHES" | grep -i 'path' | head -n 1 || true)
TRUTH_BRANCH=$(echo "$BRANCHES" | grep -i 'truth' | head -n 1 || true)

if [ -z "$PATH_BRANCH" ]; then
  echo "❌ No branch containing 'path' found"
  exit 1
fi

if [ -z "$TRUTH_BRANCH" ]; then
  echo "❌ No branch containing 'truth' found"
  exit 1
fi

echo "✅ Found branches:"
echo "   PATH  → $PATH_BRANCH"
echo "   TRUTH → $TRUTH_BRANCH"

echo "🔁 Checking out main..."
git checkout main >/dev/null 2>&1

# Check files in main (case-insensitive)
FILES=$(ls | tr '[:upper:]' '[:lower:]')

echo "$FILES" | grep -qx "path.txt" || {
  echo "❌ path.txt not found in main"
  exit 1
}

echo "$FILES" | grep -qx "truth.txt" || {
  echo "❌ truth.txt not found in main"
  exit 1
}

echo "📦 Required files exist in main"

# Check if branches are merged into main (robust way)
MERGED_BRANCHES=$(git branch -r --merged origin/main | tr '[:upper:]' '[:lower:]')

echo "$MERGED_BRANCHES" | grep -q "$(echo "$PATH_BRANCH" | tr '[:upper:]' '[:lower:]')" || {
  echo "❌ Path branch is NOT merged into main"
  exit 1
}

echo "$MERGED_BRANCHES" | grep -q "$(echo "$TRUTH_BRANCH" | tr '[:upper:]' '[:lower:]')" || {
  echo "❌ Truth branch is NOT merged into main"
  exit 1
}

echo "🎉 Level Passed — Both branches merged and files present!"
