param(
  [string]$WheelhouseDir = "wheelhouse",
  [string]$Requirements = "requirements.txt"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptDir = Split-Path -Parent $PSCommandPath

# Load lfsavoider configuration if present (only GCS vars are used)
$GCS_BUCKET = ""
$GCS_KEY_PATH = ""
$configPath = Join-Path $ScriptDir 'lfsavoider.config.sh'
if (Test-Path $configPath) {
  Get-Content $configPath | ForEach-Object {
    if ($_ -match '^GCS_BUCKET="?(.*)"') { $GCS_BUCKET = $matches[1] }
    elseif ($_ -match '^GCS_KEY_PATH="?(.*)"') { $GCS_KEY_PATH = $matches[1] }
  }
}

$PyTag = "cp312"
$LinuxPlatform = "manylinux_2_28_x86_64"
$WinPlatform   = "win_amd64"
$linuxDir = Join-Path $WheelhouseDir "wheels/linux/$PyTag"
$winDir   = Join-Path $WheelhouseDir "wheels/windows/$PyTag"
New-Item -ItemType Directory -Path $linuxDir -Force | Out-Null
New-Item -ItemType Directory -Path $winDir -Force | Out-Null

Get-Content $Requirements | ForEach-Object {
  if (-not $_ -or $_.StartsWith('#')) { return }
  Write-Host "Downloading $_" -ForegroundColor Cyan
  pip download $_ `
    --python-version 312 `
    --only-binary=:all: `
    --platform $WinPlatform `
    --dest $winDir
  pip download $_ `
    --python-version 312 `
    --only-binary=:all: `
    --platform $LinuxPlatform `
    --dest $linuxDir
}

Get-ChildItem -Recurse -Filter *.whl -Path $WheelhouseDir | \
  Sort-Object FullName | \
  Get-FileHash -Algorithm SHA256 | \
  ForEach-Object { "$($_.Hash)  $($_.Path -replace '\\','/')" } | \
  Set-Content -Path (Join-Path $WheelhouseDir 'SHA256SUMS.txt')
Write-Host "Wheelhouse written to $WheelhouseDir" -ForegroundColor Green

# Prevent accidental Git LFS usage by installing guard hooks
$LFSAV_DIR = ""
if (Test-Path (Join-Path $ScriptDir 'lfsavoider')) {
  $LFSAV_DIR = Join-Path $ScriptDir 'lfsavoider'
} elseif (Test-Path (Join-Path $ScriptDir '..' 'lfsavoider')) {
  $LFSAV_DIR = Join-Path $ScriptDir '..' 'lfsavoider'
}
if ($LFSAV_DIR) {
  Write-Host "Installing LFS guard hooks from lfsavoider submodule"
  & bash (Join-Path $LFSAV_DIR 'install-lfs-guard.sh') $PWD
  Copy-Item (Join-Path $LFSAV_DIR '.lfs.guard') -Destination . -Force
}

# Upload wheels to GCS using lfsavoider if submodule and config are present
if ($LFSAV_DIR -and $GCS_BUCKET -and $GCS_KEY_PATH) {
  Write-Host "Uploading wheels to GCS via lfsavoider submodule"
  & bash (Join-Path $LFSAV_DIR 'upload-lfs-to-gcs.sh') $WheelhouseDir $GCS_BUCKET $GCS_KEY_PATH
}
