/// Parameter Object qui encode tous les cas d'usage de la page d'avis.
///
/// Utilise des factory constructors nommés pour un API intent-revealing :
///   ReviewsViewConfig.myAccount(userId: ...)        → Mon compte (2 onglets)
///   ReviewsViewConfig.publicProfile(userId: ...)    → Vue profil (reçus seulement)
class ReviewsViewConfig {
  /// ID de l'utilisateur dont on charge les avis.
  final String userId;

  /// Affiche l'onglet "Donnés" (false = vue profil public, reçus seulement).
  final bool showGivenTab;

  /// Titre de la page.
  final String title;

  /// Nom affiché dans le header de la vue profil (null = mon compte).
  final String? profileName;

  /// URL avatar affiché dans le header de la vue profil (null = mon compte).
  final String? profileAvatar;

  const ReviewsViewConfig._({
    required this.userId,
    required this.showGivenTab,
    required this.title,
    this.profileName,
    this.profileAvatar,
  });

  // ─── Factory constructors ─────────────────────────────────────────────────

  /// Mon compte — 2 onglets (Reçus + Donnés), titre "Mes avis".
  factory ReviewsViewConfig.myAccount({required String userId}) =>
      ReviewsViewConfig._(
        userId: userId,
        showGivenTab: true,
        title: 'Mes avis',
      );

  /// Vue profil public — reçus uniquement, titre "Avis sur [name]".
  factory ReviewsViewConfig.publicProfile({
    required String userId,
    required String name,
    required String avatar,
  }) => ReviewsViewConfig._(
    userId: userId,
    showGivenTab: false,
    title: 'Avis sur $name',
    profileName: name,
    profileAvatar: avatar,
  );

  bool get isPublicProfile => !showGivenTab;
}
