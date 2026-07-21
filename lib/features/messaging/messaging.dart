/// ═══════════════════════════════════════════════════════════════════════════
/// Messaging Feature Barrel
/// ═══════════════════════════════════════════════════════════════════════════
library;

// ─── Data Models ──────────────────────────────────────────────────────────────
export 'data/models/message.dart';
export 'data/models/message_content.dart';

// ─── Repositories ─────────────────────────────────────────────────────────────
export 'data/repositories/messaging_repository.dart';
export 'data/repositories/moderated_messaging_repository.dart';

// ─── Providers ────────────────────────────────────────────────────────────────
export 'messaging_provider.dart';
export 'presentation/providers/chat_provider.dart';

// ─── Pages ────────────────────────────────────────────────────────────────────
export 'presentation/pages/messages_page.dart';
export 'presentation/pages/chat_page.dart';

// ─── Widgets ──────────────────────────────────────────────────────────────────
export 'presentation/widgets/chat_message_bubble.dart';
export 'presentation/widgets/chat_input_bar.dart';
export 'presentation/widgets/location_message_bubble.dart';
export 'presentation/widgets/message_time_status.dart';
