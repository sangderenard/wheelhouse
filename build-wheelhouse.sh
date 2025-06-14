#!/usr/bin/env bash
# Build a small wheelhouse based on requirements.txt and integrate with lfsavoider
set -euo pipefail

# Load lfsavoider configuration if present
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
if [ -f "$SCRIPT_DIR/lfsavoider.config.sh" ]; then
  source "$SCRIPT_DIR/lfsavoider.config.sh"
fi

WHEELHOUSE_DIR=${1:-"wheelhouse"}
REQ_FILE=${2:-"requirements.txt"}
PYTAG="cp312"
LINUX_PLATFORM="manylinux_2_28_x86_64"
WIN_PLATFORM="win_amd64"
mkdir -p "$WHEELHOUSE_DIR/wheels/linux/$PYTAG" "$WHEELHOUSE_DIR/wheels/windows/$PYTAG"
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  echo "Downloading $pkg"
  pip download "$pkg" \
    --python-version 312 \
    --only-binary=:all: \
    --platform "$WIN_PLATFORM" \
    --dest "$WHEELHOUSE_DIR/wheels/windows/$PYTAG"
  pip download "$pkg" \
    --python-version 312 \
    --only-binary=:all: \
    --platform "$LINUX_PLATFORM" \
    --dest "$WHEELHOUSE_DIR/wheels/linux/$PYTAG"
done < "$REQ_FILE"
find "$WHEELHOUSE_DIR" -name '*.whl' -print0 | sort -z | xargs -0 sha256sum > "$WHEELHOUSE_DIR/SHA256SUMS.txt"
echo "Wheelhouse written to $WHEELHOUSE_DIR"

## Prevent accidental Git LFS usage by installing guard hooks
# Look for lfsavoider submodule in possible locations
LFSAV_DIR=""
if [ -d "$SCRIPT_DIR/lfsavoider" ]; then
  LFSAV_DIR="$SCRIPT_DIR/lfsavoider"
elif [ -d "$SCRIPT_DIR/../lfsavoider" ]; then
  LFSAV_DIR="$SCRIPT_DIR/../lfsavoider"
fi
if [ -n "$LFSAV_DIR" ]; then
  echo "Installing LFS guard hooks from lfsavoider submodule"
  "$LFSAV_DIR/install-lfs-guard.sh" "$PWD"
  cp "$LFSAV_DIR/.lfs.guard" .
fi

## Upload wheels to GCS using lfsavoider if submodule and config are present
if [ -n "$LFSAV_DIR" ] && [ -n "${GCS_BUCKET:-}" ] && [ -n "${GCS_KEY_PATH:-}" ]; then
  echo "Uploading wheels to GCS via lfsavoider submodule"
  "$LFSAV_DIR/upload-lfs-to-gcs.sh" "$WHEELHOUSE_DIR" "$GCS_BUCKET" "$GCS_KEY_PATH"
fi
