/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - Mission Feature Barrel
/// ═══════════════════════════════════════════════════════════════════════════
library;

// ─── Repository ───────────────────────────────────────────────────────────────
export 'data/repositories/mission_repository.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────
export 'data/models/mission.dart';
export 'data/models/mission_address.dart';
export 'data/models/budget_info.dart';
export 'data/models/user_models.dart';
export 'data/models/service_category.dart';
export 'data/models/candidate.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────
export 'presentation/mission_provider.dart';

// ─── Widgets - Shared ─────────────────────────────────────────────────────────
export 'presentation/widgets/shared/mission_shared_widgets.dart';
export 'presentation/widgets/shared/status_timeline.dart';

// ─── Widgets - Freelancer ─────────────────────────────────────────────────────
export 'presentation/widgets/freelancer_list_widgets.dart';

// ─── Pages - Client ───────────────────────────────────────────────────────────
export 'presentation/pages/client/client_my_missions_content.dart';
export 'presentation/pages/client/client_mission_detail_page.dart';
export 'presentation/pages/client/candidates_page.dart';
export 'presentation/pages/client/tracking_page.dart';
export 'presentation/pages/client/mission_validation_page.dart';

// ─── Pages - Freelancer ───────────────────────────────────────────────────────
export 'presentation/pages/freelancer/mission_browse_page.dart';
export 'presentation/pages/freelancer/freelancer_mission_detail_page.dart';
export 'presentation/pages/freelancer/freelancer_engagements_content.dart';
export 'presentation/pages/freelancer/freelancer_tracking_page.dart';
