<?php

use App\Models\User;

it('renders the portal index for authenticated users', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)->get('/portal');

    $response->assertStatus(200);
    $response->assertInertia(fn ($page) => $page->component('Portal/Index'));
});
