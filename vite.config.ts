import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));

// libsodium-wrappers-sumo's ESM build is broken in Node; the CJS
// entrypoints work for both Vite and Vitest. Same workaround
// crypto-js itself uses (B1.8.0).
const sodiumWrappersCjs = require.resolve('libsodium-wrappers-sumo');
const sodiumSumoCjs = require.resolve('libsodium-sumo');

export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/js/app.tsx',
            refresh: true,
        }),
        react(),
    ],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'resources/js'),
            'libsodium-wrappers-sumo': sodiumWrappersCjs,
            'libsodium-sumo': sodiumSumoCjs,
        },
    },
});
