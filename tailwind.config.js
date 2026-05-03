import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);

/** The bloxy-ui Tailwind preset is published via:
 *    php artisan vendor:publish --tag=bloxy-ui-tailwind
 *  which writes tailwind.preset.js to the project root. The require
 *  below picks it up. If the preset hasn't been published yet (e.g.,
 *  immediately post-clone before scripts.post-create-project-cmd has
 *  run), this falls back to an empty preset.
 */
const presetPath = path.resolve(__dirname, 'tailwind.preset.js');
const bloxyPreset = fs.existsSync(presetPath) ? require(presetPath) : {};

/** @type {import('tailwindcss').Config} */
export default {
    presets: [bloxyPreset],
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.{js,jsx,ts,tsx}',
        // Pull in bloxy-ui's compiled JS so its class names are scanned by JIT.
        './node_modules/@peanutgraphic/bloxy-ui/**/*.{js,jsx,ts,tsx}',
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Figtree', ...defaultTheme.fontFamily.sans],
            },
        },
    },
    plugins: [forms],
};
