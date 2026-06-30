import '../models/app_notification.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📦 Inkern - NotificationRepository (interface async)
/// ═══════════════════════════════════════════════════════════════════════════

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchAll(String userId);
  Future<void> markRead(String notifId);
  Future<void> markAllRead(String userId);
  Future<void> delete(String notifId);
  Future<void> sendNotification(
    String targetUserId, {
    required String type,
    required String title,
    required String body,
    String? avatarUrl,
    Map<String, dynamic>? data,
  });
}

/// ─── Implémentation In-Memory (données de démo) ───────────────────────────

class InMemoryNotificationRepository implements NotificationRepository {
  const InMemoryNotificationRepository();

  @override
  Future<List<AppNotification>> fetchAll(String userId) async =>
      NotificationDemoData.initial;

  @override
  Future<void> markRead(String notifId) async {}

  @override
  Future<void> markAllRead(String userId) async {}

  @override
  Future<void> delete(String notifId) async {}

  @override
  Future<void> sendNotification(
    String targetUserId, {
    required String type,
    required String title,
    required String body,
    String? avatarUrl,
    Map<String, dynamic>? data,
  }) async {}
}

/// ─── Données de démonstration ─────────────────────────────────────────────

class NotificationDemoData {
  const NotificationDemoData._();

  static List<AppNotification> get initial => [
        const AppNotification(
          id: '1',
          type: NotifType.message,
          title: 'Nouveau message de Thomas',
          body: 'Bonjour, je suis disponible pour votre mission de ménage ce samedi.',
          timeAgo: 'Il y a 5 min',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
        ),
        const AppNotification(
          id: '2',
          type: NotifType.candidature,
          title: 'Candidature acceptée',
          body: 'Marie a accepté votre candidature pour la mission "Jardinage - Paris 11e".',
          timeAgo: 'Il y a 1h',
          avatarUrl: 'https://i.pravatar.cc/150?img=47',
        ),
        const AppNotification(
          id: '3',
          type: NotifType.mission,
          title: 'Nouvelle mission près de vous',
          body: 'Repassage 2h — Paris 10e · 2,3 km · 35 €',
          timeAgo: 'Il y a 2h',
        ),
        const AppNotification(
          id: '4',
          type: NotifType.payment,
          title: 'Paiement reçu',
          body: 'Vous avez reçu 80 € pour la mission "Ménage appartement".',
          timeAgo: 'Hier, 18h30',
          isRead: true,
        ),
        const AppNotification(
          id: '5',
          type: NotifType.review,
          title: 'Nouvel avis reçu',
          body: 'Julie M. vous a laissé un avis 5 étoiles : "Excellent travail, très ponctuelle !"',
          timeAgo: 'Hier, 14h00',
          avatarUrl: 'https://i.pravatar.cc/150?img=25',
          isRead: true,
        ),
        const AppNotification(
          id: '6',
          type: NotifType.message,
          title: 'Nouveau message de Marc',
          body: 'Est-ce que vous pouvez venir le mardi plutôt que le mercredi ?',
          timeAgo: 'Il y a 2 jours',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          isRead: true,
        ),
        const AppNotification(
          id: '7',
          type: NotifType.mission,
          title: 'Mission terminée',
          body: 'La mission "Bricolage - Paris 12e" a été marquée comme terminée.',
          timeAgo: 'Il y a 3 jours',
          isRead: true,
        ),
        const AppNotification(
          id: '8',
          type: NotifType.candidature,
          title: 'Nouvelle candidature',
          body: 'Antoine B. a postulé à votre mission "Jardinage - Paris 11e".',
          timeAgo: 'Il y a 4 jours',
          avatarUrl: 'https://i.pravatar.cc/150?img=7',
          isRead: true,
        ),
      ];
}
