import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/push/push_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'enum/user_role.dart';
import '../features/auth/data/models/registration_data.dart';
import '../features/auth/data/models/user_type.dart';
import '../features/auth/presentation/utils/auth_formatters.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserRole currentRole = UserRole.guest;
  UserRole? pendingRole;
  bool isLogged = false;
  bool isLoading = false;
  bool needsRoleSelection = false;
  String? error;
  int _switchToken = 0;

  String? get userId => _supabase.auth.currentUser?.id;

  bool get isGoogleUser {
    final identities = _supabase.auth.currentUser?.identities ?? [];
    return identities.any((i) => i.provider == 'google');
  }

  bool _isRegistering = false;
  bool _isLoadingProfile = false;
  bool profileIncomplete = false;
  StreamSubscription<AuthState>? _authSub;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        currentRole = UserRole.guest;
        isLogged = false;
        notifyListeners();
      } else if (data.event == AuthChangeEvent.signedIn &&
          data.session != null) {
        // Blocked during login() and register() which call _loadProfile directly.
        if (!_isRegistering) _loadProfile(data.session!.user.id);
        PushService.registerToken();
      } else if (data.event == AuthChangeEvent.initialSession &&
          data.session != null) {
        // Fires on app restart when a valid session is found in local storage.
        _loadProfile(data.session!.user.id);
        PushService.registerToken();
      } else if (data.event == AuthChangeEvent.tokenRefreshed &&
          data.session != null) {
        if (!isLogged) _loadProfile(data.session!.user.id);
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    // Prevent concurrent executions (e.g. initialSession + signedIn firing together).
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    try {
      final List data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId);

      String? userType;

      if (data.isEmpty) {
        // No profile row in DB — try to recreate it from auth metadata.
        // This happens after a DB purge in dev, or an orphaned auth session.
        final authUser = _supabase.auth.currentUser;
        final meta = authUser?.userMetadata ?? {};
        userType = meta['user_type'] as String?;

        if (userType == null) {
          needsRoleSelection = true;
          isLogged = false;
          notifyListeners();
          return;
        }

        // Recreate the missing profile row so the rest of the app works normally.
        try {
          await _supabase.from('profiles').upsert({
            'id': userId,
            'email': authUser?.email ?? '',
            'first_name': meta['first_name'] ?? '',
            'last_name': meta['last_name'] ?? '',
            if (meta['phone'] != null) 'phone': meta['phone'],
            if (meta['birth_date'] != null) 'birth_date': meta['birth_date'],
            if (meta['gender'] != null) 'gender': meta['gender'],
            'user_type': userType,
          });
          debugPrint('_loadProfile: profile row recreated from auth metadata');
        } catch (e) {
          debugPrint('_loadProfile: profile recreate failed: $e');
        }
      } else if ((data.first['user_type'] as String?) == null) {
        // Row exists but user_type is missing — fall back to auth metadata.
        userType =
            _supabase.auth.currentUser?.userMetadata?['user_type'] as String?;
        if (userType == null) {
          needsRoleSelection = true;
          isLogged = false;
          notifyListeners();
          return;
        }
      } else {
        userType = data.first['user_type'] as String;
      }

      final baseRole = userType == 'freelancer'
          ? UserRole.provider
          : UserRole.client;

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('role_$userId');
      currentRole = saved != null
          ? (saved == 'provider' ? UserRole.provider : UserRole.client)
          : baseRole;

      needsRoleSelection = false;
      profileIncomplete = false;
      isLogged = true;
    } catch (e) {
      debugPrint('_loadProfile error: $e');
      isLogged = true;
      // Fall back to the user's registered type from auth metadata rather than
      // hardcoding client, which would be wrong for freelancer accounts.
      final meta = _supabase.auth.currentUser?.userMetadata ?? {};
      final fallbackType = meta['user_type'] as String?;
      currentRole = fallbackType == 'freelancer'
          ? UserRole.provider
          : UserRole.client;
    } finally {
      _isLoadingProfile = false;
    }
    notifyListeners();
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<String?> signInWithGoogle() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      if (serverClientId == null ||
          serverClientId.isEmpty ||
          serverClientId == 'your-web-client-id-here') {
        return 'GOOGLE_WEB_CLIENT_ID manquant ou invalide dans .env';
      }

      final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return null; // user cancelled
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        isLoading = false;
        notifyListeners();
        return 'Erreur Google Sign-In';
      }
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('signInWithGoogle error: $e');
      error = 'Erreur lors de la connexion Google';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> completeGoogleSetup({
    required UserType userType,
    DateTime? birthDate,
    Gender? gender,
    String? phone,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'Erreur';
      await _supabase.from('profiles').upsert({
        'id': userId,
        'user_type': userType.name,
        if (birthDate != null)
          'birth_date': birthDate.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender.name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      currentRole = userType == UserType.freelancer
          ? UserRole.provider
          : UserRole.client;
      needsRoleSelection = false;
      isLogged = true;
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('completeGoogleSetup error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<String?> login(String email, String password) async {
    isLoading = true;
    _isRegistering =
        true; // prevent the signedIn listener from calling _loadProfile
    error = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) await _loadProfile(res.user!.id);
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('login error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Login téléphone OTP ─────────────────────────────────────────────────

  Future<String?> sendPhoneLoginOtp(String phone) async {
    try {
      debugPrint('sendPhoneLoginOtp: phone=$phone');
      await _supabase.auth.signInWithOtp(phone: phone);
      return null;
    } on AuthException catch (e) {
      debugPrint(
        'sendPhoneLoginOtp AuthException: ${e.message} (status=${e.statusCode})',
      );
      return _friendlyError(e.message);
    } catch (e) {
      debugPrint('sendPhoneLoginOtp error: $e');
      return 'Une erreur est survenue';
    }
  }

  Future<String?> verifyPhoneLoginOtp(String phone, String token) async {
    isLoading = true;
    _isRegistering = true;
    notifyListeners();
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      if (res.user != null) await _loadProfile(res.user!.id);
      return null;
    } on AuthException catch (e) {
      return _friendlyError(e.message);
    } catch (e) {
      debugPrint('verifyPhoneLoginOtp error: $e');
      return 'Une erreur est survenue';
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Inscription ──────────────────────────────────────────────────────────

  Future<String?> register(RegistrationData data) async {
    isLoading = true;
    _isRegistering = true;
    error = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signUp(
        email: data.email!,
        password: data.password!,
        data: {
          'first_name': data.firstName,
          'last_name': data.lastName,
          'phone': data.phone,
          'birth_date': data.birthDate?.toIso8601String().split('T').first,
          'gender': data.gender?.name,
          'user_type': data.userType?.name,
        },
      );
      if (res.user != null) {
        // Insert profile row — non-blocking (fails gracefully if RLS not set up yet)
        try {
          // 1. Upload photo si fournie
          String? avatarUrl;
          if (data.photo != null) {
            try {
              final bytes = await data.photo!.readAsBytes();
              final path = '${res.user!.id}/avatar.jpg';
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
              avatarUrl = _supabase.storage.from('avatars').getPublicUrl(path);
            } catch (e) {
              debugPrint('avatar upload warning (non-blocking): $e');
            }
          }

          // 2. Insérer le profil (email obligatoire — NOT NULL dans profiles)
          await _supabase.from('profiles').upsert({
            'id': res.user!.id,
            'email': data.email,
            'first_name': data.firstName,
            'last_name': data.lastName,
            'phone': data.phone,
            'birth_date': data.birthDate?.toIso8601String().split('T').first,
            'gender': data.gender?.name,
            'user_type': data.userType?.name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          });
        } catch (e) {
          debugPrint('profiles upsert warning (non-blocking): $e');
          profileIncomplete = true;
        }
        currentRole = data.userType == UserType.freelancer
            ? UserRole.provider
            : UserRole.client;
        needsRoleSelection = false;
        isLogged = true;
      }
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      debugPrint('register error: $e');
      error = 'Une erreur est survenue';
      return error;
    } finally {
      _isRegistering = false;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Switch de rôle ───────────────────────────────────────────────────────

  Future<void> switchRole(UserRole newRole) async {
    if (!isLogged || newRole == UserRole.guest || newRole == currentRole) {
      return;
    }
    final token = ++_switchToken;
    pendingRole = newRole;
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (token != _switchToken || !isLogged) return;
    currentRole = newRole;
    pendingRole = null;
    isLoading = false;

    // Persist the chosen role so it survives app restarts
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role_$userId', newRole.name);
    }

    notifyListeners();
  }

  // ─── Reset Password OTP ───────────────────────────────────────────────────

  Future<String?> sendPasswordResetOtp(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyPasswordResetOtp(String email, String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateEmail(String newEmail) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
      return null;
    } on AuthException catch (e) {
      error = _friendlyError(e.message);
      return error;
    } catch (e) {
      error = 'Une erreur est survenue : ${e.toString()}';
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Suppression de compte ────────────────────────────────────────────────

  /// Vérifie le mot de passe puis supprime définitivement le compte.
  /// Retourne null si succès, ou un message d'erreur.
  Future<String?> deleteAccount(String password) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Utilisateur non connecté';

    _isRegistering = true;
    try {
      return await _deleteAccountInner(user, password);
    } finally {
      _isRegistering = false;
    }
  }

  Future<String?> _deleteAccountInner(User user, String password) async {
    // 1. Re-authentifier — ignoré pour les comptes Google (pas de mot de passe)
    if (!isGoogleUser) {
      final email = user.email;
      if (email == null) return 'Email introuvable';
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException {
        return 'Mot de passe incorrect';
      } catch (_) {
        return 'Mot de passe incorrect';
      }
    }

    final userId = user.id;

    // 2. Supprimer les données via RPC (SECURITY DEFINER — s'exécute côté serveur)
    try {
      await _supabase.rpc('delete_my_account');
    } catch (rpcError) {
      debugPrint('delete_my_account RPC failed: $rpcError');
      return 'Erreur lors de la suppression du compte';
    }

    // 3. Déconnexion + nettoyage local
    await PushService.clearToken();
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role_$userId');
    _switchToken++;
    pendingRole = null;
    currentRole = UserRole.guest;
    isLogged = false;
    isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _switchToken++;
    pendingRole = null;
    await PushService.clearToken();
    await _supabase.auth.signOut();
    currentRole = UserRole.guest;
    isLogged = false;
    isLoading = false;
    notifyListeners();
  }

  // ─── Erreurs lisibles ─────────────────────────────────────────────────────

  String _friendlyError(String message) => friendlyAuthError(message);

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
