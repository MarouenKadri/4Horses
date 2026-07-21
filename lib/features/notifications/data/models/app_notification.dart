enum NotifType { message, mission, candidature, payment, review }

/// Rôle de l'utilisateur concerné par la notification (côté client ou
/// côté freelancer de l'interaction) — sert à filtrer le flux selon le
/// mode actif de l'app, un même compte pouvant tenir les deux rôles.
enum NotifTargetRole {
  client,
  freelancer;

  static NotifTargetRole fromDb(String? value) => switch (value) {
    'freelancer' => NotifTargetRole.freelancer,
    _ => NotifTargetRole.client,
  };
}

class AppNotification {
  final String id;
  final NotifType type;
  final NotifTargetRole targetRole;
  final String title;
  final String body;
  final String timeAgo;
  final String? avatarUrl;
  final bool isRead;
  final DateTime? createdAt;

  /// Payload structuré pour les actions in-app
  /// (ex. contact_request : freelancer_id, freelancer_name)
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.type,
    this.targetRole = NotifTargetRole.client,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.avatarUrl,
    this.isRead = false,
    this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    final type = NotifType.values.firstWhere(
      (t) => t.name == (json['type'] as String? ?? ''),
      orElse: () => NotifType.mission,
    );
    return AppNotification(
      id: json['id'] as String,
      type: type,
      targetRole: NotifTargetRole.fromDb(json['target_role'] as String?),
      title: json['title'] as String,
      body: json['body'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      timeAgo: _timeAgo(createdAt),
      createdAt: createdAt,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return 'Il y a ${(diff.inDays / 7).floor()} semaines';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    targetRole: targetRole,
    title: title,
    body: body,
    timeAgo: timeAgo,
    avatarUrl: avatarUrl,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    data: data,
  );
}
