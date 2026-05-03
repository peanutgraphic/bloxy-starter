<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class CockpitController extends Controller
{
    public function dashboard(Request $request): Response
    {
        return Inertia::render('Cockpit/Dashboard', [
            'user' => $request->user(),
        ]);
    }
}
