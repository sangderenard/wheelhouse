#!/usr/bin/env bash
echo "Updating all submodules recursively..."

# Update submodules
git submodule update --remote --recursive

# Stage updated submodules
git add .

# Check if any changes occurred
if [[ $(git status --porcelain) ]]; then
    git commit -m "Updated submodules to latest commits"
    git push origin main
    echo "Submodules updated and pushed successfully."
else
    echo "No changes detected in submodules."
fi
