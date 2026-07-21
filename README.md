# BYRSA

Application Flutter de marketplace de services entre clients et prestataires.

## Stack

- Flutter / Dart
- Provider pour la gestion d'état
- Supabase pour l'authentification, les données et le realtime
- Stripe pour les paiements

## Installation (nouvelle machine)

```bash
./scripts/setup_env.sh   # génère .env, demande chaque clé (Supabase, Google, Stripe)
flutter pub get
flutter run
```

## Qualité

```bash
flutter analyze
flutter test
```
