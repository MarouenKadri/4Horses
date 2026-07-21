import 'dart:async' show StreamSubscription, unawaited;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/user_profile.dart';
import 'data/utils/service_categories_resolver.dart';
import 'data/repositories/freelancer_catalog_repository.dart';
import 'data/repositories/supabase_freelancer_catalog_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final FreelancerCatalogRepository _freelancerCatalogRepository;

  UserProfile? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  List<Map<String, dynamic>> _freelancers = [];
  bool isLoadingFreelancers = false;
  StreamSubscription<AuthState>? _authSub;

  List<Map<String, dynamic>> get freelancers => List.unmodifiable(_freelancers);

  String? get currentUserId => _supabase.auth.currentUser?.id;
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  ProfileProvider({FreelancerCatalogRepository? freelancerCatalogRepository})
    : _freelancerCatalogRepository =
          freelancerCatalogRepository ?? SupabaseFreelancerCatalogRepository() {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        loadProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        clear();
      }
    });
    if (_supabase.auth.currentUser != null) loadProfile();
  }

  Future<void> loadProfile() async {
    final userId = currentUserId;
    if (userId == null) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      final metadata = _supabase.auth.currentUser?.userMetadata ?? {};
      final mergedRow = <String, dynamic>{
        ...row,
        'email': currentUserEmail,
        'birth_date': (row['birth_date'] as String?)?.isNotEmpty == true
            ? row['birth_date']
            : metadata['birth_date'],
        'gender': (row['gender'] as String?)?.isNotEmpty == true
            ? row['gender']
            : metadata['gender'],
        'service_categories': ServiceCategoriesResolver.resolve(
          rowValue: row['service_categories'],
          metadataValue: metadata['service_categories'],
        ),
      };

      profile = UserProfile.fromJson(mergedRow);

      final needsBirthDateBackfill =
          (row['birth_date'] as String?)?.isNotEmpty != true &&
          mergedRow['birth_date'] != null;
      final needsGenderBackfill =
          (row['gender'] as String?)?.isNotEmpty != true &&
          mergedRow['gender'] != null;

      if (needsBirthDateBackfill || needsGenderBackfill) {
        final patch = <String, dynamic>{};
        if (needsBirthDateBackfill) {
          patch['birth_date'] = mergedRow['birth_date'];
        }
        if (needsGenderBackfill) {
          patch['gender'] = mergedRow['gender'];
        }
        unawaited(_supabase.from('profiles').update(patch).eq('id', userId));
      }
    } catch (e) {
      debugPrint('loadProfile error: $e');
      error = 'Impossible de charger le profil';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProfile(UserProfile updated) async {
    final userId = currentUserId;
    if (userId == null) return 'Non connecté';
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final payload = updated.toUpdateJson();
      try {
        await _supabase.from('profiles').update(payload).eq('id', userId);
      } on PostgrestException catch (e) {
        final missingServiceCategoriesColumn =
            _isMissingServiceCategoriesColumnError(e) &&
            payload.containsKey('service_categories');
        if (!missingServiceCategoriesColumn) rethrow;

        final fallbackPayload = Map<String, dynamic>.from(payload)
          ..remove('service_categories');
        await _supabase
            .from('profiles')
            .update(fallbackPayload)
            .eq('id', userId);
        await _persistServiceCategoriesInUserMetadata(
          updated.serviceCategories,
        );
      }
      profile = updated;
      return null;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      error = 'Erreur lors de la sauvegarde';
      return error;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  bool _isMissingServiceCategoriesColumnError(PostgrestException e) {
    final message = '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'
        .toLowerCase();
    return e.code == '42703' && message.contains('service_categories');
  }

  Future<void> _persistServiceCategoriesInUserMetadata(
    List<String> categories,
  ) async {
    final normalized = categories
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'service_categories': normalized}),
      );
    } catch (e) {
      debugPrint('persistServiceCategoriesInUserMetadata error: $e');
    }
  }

  Future<void> loadFreelancers({String? search, String? category}) async {
    isLoadingFreelancers = true;
    notifyListeners();
    try {
      List<Map<String, dynamic>> results;
      try {
        results = await _freelancerCatalogRepository.fetchFreelancers(
          includeServiceCategories: true,
        );
      } catch (e) {
        debugPrint('loadFreelancers with service_categories failed: $e');
        results = await _freelancerCatalogRepository.fetchFreelancers(
          includeServiceCategories: false,
        );
      }

      // Filtrage local (search sur nom + catégories)
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        results = results.where((f) {
          final name = '${f['first_name'] ?? ''} ${f['last_name'] ?? ''}'
              .toLowerCase();
          final categories = ServiceCategoriesResolver.parse(
            f['service_categories'],
          ).join(' ').toLowerCase();
          return name.contains(q) || categories.contains(q);
        }).toList();
      }

      // Filtrage local par catégorie (id ou libellé).
      if (category != null && category.trim().isNotEmpty) {
        final normalizedCategory = _normalizeToken(category);
        if (normalizedCategory != 'all' &&
            normalizedCategory != 'tous' &&
            normalizedCategory != 'toutes') {
          results = results.where((f) {
            final categories = ServiceCategoriesResolver.parse(
              f['service_categories'],
            );
            if (categories.isEmpty) return false;
            return categories.any(
              (entry) => _normalizeToken(entry) == normalizedCategory,
            );
          }).toList();
        }
      }

      _freelancers = results;
    } catch (e) {
      debugPrint('loadFreelancers error: $e');
      _freelancers = [];
    } finally {
      isLoadingFreelancers = false;
      notifyListeners();
    }
  }

  Future<UserProfile?> fetchProfileById(String userId) async {
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(row);
    } catch (e) {
      debugPrint('fetchProfileById error: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final userId = currentUserId;
    if (userId == null) return 'Non connecté';
    isSaving = true;
    notifyListeners();
    try {
      final bytes = await imageFile.readAsBytes();
      final path = '$userId/avatar.jpg';
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      final url = _supabase.storage.from('avatars').getPublicUrl(path);
      // Éviter que Flutter serve l'ancienne image depuis son cache mémoire
      if (profile?.avatarUrl != null) {
        NetworkImage(profile!.avatarUrl!).evict();
      }
      // Cache-buster stocké en DB — loadProfile() récupère aussi la bonne version
      final cacheBustedUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      await _supabase
          .from('profiles')
          .update({'avatar_url': cacheBustedUrl})
          .eq('id', userId);
      profile = profile?.copyWith(avatarUrl: cacheBustedUrl);
      return null;
    } catch (e) {
      debugPrint('uploadAvatar error: $e');
      return 'Erreur lors du téléchargement';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clear() {
    profile = null;
    error = null;
    _freelancers = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  static String _normalizeToken(String raw) {
    var value = raw.trim().toLowerCase();
    if (value.isEmpty) return value;
    const replacements = <String, String>{
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ì': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ò': 'o',
      'ó': 'o',
      'õ': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };
    replacements.forEach((from, to) {
      value = value.replaceAll(from, to);
    });
    return value.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
