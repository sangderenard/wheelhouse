# Minimal Wheelhouse Builder

This folder is a self‑contained template for creating a tiny Git‑LFS
wheelhouse. It can be extracted to its own repository and used as a
submodule or standalone project.

1. Edit `requirements.txt` with the packages you need.
2. Run `./build-wheelhouse.sh` (or `powershell -File build-wheelhouse.ps1`).
3. Run `lfsavoider/install-lfs-guard.sh .` to install the `.lfs.guard`
   pre-commit hook, then commit the resulting `wheelhouse/` directory
   normally **without** Git LFS.
4. Use `./update-lfsavoider.sh [branch]` (or `pwsh update-lfsavoider.ps1 -Branch branch`)
   to update the `lfsavoider` submodule and push to the specified branch
   (defaults to `main`).

The scripts download binary wheels for Windows and manylinux using
`pip download` and compute a `SHA256SUMS.txt` manifest. No network access
is required for installation once the wheelhouse is prepared.
