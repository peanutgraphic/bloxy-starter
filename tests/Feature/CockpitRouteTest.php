<?php

use App\Models\User;

it('renders the cockpit dashboard for authenticated users', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)->get('/cockpit');

    $response->assertStatus(200);
    $response->assertInertia(fn ($page) => $page->component('Cockpit/Dashboard'));
});

it('redirects unauthenticated users away from cockpit', function () {
    $response = $this->get('/cockpit');

    $response->assertRedirect('/login');
});
