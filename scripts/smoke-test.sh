#!/usr/bin/env bash
#
# bloxy-starter smoke test — single source of truth for CI and local dev.
#
# Runs `composer create-project peanutgraphic/bloxy-starter` against a
# tmpdir using the path repo at packages/starter/, runs the Pest suite,
# and reports pass/fail. Used by .github/workflows/ci.yml and
# directly by humans.
#
# Usage:
#   ./packages/starter/scripts/smoke-test.sh
#   SMOKE_KEEP=1 ./packages/starter/scripts/smoke-test.sh   # don't rm tmpdir
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STARTER_DIR="${REPO_ROOT}/packages/starter"
TMPDIR_BASE="${TMPDIR:-/tmp}"
SMOKE_DIR="${TMPDIR_BASE}/bloxy-starter-smoke-$$"

cleanup() {
  if [ -z "${SMOKE_KEEP:-}" ]; then
    rm -rf "${SMOKE_DIR}"
  else
    echo "Keeping ${SMOKE_DIR} (SMOKE_KEEP=1)"
  fi
}
trap cleanup EXIT

mkdir -p "${SMOKE_DIR}"
cd "${SMOKE_DIR}"

echo "==> composer create-project peanutgraphic/bloxy-starter (path repo, no scripts)"
composer create-project \
  --repository="$(printf '{"type":"path","url":"%s","options":{"symlink":false}}' "${STARTER_DIR}")" \
  --stability=dev \
  --prefer-source \
  --no-scripts \
  --no-install \
  --no-interaction \
  peanutgraphic/bloxy-starter app

cd app

echo "==> Rewriting bloxy-* path repos to absolute paths (mirrored relative paths broke)"
# Drop the relative path repos from the mirrored composer.json and re-add
# them with absolute paths pointing back at the BLOXY monorepo. This is
# the local-dev override; the published-Packagist flow won't have a
# repositories block at all.
python3 - "${REPO_ROOT}" <<'PY'
import json, sys, pathlib
repo_root = pathlib.Path(sys.argv[1])
cj_path = pathlib.Path('composer.json')
cj = json.loads(cj_path.read_text())
cj['repositories'] = [
    {'type': 'path', 'url': str(repo_root / 'packages' / pkg), 'options': {'symlink': True}}
    for pkg in ('core-php', 'files-php', 'ui-php', 'crypto-php', 'passkey-php')
]
cj_path.write_text(json.dumps(cj, indent=4) + '\n')
PY

echo "==> composer install"
composer install --no-interaction --no-progress

echo "==> Copying .env + key:generate"
cp .env.example .env
php artisan key:generate --ansi

echo "==> Configuring SQLite + stubbing required env vars (before migrate)"
touch database/database.sqlite
# Use perl -i for cross-platform sed-i compatibility (BSD vs GNU)
perl -i -pe 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
perl -i -pe "s|^DB_DATABASE=.*|DB_DATABASE=$(pwd)/database/database.sqlite|" .env
# bloxy-passkey recovery JWT key — required (≥32 bytes); empty value would
# crash the recovery routes at first request.
echo "BLOXY_PASSKEY_RECOVERY_JWT_KEY=$(openssl rand -hex 32)" >> .env

echo "==> Running migrations"
php artisan migrate --graceful --force

echo "==> Publishing bloxy-* configs"
php artisan vendor:publish --tag=bloxy-config         --force --ansi || true
php artisan vendor:publish --tag=bloxy-files-config   --force --ansi || true
php artisan vendor:publish --tag=bloxy-ui-config      --force --ansi || true
php artisan vendor:publish --tag=bloxy-ui-tailwind    --force --ansi || true
php artisan vendor:publish --tag=bloxy-crypto-config  --force --ansi || true
php artisan vendor:publish --tag=bloxy-passkey-config --force --ansi || true

echo "==> Verifying Laravel boots"
php artisan --version

echo "==> Rewriting bloxy-* npm deps to file: references (registry resolution awaits M3)"
python3 - "${REPO_ROOT}" <<'PY'
import json, sys, pathlib
repo_root = pathlib.Path(sys.argv[1])
pj_path = pathlib.Path('package.json')
pj = json.loads(pj_path.read_text())
mapping = {
    '@peanutgraphic/bloxy-ui':      repo_root / 'packages' / 'core-js',
    '@peanutgraphic/bloxy-crypto':  repo_root / 'packages' / 'crypto-js',
    '@peanutgraphic/bloxy-passkey': repo_root / 'packages' / 'passkey-js',
}
deps = pj.setdefault('dependencies', {})
for name, path in mapping.items():
    if name in deps:
        deps[name] = f'file:{path}'
pj_path.write_text(json.dumps(pj, indent=4) + '\n')
PY

echo "==> Ensuring bloxy-ui (core-js) dist is built"
( cd "${REPO_ROOT}/packages/core-js" && [ -d dist ] || npm run build 2>&1 | tail -5 )

echo "==> npm install (smoke app)"
npm install --legacy-peer-deps --no-audit --no-fund 2>&1 | tail -8

echo "==> npm run build (produces public/build/manifest.json for Inertia tests)"
npm run build 2>&1 | tail -8

if [ "${SMOKE_VARIANT:-default}" = "passkey-only" ]; then
  echo "==> SMOKE_VARIANT=passkey-only — running bloxy:passkey-only swap"
  php artisan bloxy:passkey-only --no-interaction

  echo "==> Re-migrating (passkey-only adds make_users_password_nullable)"
  php artisan migrate --graceful --force

  echo "==> Re-building Vite manifest with new passkey pages"
  npm run build 2>&1 | tail -8
fi

echo "==> Running starter Pest suite"
vendor/bin/pest --colors=always

echo "==> Smoke test PASSED (variant=${SMOKE_VARIANT:-default})"
