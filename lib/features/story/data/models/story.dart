import '../../shared/story_category_mapper.dart';

/// Story model (stored in Supabase `posts` table — images-only subset)
class Story {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String imageUrl;
  final String caption;
  final String serviceCategory; // e.g. "jardinage", "" = non classé
  final DateTime createdAt;
  final bool isOwner;
  final int likesCount;
  final bool isLiked;

  const Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.imageUrl,
    required this.caption,
    required this.serviceCategory,
    required this.createdAt,
    required this.isOwner,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Story.fromJson(Map<String, dynamic> json, String currentUserId) {
    final author = json['author'] as Map<String, dynamic>?;
    final images = List<String>.from(json['images'] as List? ?? []);
    final authorName =
        '${author?['first_name'] ?? ''} ${author?['last_name'] ?? ''}'.trim();
    // Likes depuis la table post_likes (jointure)
    final likedByRows = List<Map<String, dynamic>>.from(
      json['post_likes'] as List? ?? [],
    );
    final likedByIds = likedByRows.map((r) => r['user_id'].toString()).toList();
    return Story(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: authorName.isEmpty ? 'Prestataire' : authorName,
      authorAvatar: author?['avatar_url'] as String? ?? '',
      imageUrl: images.isNotEmpty ? images.first : '',
      caption: json['content'] as String? ?? '',
      serviceCategory: json['service_category'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwner: json['author_id'] == currentUserId,
      likesCount: likedByIds.length,
      isLiked: likedByIds.contains(currentUserId),
    );
  }

  Story copyWith({
    String? caption,
    String? serviceCategory,
    int? likesCount,
    bool? isLiked,
  }) => Story(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorAvatar: authorAvatar,
    imageUrl: imageUrl,
    caption: caption ?? this.caption,
    serviceCategory: serviceCategory ?? this.serviceCategory,
    createdAt: createdAt,
    isOwner: isOwner,
    likesCount: likesCount ?? this.likesCount,
    isLiked: isLiked ?? this.isLiked,
  );
}

/// A group of stories displayed as one circle.
/// Two modes:
///   • Author group  (isAuthorGroup = true)  → one circle per freelancer (home bars)
///   • Category group (isAuthorGroup = false) → one circle per service category (profile views)
class StoryGroup {
  final String groupId; // authorId  OR  categoryId
  final String groupName; // author first name  OR  category label
  final String avatarUrl; // author avatar (empty for category groups)
  final String categoryId; // "" for author groups, filled for category groups
  final List<Story> stories; // sorted newest first

  const StoryGroup({
    required this.groupId,
    required this.groupName,
    this.avatarUrl = '',
    this.categoryId = '',
    required this.stories,
  });

  /// true  → show avatar circle (home bars)
  /// false → show category-icon circle (profile views)
  bool get isAuthorGroup => categoryId.isEmpty;

  DateTime get latestDate => stories.first.createdAt;

  // ── Group by author (for home story bars) ───────────────────
  static List<StoryGroup> fromStoriesByAuthor(List<Story> stories) {
    final Map<String, List<Story>> grouped = {};
    for (final s in stories) {
      grouped.putIfAbsent(s.authorId, () => []).add(s);
    }
    final groups = grouped.entries.map((e) {
      final sorted = List<Story>.from(e.value)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return StoryGroup(
        groupId: e.key,
        groupName: sorted.first.authorName.split(' ').first,
        avatarUrl: sorted.first.authorAvatar,
        categoryId: '', // author group → no categoryId
        stories: sorted,
      );
    }).toList();
    groups.sort((a, b) => b.latestDate.compareTo(a.latestDate));
    return groups;
  }

  // ── Group by service category (for profile views) ────────────
  static List<StoryGroup> fromStoriesByCategory(List<Story> stories) {
    final Map<String, List<Story>> grouped = {};
    for (final s in stories) {
      final key = s.serviceCategory.isNotEmpty ? s.serviceCategory : 'autres';
      grouped.putIfAbsent(key, () => []).add(s);
    }
    final groups = grouped.entries.map((e) {
      final sorted = List<Story>.from(e.value)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return StoryGroup(
        groupId: e.key,
        groupName: _categoryLabel(e.key),
        avatarUrl: '', // category group → no avatar
        categoryId: e.key,
        stories: sorted,
      );
    }).toList();
    groups.sort((a, b) => b.latestDate.compareTo(a.latestDate));
    return groups;
  }

  static String _categoryLabel(String id) {
    return StoryCategoryMapper.label(id, fallback: 'Autres');
  }
}
