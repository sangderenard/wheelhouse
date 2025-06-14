#!/usr/bin/env bash
BRANCH="${1:-main}"
echo "Updating all submodules recursively on branch '$BRANCH'..."

# Update submodules
git submodule update --remote --recursive

# Stage updated submodules
git add .

# Check if any changes occurred
if [[ $(git status --porcelain) ]]; then
    git commit -m "Updated submodules to latest commits"
    git push origin "$BRANCH"
    echo "Submodules updated and pushed successfully to '$BRANCH'."
else
    echo "No changes detected in submodules."
fi
