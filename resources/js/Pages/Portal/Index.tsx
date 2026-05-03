import { PortalShell } from '@peanutgraphic/bloxy-ui';
import { Head } from '@inertiajs/react';
import type { User } from '@/types';

export default function PortalIndex({ user }: { user: User }) {
    return (
        <PortalShell appName="Bloxy">
            <Head title="Portal" />
            <div className="space-y-4 p-6">
                <h1 className="text-2xl font-semibold">Hi {user.name}.</h1>
                <p className="text-slate-600">
                    This is your starter portal. Replace this stub with your
                    application's end-user surface.
                </p>
            </div>
        </PortalShell>
    );
}
