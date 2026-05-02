#!/usr/bin/env bash
#
# BLOXY starter deploy script — bundle-rsync pipeline patterned on HULLABALOO.
#
# Builds a curated tarball locally, uploads to prod, rsyncs onto the live
# directory with --delete --exclude='.git' --exclude='storage' --exclude='.env',
# runs migrations, caches, restarts the queue worker, and health-checks.
# Auto-rolls back on health-check failure.
#
# CONFIGURE these variables before first deploy.
set -euo pipefail

# ---- App-specific config (EDIT THESE) -------------------------------------
APP_NAME="${APP_NAME:-myapp}"
DEPLOY_HOST="${DEPLOY_HOST:-deploy@example.com}"
DEPLOY_DIR="${DEPLOY_DIR:-/var/www/myapp}"
HEALTH_URL="${HEALTH_URL:-https://example.com/health}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/id_ed25519}"
# ---------------------------------------------------------------------------

LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="${LOCAL_DIR}/storage/deploy"
BUNDLE_FILE="${BUNDLE_DIR}/${APP_NAME}-$(date +%Y%m%d-%H%M%S).tar.gz"
RELEASE_TAG="$(git -C "${LOCAL_DIR}" rev-parse --short HEAD 2>/dev/null || echo 'unknown')"

mkdir -p "${BUNDLE_DIR}"

echo "==> Building assets locally"
cd "${LOCAL_DIR}"
npm run build

echo "==> Creating deploy bundle (${BUNDLE_FILE})"
tar --exclude='./node_modules' \
    --exclude='./storage' \
    --exclude='./.git' \
    --exclude='./.env' \
    --exclude='./tests' \
    --exclude='./.github' \
    --exclude='./scripts/deploy*' \
    -czf "${BUNDLE_FILE}" .

echo "==> Uploading bundle to ${DEPLOY_HOST}:${DEPLOY_DIR}/.deploy-incoming/"
ssh -i "${SSH_KEY}" "${DEPLOY_HOST}" "mkdir -p ${DEPLOY_DIR}/.deploy-incoming"
scp -i "${SSH_KEY}" "${BUNDLE_FILE}" "${DEPLOY_HOST}:${DEPLOY_DIR}/.deploy-incoming/"

REMOTE_BUNDLE="${DEPLOY_DIR}/.deploy-incoming/$(basename "${BUNDLE_FILE}")"

echo "==> Releasing on remote (extract + rsync + migrate + cache + queue restart + health)"
ssh -i "${SSH_KEY}" "${DEPLOY_HOST}" bash -s <<EOF
set -euo pipefail
cd "${DEPLOY_DIR}"

# Snapshot current release for rollback
PREVIOUS_TAG=\$(cat .release-tag 2>/dev/null || echo 'none')
echo "Previous release: \$PREVIOUS_TAG"

# Move current snapshot to .deploy-previous before extracting new one
if [ -d .deploy-previous ]; then
    rm -rf .deploy-previous
fi
mkdir -p .deploy-previous
rsync -a --exclude='.git' --exclude='storage' --exclude='.env' \
    --exclude='.deploy-previous' --exclude='.deploy-incoming' \
    --exclude='.deploy-stage' \
    ./ .deploy-previous/

# Extract new bundle into a staging dir, then rsync onto the live tree
mkdir -p .deploy-stage
tar -xzf "${REMOTE_BUNDLE}" -C .deploy-stage

# Rsync, deleting stale files but excluding stateful dirs
rsync -a --delete \
    --exclude='.git' \
    --exclude='storage' \
    --exclude='.env' \
    --exclude='.deploy-previous' \
    --exclude='.deploy-incoming' \
    --exclude='.deploy-stage' \
    .deploy-stage/ ./

rm -rf .deploy-stage

# Mark release
echo "${RELEASE_TAG}" > .release-tag

# Maintenance window
php artisan down --retry=15 || true

# Migrate + cache
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Queue + horizon (if installed)
if [ -f /etc/supervisor/conf.d/${APP_NAME}-queue.conf ]; then
    sudo systemctl restart ${APP_NAME}-queue
fi

# Bring the app back up
php artisan up
EOF

echo "==> Health-check (${HEALTH_URL})"
sleep 3
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${HEALTH_URL}" || echo "000")

if [ "${HEALTH_STATUS}" != "200" ]; then
    echo "!! Health check failed (HTTP ${HEALTH_STATUS}). Rolling back."
    ssh -i "${SSH_KEY}" "${DEPLOY_HOST}" bash -s <<EOF
set -euo pipefail
cd "${DEPLOY_DIR}"
bash scripts/rollback.sh
EOF
    exit 1
fi

echo "==> Deploy ${RELEASE_TAG} complete and healthy."
