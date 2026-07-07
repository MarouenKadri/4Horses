/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - Profile Feature Barrel
/// Profil, paramètres, wallet, sécurité, compétences, vérification identité
/// ═══════════════════════════════════════════════════════════════════════════
library;

// ─── Data Models ──────────────────────────────────────────────────────────────
export 'data/models/transaction.dart';
export 'data/models/skill.dart';
export 'data/models/user_profile.dart';
export 'data/repositories/freelancer_catalog_repository.dart';
export 'data/repositories/supabase_freelancer_catalog_repository.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────
export 'profile_provider.dart';

// ─── Widgets - Shared ─────────────────────────────────────────────────────────
export 'presentation/pages/widgets/shared/user_common_widgets.dart';

// ─── Pages - Shared ───────────────────────────────────────────────────────────
export 'presentation/pages/shared/account_page.dart';
export 'presentation/pages/shared/change_password_page.dart';
export 'presentation/pages/shared/my_information_page.dart';

// ─── Pages - Client ───────────────────────────────────────────────────────────
export 'presentation/pages/client/client_payment_methods_page.dart';

// ─── Pages - Freelancer ───────────────────────────────────────────────────────
export 'presentation/pages/freelancer/freelancer_activity_page.dart';
export 'presentation/pages/freelancer/freelancer_payment_methods_page.dart';
