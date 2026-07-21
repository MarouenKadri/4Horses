# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Analyze / lint
flutter analyze

# Format code
dart format .

# Run app
flutter run

# Run a single test file
flutter test test/path/to/test_file.dart

# Run tests
flutter test

# Build
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## Environment Setup

Copy `.env.example` to `.env` and fill in:
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Supabase anonymous key
- `GOOGLE_WEB_CLIENT_ID` — Google OAuth client ID

A generated `lib/app/config.dart` is required at runtime (gitignored). It is produced from the `.env` values.

## Architecture

Flutter marketplace app (service requests / freelancers). Default locale is **French**.

### Layer structure under `lib/`

| Directory | Purpose |
|---|---|
| `app/` | App-wide config: routing, theming (`ThemeProvider`), auth state (`AuthProvider`), top-level widgets |
| `core/design/` | Design system — tokens (colors, spacing, radius, typography), reusable UI components |
| `features/` | Feature modules, each with `data/` and `presentation/` sub-layers |

### Feature modules

- **auth** — login, registration (multi-step with service type selection), OTP verification, password reset, Google Sign-In
- **mission** — mission CRUD, listings, candidates, tracking (shared between roles); `MissionStatus` has 15 states
- **client** — client-specific mission management views
- **freelancer** — freelancer mission browsing and application views
- **messaging** — real-time chat (Supabase Realtime) with optimistic UI and unread count tracking
- **profile** — user profile, settings, payment methods, wallet, skills; split into `client/` and `freelancer/` sub-pages
- **notifications** — in-app notification feed
- **reviews** — rating and review system
- **story** — social story/feed functionality

### Feature module layout

Each feature follows this structure:
```
feature/
├── feature.dart          # barrel export
├── data/
│   ├── models/           # data classes with serialization
│   ├── repositories/     # abstract interface + SupabaseXxxRepository implementation
│   └── fixtures/         # InMemoryXxxRepository with demo data (for development)
└── presentation/
    ├── xxx_provider.dart # ChangeNotifier with business logic
    ├── pages/            # screens, split into client/ and freelancer/ where needed
    └── widgets/          # reusable components scoped to this feature
```

Repositories are injected into providers; swap in `InMemoryXxxRepository` (from `fixtures/`) for development without a live backend.

### User role system

Users have a `user_type` of `'client'` or `'freelancer'` and can hold both roles simultaneously. The active role is persisted in `SharedPreferences`. Navigation trees are separate per role: `guest_navigation_config.dart`, `client_navigation_config.dart`, `provider_navigation_config.dart`.

### Navigation / routing

`RootNav` watches `AuthProvider` and routes between three states:
1. `needsRoleSelection` → `GoogleOnboardingFlow`
2. `!isLogged` → `GuestNav`
3. Logged in → `ClientNav` or `ProviderNav` based on `currentRole` (with `_ModeSwitchSplash` animation on switch)

### App startup sequence (`main.dart`)

1. Load `.env`
2. Validate Supabase config
3. Initialize Supabase
4. Configure system UI
5. Inject 7 `Provider` instances (auth, theme, missions, freelancers, stories, notifications, messaging)
6. Route based on auth state

### Design system

All UI primitives live in `lib/core/design/`. Import via the barrel:
```dart
import 'package:your_app/core/design/app_design_system.dart';
```
Tokens: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`. Components: `AppButton`, `AppTextField`, `AppDialog`, `AppSheet`, `AppLayout`, `AppAppBar`.

### Backend

**Supabase** handles auth, database (PostgreSQL), storage, and real-time subscriptions. There is no separate backend service.

Supabase query conventions:
- Fluent API: `.from('table').select().eq().order()`
- Joins use postfix notation: `select('*, client:profiles!client_id(*)')`
- All queries check auth state before executing; return empty list on failure

Real-time: `MessagingProvider` uses `supabase.channel()` with `PostgresChangeEvent.insert`, filtered by `conversation_id`. Unsubscribe on `signOut`.

### State management

`provider` package only — no Riverpod, Bloc, or GetX.

Providers are `ChangeNotifier`-based. Notable patterns:
- `AuthProvider` guards concurrent profile loads with `_isLoadingProfile` and skips profile load during registration with `_isRegistering`
- `MissionProvider` loads all mission lists in parallel on auth state change; uses optimistic UI (prepend/remove before server confirmation)
- `MessagingProvider` uses temp IDs for optimistic message sending; cleans up real-time subscriptions on `signOut`
