<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PortalController extends Controller
{
    public function index(Request $request): Response
    {
        return Inertia::render('Portal/Index', [
            'user' => $request->user(),
        ]);
    }
}
