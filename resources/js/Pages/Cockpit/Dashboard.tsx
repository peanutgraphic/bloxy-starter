import { CockpitShell } from '@peanutgraphic/bloxy-ui';
import { Head } from '@inertiajs/react';
import type { User } from '@/types';

export default function CockpitDashboard({ user }: { user: User }) {
    return (
        <CockpitShell
            appName="Bloxy"
            sidebar={
                <nav>
                    <a href="/cockpit" className="block rounded px-3 py-2 hover:bg-slate-100">Dashboard</a>
                    <a href="/portal" className="block rounded px-3 py-2 hover:bg-slate-100">Portal</a>
                </nav>
            }
            topBar={<div className="text-sm text-slate-600">{user.email}</div>}
        >
            <Head title="Cockpit" />
            <div className="space-y-4 p-6">
                <h1 className="text-2xl font-semibold">Welcome, {user.name}.</h1>
                <p className="text-slate-600">
                    This is your starter cockpit. Replace this stub with your
                    application's operator/admin surface.
                </p>
            </div>
        </CockpitShell>
    );
}
