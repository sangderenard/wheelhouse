#!/usr/bin/env pwsh
param(
    [string]$Branch = 'main'
)

Write-Host "Updating all submodules recursively on branch '$Branch'..."

# Update submodules to latest remote commit
git submodule update --remote --recursive

# Stage updated submodules
git add .

# Commit changes if there are any updates
if ((git status --porcelain) -ne "") {
    git commit -m "Updated submodules to latest commits"
    git push origin $Branch
    Write-Host "Submodules updated and pushed successfully to '$Branch'."
} else {
    Write-Host "No changes detected in submodules."
}
