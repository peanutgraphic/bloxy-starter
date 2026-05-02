#!/usr/bin/env bash
# BLOXY starter rollback script — restores the previous bundle.
#
# Reads .deploy-previous/ to find the last-known-good release and rsyncs
# it back into place. Run automatically by deploy.sh on health-check
# failure; can also be run manually.
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${DEPLOY_DIR}"

PREVIOUS_BUNDLE_DIR=".deploy-previous"
if [ ! -d "${PREVIOUS_BUNDLE_DIR}" ]; then
    echo "!! No previous bundle to roll back to (.deploy-previous missing)."
    exit 1
fi

php artisan down --retry=15 || true

rsync -a --delete \
    --exclude='.git' \
    --exclude='storage' \
    --exclude='.env' \
    --exclude='.deploy-previous' \
    --exclude='.deploy-incoming' \
    --exclude='.deploy-stage' \
    "${PREVIOUS_BUNDLE_DIR}/" ./

php artisan migrate --force
php artisan config:cache
php artisan up

echo "==> Rollback complete."
