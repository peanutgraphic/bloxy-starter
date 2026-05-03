<?php

use App\Http\Controllers\CockpitController;
use App\Http\Controllers\PortalController;
use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::middleware(['auth', 'verified'])->group(function () {
    // Default Breeze dashboard — kept for parity. Cockpit + Portal are the
    // BLOXY-shaped landing surfaces.
    Route::get('/dashboard', fn () => Inertia::render('Dashboard'))->name('dashboard');

    Route::get('/cockpit', [CockpitController::class, 'dashboard'])->name('cockpit');
    Route::get('/portal', [PortalController::class, 'index'])->name('portal');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

// Breeze: traditional email+password auth. SHIPS ENABLED by default.
require __DIR__.'/auth.php';

// bloxy-passkey: WebAuthn + PRF + recovery routes auto-mount via
// BloxyPasskeyServiceProvider when `bloxy-passkey.route_prefix` is set
// (default 'passkey' — see .env.example BLOXY_PASSKEY_ROUTE_PREFIX).
// To disable, set the env var to an empty string.
// B1.7.1's `php artisan bloxy:passkey-only` command flips Breeze auth
// pages for passkey-flow pages (UI swap, not a routes change — passkey
// routes are already mounted).
