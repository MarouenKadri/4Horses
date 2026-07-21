# 4horses

A Flutter marketplace app connecting clients who need a service done with
freelancers who provide it — think housekeeping, gardening, handyman work,
childcare, and more. Clients post missions, freelancers apply (or get
booked directly), and both sides track the mission live from confirmation
to payout.

**Same account, both roles.** Every user can act as a client and a
freelancer at the same time — there's no separate signup flow for either
side. The active role is switched from within the app (persisted locally),
and each role gets its own dedicated navigation, home screen, and mission
list. A user who books a plumber one day can offer gardening services the
next, without creating a second account.

Default locale: French. Built and tested primarily on Android.

## Stack

- Flutter / Dart
- Provider for state management (no Riverpod, Bloc, or GetX)
- Supabase — auth, Postgres database, storage, and realtime subscriptions
- Stripe — payments

## Architecture

```
lib/
├── app/          app-wide config: routing, theming, auth state,
│                 role-based navigation (client / freelancer / guest)
├── core/
│   └── design/   design system — tokens (colors, spacing, typography)
│                 + reusable components (buttons, cards, dialogs...)
└── features/     one module per business domain (see below)
```

Each module under `features/` follows the same layout:

```
feature/
├── data/
│   ├── models/        data classes + serialization
│   ├── repositories/  abstract interface + Supabase implementation
│   └── fixtures/      in-memory demo data (dev without a live backend)
└── presentation/
    ├── xxx_provider.dart   business logic (ChangeNotifier)
    ├── pages/              screens
    └── widgets/            components scoped to this feature
```

Repositories are injected into providers, so the Supabase implementation
can be swapped for the in-memory fixture to develop without a live
backend connection.

## Features

| Module | What it covers |
|---|---|
| `auth` | login, multi-step registration, OTP verification, password reset, Google Sign-In |
| `mission` | full mission lifecycle (15 statuses): posting, applications, confirmation, live tracking, completion, payout |
| `client` | screens specific to the client role (managing posted missions) |
| `freelancer` | screens specific to the freelancer role (browsing, applying, tracking) |
| `messaging` | real-time chat (Supabase Realtime), optimistic UI, unread badges |
| `profile` | profile, settings, payment methods, wallet, skills |
| `notifications` | in-app notification feed |
| `reviews` | ratings and reviews after a completed mission |
| `story` | social-style feed of posts/past work showcased by freelancers |

### How a mission flows

A mission moves through a defined set of statuses shared by both roles:
posted → applications received / directly booked → confirmed → freelancer
en route → in progress → completion requested → paid out. Both the client
and the freelancer see the same mission update live via Supabase Realtime
— no manual refresh needed. Freelancers can either browse and apply to
open missions or accept a direct booking from a client; clients can review
applicants, message freelancers, and track their arrival on a live map
once a mission is confirmed.

## Getting started (new machine)

```bash
git clone git@github.com:MarouenKadri/4horses-app.git
cd 4horses-app
./scripts/setup_env.sh   # generates .env, prompts for each key (Supabase, Google, Stripe)
flutter pub get
flutter run
```

## Quality

```bash
flutter analyze
flutter test
```
