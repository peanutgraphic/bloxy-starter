<?php

namespace App\Models;

use Bloxy\Core\Identity\Authorizable;
use Bloxy\Passkey\Models\Passkey;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use Authorizable, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Polymorphic passkeys belonging to this user (bloxy-passkey).
     */
    public function passkeys(): MorphMany
    {
        return $this->morphMany(Passkey::class, 'user');
    }
}
