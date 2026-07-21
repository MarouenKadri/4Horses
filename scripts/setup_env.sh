#!/usr/bin/env bash
# Génère le fichier .env de la machine locale en posant les questions
# une par une, avec un rappel d'où trouver chaque clé.
#
# Usage : ./scripts/setup_env.sh

set -euo pipefail

cd "$(dirname "$0")/.."

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
  read -rp "$ENV_FILE existe déjà. L'écraser ? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Abandon — $ENV_FILE inchangé."
    exit 0
  fi
fi

ask() {
  local var_name="$1"
  local hint="$2"
  local value

  {
    echo
    echo "── $var_name ──────────────────────────────────────────"
    echo "$hint"
  } >&2
  read -rp "> " value
  echo "$value"
}

SUPABASE_URL=$(ask "SUPABASE_URL" \
  "Dashboard Supabase → ton projet → Project Settings → API → 'Project URL'
  (ressemble à https://xxxxxxxx.supabase.co)")

SUPABASE_ANON_KEY=$(ask "SUPABASE_ANON_KEY" \
  "Même page → API → section 'Project API keys' → clé 'anon' / 'public'
  (jamais la clé 'service_role' — celle-là ne doit jamais quitter le serveur)")

GOOGLE_WEB_CLIENT_ID=$(ask "GOOGLE_WEB_CLIENT_ID" \
  "Google Cloud Console → APIs & Services → Identifiants → ton
  'OAuth 2.0 Client ID' de type Web (finit par .apps.googleusercontent.com)")

STRIPE_PUBLISHABLE_KEY=$(ask "STRIPE_PUBLISHABLE_KEY" \
  "Dashboard Stripe → Developers → API keys → 'Publishable key'
  (commence par pk_test_ en mode test, pk_live_ en production —
  jamais la clé secrète sk_...)")

cat > "$ENV_FILE" <<EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID
STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
EOF

echo
echo "✓ $ENV_FILE généré."
echo "Prochaine étape : flutter pub get && flutter run"
