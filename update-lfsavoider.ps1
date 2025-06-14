#!/usr/bin/env pwsh
Write-Host "Updating all submodules recursively..."

# Update submodules to latest remote commit
git submodule update --remote --recursive

# Stage updated submodules
git add .

# Commit changes if there are any updates
if ((git status --porcelain) -ne "") {
    git commit -m "Updated submodules to latest commits"
    git push origin main
    Write-Host "Submodules updated and pushed successfully."
} else {
    Write-Host "No changes detected in submodules."
}
