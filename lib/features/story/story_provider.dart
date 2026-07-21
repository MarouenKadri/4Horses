import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/story.dart';

class StoryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Story> _stories = [];
  bool isLoading = false;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  List<Story> get stories => List.unmodifiable(_stories);

  /// Home bars: one circle per freelancer
  List<StoryGroup> get storyGroups => StoryGroup.fromStoriesByAuthor(_stories);

  /// Profile view: one circle per service category, filtered by freelancer
  List<StoryGroup> storyGroupsForFreelancer(String authorId) =>
      StoryGroup.fromStoriesByCategory(
        _stories.where((s) => s.authorId == authorId).toList(),
      );

  /// Own stories grouped by category (for account page)
  List<StoryGroup> get myStoryGroups => StoryGroup.fromStoriesByCategory(
    _stories.where((s) => s.isOwner).toList(),
  );

  StreamSubscription<AuthState>? _authSub;

  StoryProvider() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _load();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _stories = [];
        notifyListeners();
      }
    });
    if (Supabase.instance.client.auth.currentUser != null) _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    try {
      final userId = _userId ?? '';
      final data = await _supabase
          .from('posts')
          .select(
            '*, author:profiles!author_id(first_name, last_name, avatar_url), post_likes(user_id)',
          )
          .order('created_at', ascending: false)
          .limit(100);
      _stories = (data as List)
          .map<Story?>((j) {
            final images = List<String>.from(j['images'] as List? ?? []);
            if (images.isEmpty) return null;
            return Story.fromJson(j as Map<String, dynamic>, userId);
          })
          .whereType<Story>()
          .toList();
    } catch (e) {
      debugPrint('StoryProvider load error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  /// Crée UN post contenant toutes les images (posts.images est un tableau).
  Future<Story?> createStory({
    required List<File> imageFiles,
    String caption = '',
    String serviceCategory = '',
  }) async {
    final userId = _userId;
    if (userId == null || imageFiles.isEmpty) return null;
    try {
      final urls = <String>[];
      final ts = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < imageFiles.length; i++) {
        final bytes = await imageFiles[i].readAsBytes();
        final path = '$userId/${ts}_$i.jpg';
        await _supabase.storage
            .from('post-images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        urls.add(_supabase.storage.from('post-images').getPublicUrl(path));
      }

      final data = await _supabase
          .from('posts')
          .insert({
            'author_id': userId,
            'content': caption,
            'images': urls,
            'service_category': serviceCategory.isEmpty
                ? null
                : serviceCategory,
          })
          .select(
            '*, author:profiles!author_id(first_name, last_name, avatar_url)',
          )
          .single();

      final story = Story.fromJson(data, userId);
      _stories = [story, ..._stories];
      notifyListeners();
      return story;
    } catch (e) {
      debugPrint('StoryProvider createStory error: $e');
      return null;
    }
  }

  Future<void> deleteStory(String id) async {
    _stories = _stories.where((s) => s.id != id).toList();
    notifyListeners();
    try {
      await _supabase.from('posts').delete().eq('id', id);
    } catch (e) {
      debugPrint('StoryProvider deleteStory error: $e');
    }
  }

  Future<void> toggleLike(String storyId) async {
    final userId = _userId;
    if (userId == null) return;
    final idx = _stories.indexWhere((s) => s.id == storyId);
    if (idx < 0) return;
    final story = _stories[idx];
    final newLiked = !story.isLiked;

    // Optimistic update (instant feedback)
    _stories = List.from(_stories)
      ..[idx] = story.copyWith(
        isLiked: newLiked,
        likesCount: story.likesCount + (newLiked ? 1 : -1),
      );
    notifyListeners();

    try {
      if (newLiked) {
        await _supabase.from('post_likes').insert({
          'post_id': storyId,
          'user_id': userId,
        });
      } else {
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', storyId)
            .eq('user_id', userId);
      }
      // Optimistic state is already applied; no re-fetch needed
    } catch (e) {
      // Revert optimistic update on error
      _stories = List.from(_stories)..[idx] = story;
      notifyListeners();
      debugPrint('StoryProvider toggleLike error: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<bool> updateStory(
    String id, {
    required String caption,
    required String serviceCategory,
  }) async {
    final idx = _stories.indexWhere((s) => s.id == id);
    if (idx < 0) return false;
    try {
      await _supabase
          .from('posts')
          .update({
            'content': caption,
            'service_category': serviceCategory.isEmpty
                ? null
                : serviceCategory,
          })
          .eq('id', id);
      _stories = List.from(_stories)
        ..[idx] = _stories[idx].copyWith(
          caption: caption,
          serviceCategory: serviceCategory,
        );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('StoryProvider updateStory error: $e');
      return false;
    }
  }
}
