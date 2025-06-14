# Minimal Wheelhouse Builder

This folder is a self‑contained template for creating a tiny Git‑LFS
wheelhouse. It can be extracted to its own repository and used as a
submodule or standalone project.

1. Edit `requirements.txt` with the packages you need.
2. Run `./build-wheelhouse.sh` (or `powershell -File build-wheelhouse.ps1`).
3. Run `lfsavoider/install-lfs-guard.sh .` to install the `.lfs.guard`
   pre-commit hook, then commit the resulting `wheelhouse/` directory
   normally **without** Git LFS.

The scripts download binary wheels for Windows and manylinux using
`pip download` and compute a `SHA256SUMS.txt` manifest. No network access
is required for installation once the wheelhouse is prepared.
