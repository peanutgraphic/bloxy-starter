import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';

/**
 * Public landing page for BLOXY-built apps.
 *
 * Replaces the Laravel-Breeze welcome page (which advertised Laravel,
 * not the host product). Two-column institutional layout — product
 * identity on the left, a minimal structural diagram of the
 * cockpit/portal split on the right. No external assets, no emojis,
 * line-art SVG only, brand color is bloxy.steel.
 *
 * Apps consuming the BLOXY starter are expected to customize the
 * APP_NAME and the one-line description. The structural diagram on
 * the right makes a generic claim about BLOXY-built apps in general
 * and can be replaced with a product-specific illustration if useful.
 */
export default function Welcome({ auth }: PageProps) {
    const dashboardHref = auth?.user ? route('dashboard') : route('login');
    const dashboardLabel = auth?.user ? 'Open dashboard' : 'Sign in';

    return (
        <>
            <Head title="Welcome" />
            <div className="bloxy-welcome min-h-screen bg-bloxy-paper font-bloxy text-bloxy-ink">
                <main className="mx-auto grid max-w-6xl gap-12 px-6 py-24 lg:grid-cols-2 lg:items-center lg:py-32">
                    {/* Left column — identity */}
                    <section>
                        <p className="mb-3 font-bloxy-mono text-xs uppercase tracking-widest text-bloxy-steel-dim">
                            Vertical-SaaS engine
                        </p>
                        <h1 className="text-4xl font-semibold tracking-tight text-bloxy-steel sm:text-5xl">
                            BLOXY
                        </h1>
                        <p className="mt-6 max-w-md text-lg leading-relaxed text-bloxy-ink">
                            Operator cockpit, customer portal, audit trail
                            by default. Compliance-shaped primitives for
                            apps where data sensitivity and policy review
                            are part of the product.
                        </p>
                        <div className="mt-10 flex items-center gap-4">
                            <Link
                                href={dashboardHref}
                                className="inline-flex items-center justify-center rounded border border-bloxy-steel bg-bloxy-steel px-5 py-2.5 text-sm font-medium text-bloxy-surface transition-colors hover:bg-bloxy-steel/90 focus:outline-none focus:ring-2 focus:ring-bloxy-steel focus:ring-offset-2"
                            >
                                {dashboardLabel}
                            </Link>
                            {!auth?.user && (
                                <Link
                                    href={route('register')}
                                    className="inline-flex items-center justify-center rounded border border-bloxy-wire bg-bloxy-surface px-5 py-2.5 text-sm font-medium text-bloxy-ink transition-colors hover:border-bloxy-steel-dim focus:outline-none focus:ring-2 focus:ring-bloxy-steel focus:ring-offset-2"
                                >
                                    Create account
                                </Link>
                            )}
                        </div>
                    </section>

                    {/* Right column — structural diagram of the cockpit/portal split */}
                    <section className="lg:pl-12" aria-hidden="true">
                        <div className="bloxy-structural-diagram rounded border border-bloxy-wire bg-bloxy-surface p-8">
                            <svg
                                width="100%"
                                viewBox="0 0 320 220"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth="1.5"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                className="text-bloxy-steel"
                            >
                                {/* Cockpit */}
                                <rect x="8" y="8" width="140" height="100" rx="2" />
                                <line x1="8" y1="28" x2="148" y2="28" />
                                <line x1="28" y1="48" x2="120" y2="48" />
                                <line x1="28" y1="62" x2="100" y2="62" />
                                <line x1="28" y1="76" x2="110" y2="76" />
                                <line x1="28" y1="90" x2="80" y2="90" />
                                {/* Portal */}
                                <rect x="172" y="8" width="140" height="100" rx="2" />
                                <line x1="172" y1="28" x2="312" y2="28" />
                                <line x1="192" y1="50" x2="292" y2="50" />
                                <line x1="192" y1="64" x2="272" y2="64" />
                                <line x1="192" y1="86" x2="252" y2="86" />
                                {/* Audit trail */}
                                <rect x="8" y="128" width="304" height="80" rx="2" />
                                <line x1="8" y1="148" x2="312" y2="148" />
                                <text
                                    x="20"
                                    y="172"
                                    fontSize="9"
                                    fontFamily="ui-monospace, SFMono-Regular, monospace"
                                    fill="currentColor"
                                    stroke="none"
                                >
                                    audit_log :: chained, signed, tamper-evident
                                </text>
                                <text
                                    x="20"
                                    y="190"
                                    fontSize="9"
                                    fontFamily="ui-monospace, SFMono-Regular, monospace"
                                    fill="currentColor"
                                    stroke="none"
                                >
                                    auth :: passkey + RBAC + recovery
                                </text>
                            </svg>
                            <div className="mt-4 grid grid-cols-2 gap-4 font-bloxy-mono text-[10px] uppercase tracking-wider text-bloxy-steel-dim">
                                <div>Operator cockpit</div>
                                <div>Customer portal</div>
                            </div>
                        </div>
                    </section>
                </main>

                <footer className="border-t border-bloxy-wire">
                    <div className="mx-auto max-w-6xl px-6 py-6 font-bloxy-mono text-xs text-bloxy-steel-dim">
                        BLOXY · Peanut Graphic internal engine
                    </div>
                </footer>
            </div>
        </>
    );
}
