# LFS Avoider configuration for wheelhouse
# Define which folders contain artifacts and GCS settings.

# Folders to quarantine (relative to wheelhouse root)
TARGET_FOLDERS=("wheelhouse")

# Paths to purge from history, if any (relative to wheelhouse root)
PATHS_TO_PURGE=()

# Google Cloud Storage settings for uploading artifacts
gcs: you can specify these or leave empty to skip upload
GCS_BUCKET=""
GCS_KEY_PATH=""
