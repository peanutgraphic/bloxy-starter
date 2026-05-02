# {{ APP_NAME }} — Project Instructions

> Edit this file after `composer create-project peanutgraphic/bloxy-starter`.
> The `{{ APP_NAME }}` and similar tokens below are placeholders.

## What this is

{{ APP_NAME }} is a vertical-SaaS app built on the BLOXY meta-framework (Laravel + Inertia + React + Tailwind 4). It uses the operator-cockpit + customer-portal shape with `bloxy-core` (audit log, RBAC, encryption casts) and `bloxy-files` (file storage) pre-wired.

(Edit this section to describe what your app actually does.)

## Stack

- PHP 8.3+, Laravel 12+
- Inertia.js + React 18+ + TypeScript 5+
- TailwindCSS 4 (with the bloxy-ui Tailwind preset)
- PostgreSQL 16 (production); SQLite (local dev + testing)
- BLOXY packages: `bloxy-core`, `bloxy-files`, `bloxy-ui` (and optionally `bloxy-crypto`, `bloxy-passkey` once those ship)

## Development

```bash
# Local dev
npm run dev    # Vite + Tailwind watch
php artisan serve

# Tests
php artisan test

# Audit-coverage check (gates CI)
php artisan bloxy:audit-coverage
```

## Deployment

```bash
# One-time SSH key add
ssh-add ~/.ssh/id_ed25519

# Deploy (configure HOST + DIR + HEALTH_URL in scripts/deploy.sh first)
bash scripts/deploy.sh
```

The deploy script is a bundle-rsync pipeline. It builds locally, uploads a tarball, extracts on the remote with `rsync --delete --exclude='.git' --exclude='storage' --exclude='.env'`, runs migrations, caches, restarts the queue, and health-checks. Auto-rolls back on health-check failure via `scripts/rollback.sh`.

## BLOXY conventions

This app follows BLOXY's "compliance-shaped" patterns by default:

- **Audit log:** every state-changing route is under the `bloxy.audit` middleware. Run `php artisan bloxy:audit-coverage` to enforce — CI fails on uncovered routes. To exclude vendor-default routes (`storage/{path}`, Sanctum CSRF, etc.), add patterns to `bloxy.audit.coverage_excludes`.
- **Audit chain (opt-in):** for compliance-sensitive apps, enable `BLOXY_AUDIT_SIGNED_CHAIN=true` and run `php artisan bloxy:audit-anchor --reason "chain enablement"` once. Then schedule `php artisan bloxy:audit-verify-chain` hourly.
- **Redactor:** auto-wired to Sentry + Monolog. PII fields (`password`, `token`, `secret`, `authorization`, etc.) are redacted before they reach the observability sinks. Disable per-channel via `BLOXY_REDACTOR_AUTO_WIRE_*` env vars if your stack needs custom wiring.
- **Encrypted-at-rest:** sensitive fields use `Bloxy\Core\Casts\ServerEncryptedString` or `ServerEncryptedJson` casts. (For zero-knowledge encryption, switch to `Bloxy\Crypto\EnvelopeEncrypted` once `bloxy-crypto` ships in B1.8.0.)
- **RBAC:** routes protected via `$user->bloxyCan('permission', $resource)` on the `Authorizable` trait. Use `bloxyAssignRole`, `bloxyRevokeRole`, `bloxyHasRole` for grants.
- **File storage:** uploads via `app(FileStorage::class)->storeUpload($upload, $owner, $meta)`. Downloads via `download($file, ['reason' => 'user-playback'])` — stream + audit-log integrated.

## Customizing

Replace these placeholders in this file: `{{ APP_NAME }}`. Add app-specific sections for:

- Domain models + their relationships
- Key URLs (production, staging)
- Operational runbooks (incident response, rollback procedures)
- Team conventions (code style, PR process, deployment cadence)

## BLOXY references

- BLOXY repo: https://github.com/peanutgraphic/bloxy
- Stability promise: `vendor/peanutgraphic/bloxy-core/docs/stability.md` (or the BLOXY repo's `docs/stability.md` for the full per-primitive table)
- Upgrading guide: `vendor/peanutgraphic/bloxy-core/docs/upgrading.md`
- Audit-log docs: `vendor/peanutgraphic/bloxy-core/docs/audit-log.md`
- UI foundations: `vendor/peanutgraphic/bloxy-ui/docs/ui-foundations.md`
