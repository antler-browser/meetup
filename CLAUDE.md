# CLAUDE.md for Hello World Mini App

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A "Hello World" IRL Browser mini app demonstrating profile access via `window.irlBrowser` API with JWT verification. This mini app is meant to run inside an IRL Browser like Antler. See `/docs/irl-browser-standard.md` for IRL Browser Standard specification.

## Key Files and Directories

- `/src/components/`: Components organized by feature
  - `/QRCodePanel.tsx` - Shows a QR code for app. Hidden on mobile, visible on desktop.
  - `/Avatar.tsx` - Displays a user's avatar or placeholder if no avatar is set.
- `/src/lib/`: Library / utility functions for common tasks
  - `/jwt.ts` - JWT decoding and verification
- `/src/app.tsx` - Main component with IRL Browser integration and profile display
- `/src/main.tsx` - Entry point that renders App (initializes IRL Browser Simulator in dev mode)
- `/public/`: Public files
  - `irl-manifest.json` - Mini app IRL Browser manifest with metadata and requested permissions
  - `antler-icon.webp` - Mini app icon
- `/docs/`: Documentation
  - `irl-browser-standard.md` - IRL Browser Standard specification

## Development Commands

```bash
pnpm install       # Install dependencies
pnpm run dev       # Start dev server (localhost:5173)
pnpm run build     # TypeScript compile + Vite build
pnpm run preview   # Preview production build
```

## Architecture Overview

### JWT Verification Pipeline (`/src/lib/jwt.ts`)
1. Decode JWT with `jwt-decode`
2. Extract issuer DID from `iss` claim
3. Reject if JWT is expired (`exp` claim)
4. Reject if JWT is not intended for this application (`aud` claim)
5. Parse public key from DID: strip `did:key:z`, decode base58, remove multicodec prefix `[0xed, 0x01]`
6. Verify Ed25519 signature using `@noble/curves`: `ed25519.verify(signature, message, publicKeyBytes)`
7. Return typed payload

**Key detail**: Uses @noble/curves library for signature verification. (Cannot use Web Crypto APIs as most mobile browsers don't support Ed25519 yet.)

### Responsive Layout
- **Mobile**: Single column, QR code hidden
- **Desktop**: Two columns with QR code panel on left

## Development Workflow

### Debugging IRL Browser Mini Apps
The IRL Browser Simulator injects the `window.irlBrowser` API into a regular browser, allowing you to test your mini app locally without needing the Antler mobile app.

**Note:** This is a development-only tool and should never be used in production.

```typescript
if (import.meta.env.DEV) {
  const simulator = await import('irl-browser-simulator')
  simulator.enableIrlBrowserSimulator()
}
```

That's it! The simulator will:
- Inject `window.irlBrowser` into your page
- Load a default test profile (Paul Morphy)
- Show a floating debug panel
- Click "Open as X" to open a new tab and simulate multiple users
- Load a profile from the URL parameter `?irlProfile=<id>`

### Testing on Antler with ngrok (optional)
Ngrok creates a public URL that is useful for testing your locally running mini app on Antler.

1. Run `ngrok http 5173`
2. Add your ngrok URL to `vite.config.ts` allowedHosts
3. Run `pnpm run dev` to start your local server
4. Scan QR code with Antler app

## Third Party Libraries

- **React**
- **Tailwind**
- **@noble/curves** - Ed25519 signature verification
- **base58-universal** - Base58 encoding
- **jwt-decode** - JWT decoding
- **qrcode.react** - QR code generation
- **irl-browser-simulator** - IRL Browser debugging

## Troubleshooting

### JWT Verification Failures
- Expired JWT (`exp` claim)
- Invalid signature
- Malformed DID (must start with `did:key:z`)
- Audience claim mismatch (must match production URL)

### Profile Not Loading
Check if API exists: `console.log(window.irlBrowser)`

### Build Errors
- Run `pnpm install`
- Check TypeScript errors: `pnpm run build`