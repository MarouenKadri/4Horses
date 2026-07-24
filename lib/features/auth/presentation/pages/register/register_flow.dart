import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/navigation/root_nav.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import '../../utils/auth_formatters.dart';
import '../../widgets/photo_picker.dart';
import 'steps/register_shared.dart';

enum _FieldCheckStatus { idle, checking, available, taken }

// ─────────────────────────────────────────────────────────────────────────────
// RegisterFlow — 9-step BlaBlaCar-style PageView registration
// Steps: Email → Nom → Date → Genre → Mot de passe → Téléphone → OTP → Rôle → Photo
// ─────────────────────────────────────────────────────────────────────────────

class RegisterFlow extends StatefulWidget {
  final String? initialEmail;

  const RegisterFlow({super.key, this.initialEmail});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  final _data = RegistrationData();
  final _pageController = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // ── Text controllers ──────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── Field availability checks ─────────────────────────────────────────────
  _FieldCheckStatus _emailStatus = _FieldCheckStatus.idle;
  _FieldCheckStatus _phoneStatus = _FieldCheckStatus.idle;
  Timer? _emailTimer;
  Timer? _phoneTimer;

  // ── Step state ────────────────────────────────────────────────────────────
  DateTime? _birthDate;
  Gender? _gender;
  UserType? _userType;
  File? _photo;
  CountryCode _selectedCountry = kCountries[0];

  static const _totalSteps = 6;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailCtrl.text = widget.initialEmail!;
    }
    _emailCtrl.addListener(_onEmailChanged);
    for (final c in [_firstCtrl, _lastCtrl, _passCtrl, _passConfirmCtrl]) {
      c.addListener(_rebuild);
    }
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  void _rebuild() => setState(() {});

  // ── Email check ───────────────────────────────────────────────────────────
  void _onEmailChanged() {
    setState(() {});
    _emailTimer?.cancel();
    final email = _emailCtrl.text.trim();
    final valid =
        email.contains('@') && email.lastIndexOf('.') > email.indexOf('@') + 1;
    if (!valid) {
      setState(() => _emailStatus = _FieldCheckStatus.idle);
      return;
    }
    setState(() => _emailStatus = _FieldCheckStatus.checking);
    _emailTimer = Timer(
      const Duration(milliseconds: 800),
      () => _checkEmail(email),
    );
  }

  Future<void> _checkEmail(String email) async {
    try {
      final exists = await Supabase.instance.client.rpc(
        'check_email_exists',
        params: {'p_email': email},
      );
      if (!mounted) return;
      setState(
        () => _emailStatus = exists == true
            ? _FieldCheckStatus.taken
            : _FieldCheckStatus.available,
      );
    } catch (_) {
      if (mounted) setState(() => _emailStatus = _FieldCheckStatus.idle);
    }
  }

  // ── Phone check ───────────────────────────────────────────────────────────
  void _onPhoneChanged() {
    setState(() {});
    _phoneTimer?.cancel();
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < _selectedCountry.maxDigits) {
      setState(() => _phoneStatus = _FieldCheckStatus.idle);
      return;
    }
    setState(() => _phoneStatus = _FieldCheckStatus.checking);
    _phoneTimer = Timer(
      const Duration(milliseconds: 800),
      () => _checkPhone(digits),
    );
  }

  Future<void> _checkPhone(String digits) async {
    try {
      final exists = await Supabase.instance.client.rpc(
        'check_phone_exists',
        params: {'p_phone': digits},
      );
      if (!mounted) return;
      setState(
        () => _phoneStatus = exists == true
            ? _FieldCheckStatus.taken
            : _FieldCheckStatus.available,
      );
    } catch (_) {
      if (mounted) setState(() => _phoneStatus = _FieldCheckStatus.idle);
    }
  }

  @override
  void dispose() {
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    _pageController.dispose();
    for (final c in [
      _emailCtrl,
      _firstCtrl,
      _lastCtrl,
      _passCtrl,
      _passConfirmCtrl,
      _phoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Arrow enable logic ────────────────────────────────────────────────────
  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _firstCtrl.text.trim().isNotEmpty &&
            _lastCtrl.text.trim().isNotEmpty;
      case 1:
        return _emailStatus == _FieldCheckStatus.available &&
            _phoneStatus == _FieldCheckStatus.available;
      case 2:
        return _birthDate != null && _gender != null;
      case 3:
        return _passCtrl.text.length >= 8 &&
            _passConfirmCtrl.text == _passCtrl.text;
      case 4:
        return _userType != null;
      case 5:
        return true;
      default:
        return false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  Future<void> _goNext() async {
    switch (_page) {
      case 0:
        _data.firstName = _firstCtrl.text.trim();
        _data.lastName = _lastCtrl.text.trim();
        _advance();
      case 1:
        _data.email = _emailCtrl.text.trim();
        final digits = _phoneCtrl.text.replaceAll(' ', '');
        final stripped = digits.startsWith('0') ? digits.substring(1) : digits;
        _data.phone = '${_selectedCountry.dialCode}$stripped';
        _advance();
      case 2:
        _data.birthDate = _birthDate;
        _data.gender = _gender;
        _advance();
      case 3:
        _data.password = _passCtrl.text;
        _advance();
      case 4:
        _data.userType = _userType;
        if (_userType == UserType.freelancer) {
          _advance();
        } else {
          await _submit();
        }
      case 5:
        _data.photo = _photo;
        await _submit();
    }
  }

  void _advance() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_page == 0) {
      Navigator.pop(context);
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final error = await context.read<AuthProvider>().register(_data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootNav()),
        (_) => false,
      );
    } else {
      showAppSnackBar(context, error, type: SnackBarType.error);
    }
  }

  // ── Auto-advance: UserType ────────────────────────────────────────────────
  void _onUserTypeSelected(UserType t) {
    setState(() => _userType = t);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _page != 4) return;
      _data.userType = t;
      if (t == UserType.freelancer) {
        _advance();
      } else {
        _submit();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    const textSteps = {0, 1, 2, 3};
    final kbOnTextStep = kbOpen && textSteps.contains(_page);
    final showKbBar = kbOnTextStep && _canAdvance();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          AppPageBody(
            useSafeAreaTop: true,
            child: Column(
              children: [
                AppProgressHeader(
                  currentStep: _page + 1,
                  totalSteps: _totalSteps,
                  onBack: _goBack,
                  stepLabel: const [
                    'Prénom & Nom',
                    'Email & Téléphone',
                    'Identité',
                    'Mot de passe',
                    'Votre rôle',
                    'Photo de profil',
                  ][_page],
                ),
                // ── PageView ──
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _NamePage(firstCtrl: _firstCtrl, lastCtrl: _lastCtrl),
                      _EmailPhonePage(
                        emailCtrl: _emailCtrl,
                        emailStatus: _emailStatus,
                        phoneCtrl: _phoneCtrl,
                        phoneStatus: _phoneStatus,
                        country: _selectedCountry,
                        onCountryChanged: (c) => setState(() {
                          _selectedCountry = c;
                          _phoneCtrl.clear();
                          _phoneStatus = _FieldCheckStatus.idle;
                        }),
                      ),
                      _BirthdateGenderPage(
                        selectedGender: _gender,
                        onGenderChanged: (g) => setState(() => _gender = g),
                        onBirthdateChanged: (d) =>
                            setState(() => _birthDate = d),
                      ),
                      _PasswordPage(
                        ctrl: _passCtrl,
                        confirmCtrl: _passConfirmCtrl,
                      ),
                      _UserTypePage(
                        selected: _userType,
                        onSelected: _onUserTypeSelected,
                      ),
                      _PhotoPage(
                        photo: _photo,
                        onPhotoChanged: (f) => setState(() => _photo = f),
                      ),
                    ],
                  ),
                ),
                // ── Bottom controls (hidden when keyboard is open on text steps) ──
                if (!kbOnTextStep) _buildBottom(),
              ],
            ),
          ),
          // ── Keyboard arrow bar ──
          if (showKbBar)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(
                enabled: _canAdvance(),
                onTap: _goNext,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    // Page 6 — Photo: full-width submit
    if (_page == 5) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Créer mon compte',
              variant: ButtonVariant.black,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _goNext,
            ),
            AppGap.h10,
            AppButton(
              label: 'Passer cette étape',
              variant: ButtonVariant.ghost,
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _data.photo = null;
                      _submit();
                    },
            ),
          ],
        ),
      );
    }

    // All other pages: circular arrow button
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          const Spacer(),
          _isSubmitting
              ? const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : AppArrowActionButton(
                  enabled: _canAdvance(),
                  onPressed: _goNext,
                ),
        ],
      ),
    );
  }
}

Widget _pageHeader(BuildContext context, String title, String subtitle) {
  return AppPageHeaderBlock(title: title, subtitle: subtitle);
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0 — Email + Téléphone (fusionnés)
// ─────────────────────────────────────────────────────────────────────────────

class _EmailPhonePage extends StatelessWidget {
  final TextEditingController emailCtrl;
  final _FieldCheckStatus emailStatus;
  final TextEditingController phoneCtrl;
  final _FieldCheckStatus phoneStatus;
  final CountryCode country;
  final ValueChanged<CountryCode> onCountryChanged;

  const _EmailPhonePage({
    required this.emailCtrl,
    required this.emailStatus,
    required this.phoneCtrl,
    required this.phoneStatus,
    required this.country,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Vos coordonnées',
            'Email et téléphone pour votre compte',
          ),
          AppGap.h36,
          AppTextField(
            label: 'Adresse email',
            hint: 'exemple@mail.com',
            prefixIcon: Icons.email_outlined,
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          AppGap.h12,
          _FieldStatusRow(
            status: emailStatus,
            takenMessage: 'Cet email est déjà utilisé',
          ),
          AppGap.h24,
          AppPhoneField(
            label: 'Téléphone',
            controller: phoneCtrl,
            initialCountry: country,
            onCountryChanged: onCountryChanged,
          ),
          AppGap.h12,
          _FieldStatusRow(
            status: phoneStatus,
            takenMessage: 'Ce numéro est déjà utilisé',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Nom & Prénom
// ─────────────────────────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  const _NamePage({required this.firstCtrl, required this.lastCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Comment vous appelez-vous ?',
            'Votre nom sera affiché sur votre profil',
          ),
          AppGap.h36,
          AppTextField(
            label: 'Prénom',
            hint: 'Jean',
            prefixIcon: Icons.person_outline_rounded,
            controller: firstCtrl,
          ),
          AppGap.h20,
          AppTextField(
            label: 'Nom',
            hint: 'Dupont',
            prefixIcon: Icons.badge_outlined,
            controller: lastCtrl,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Date de naissance (texte JJ/MM/AAAA)
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdatePage extends StatefulWidget {
  final ValueChanged<DateTime?> onChanged;
  const _BirthdatePage({required this.onChanged});

  @override
  State<_BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<_BirthdatePage> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = _ctrl.text;
    if (text.length < 10) {
      if (_error != null) setState(() => _error = null);
      widget.onChanged(null);
      return;
    }
    final parts = text.split('/');
    if (parts.length != 3) return;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null ||
        month == null ||
        year == null ||
        day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900) {
      setState(() => _error = 'Date invalide');
      widget.onChanged(null);
      return;
    }
    try {
      final date = DateTime(year, month, day);
      if (date.month != month || date.day != day) {
        setState(() => _error = 'Date invalide');
        widget.onChanged(null);
        return;
      }
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      if (age < 18) {
        setState(() => _error = 'Vous devez avoir au moins 18 ans');
        widget.onChanged(null);
        return;
      }
      setState(() => _error = null);
      widget.onChanged(date);
    } catch (_) {
      setState(() => _error = 'Date invalide');
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Date de naissance',
            'Vous devez avoir au moins 18 ans',
          ),
          AppGap.h40,
          AppDateField(
            label: 'Date de naissance',
            controller: _ctrl,
            errorText: _error,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Date de naissance + Genre (fusionnés)
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdateGenderPage extends StatefulWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<DateTime?> onBirthdateChanged;

  const _BirthdateGenderPage({
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onBirthdateChanged,
  });

  @override
  State<_BirthdateGenderPage> createState() => _BirthdateGenderPageState();
}

class _BirthdateGenderPageState extends State<_BirthdateGenderPage> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = _ctrl.text;
    if (text.length < 10) {
      if (_error != null) setState(() => _error = null);
      widget.onBirthdateChanged(null);
      return;
    }
    final parts = text.split('/');
    if (parts.length != 3) return;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null ||
        month == null ||
        year == null ||
        day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900) {
      setState(() => _error = 'Date invalide');
      widget.onBirthdateChanged(null);
      return;
    }
    try {
      final date = DateTime(year, month, day);
      if (date.month != month || date.day != day) {
        setState(() => _error = 'Date invalide');
        widget.onBirthdateChanged(null);
        return;
      }
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      if (age < 18) {
        setState(() => _error = 'Vous devez avoir au moins 18 ans');
        widget.onBirthdateChanged(null);
        return;
      }
      setState(() => _error = null);
      widget.onBirthdateChanged(date);
    } catch (_) {
      setState(() => _error = 'Date invalide');
      widget.onBirthdateChanged(null);
    }
  }

  ({IconData icon, String emoji}) _genderMeta(Gender g) {
    switch (g) {
      case Gender.homme:
        return (icon: Icons.person_rounded, emoji: '♂');
      case Gender.femme:
        return (icon: Icons.face_3_rounded, emoji: '♀');
      case Gender.autre:
        return (icon: Icons.people_rounded, emoji: '⚧');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Votre identité',
            'Ces informations restent privées',
          ),
          AppGap.h40,

          // ── Date de naissance ──
          AppDateField(
            label: 'Date de naissance',
            controller: _ctrl,
            errorText: _error,
          ),

          AppGap.h36,

          // ── Genre — label ──
          Text(
            'Votre genre',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h4,
          Text(
            'Cette information reste privée',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          AppGap.h16,

          // ── Genre — pills ──
          Row(
            children: Gender.values.map((g) {
              final selected = widget.selectedGender == g;
              final meta = _genderMeta(g);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: g != Gender.values.last ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => widget.onGenderChanged(g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.colors.textPrimary
                            : context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? context.colors.textPrimary
                              : context.colors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            meta.icon,
                            size: 26,
                            color: selected
                                ? Colors.white
                                : context.colors.textSecondary,
                          ),
                          AppGap.h8,
                          Text(
                            g.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 4 — Mot de passe (champ unique, toggle intégré)
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordPage extends StatelessWidget {
  final TextEditingController ctrl;
  final TextEditingController confirmCtrl;
  const _PasswordPage({required this.ctrl, required this.confirmCtrl});

  @override
  Widget build(BuildContext context) {
    final mismatch =
        confirmCtrl.text.isNotEmpty && confirmCtrl.text != ctrl.text;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Créez un mot de passe',
            'Au moins 8 caractères pour sécuriser votre compte',
          ),
          AppGap.h36,
          AppTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: ctrl,
            obscureText: true,
          ),
          AppGap.h16,
          _StrengthBar(password: ctrl.text),
          AppGap.h20,
          AppTextField(
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: confirmCtrl,
            obscureText: true,
          ),
          if (mismatch) ...[
            AppGap.h8,
            Row(
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                AppGap.w6,
                Text(
                  'Les mots de passe ne correspondent pas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final String password;
  const _StrengthBar({required this.password});

  int get _strength => passwordStrength(password);

  Color get _color {
    switch (_strength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.rating;
      default:
        return AppColors.ink;
    }
  }

  String get _label {
    switch (_strength) {
      case 0:
        return '';
      case 1:
        return 'Faible';
      case 2:
        return 'Moyen';
      case 3:
        return 'Fort';
      default:
        return 'Très fort';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _strength ? _color : context.colors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.micro),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_label.isNotEmpty) ...[
          AppGap.h6,
          Text(
            _label,
            style: context.text.labelMedium?.copyWith(color: _color),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget indicateur de statut (idle / checking / available / taken)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldStatusRow extends StatelessWidget {
  final _FieldCheckStatus status;
  final String takenMessage;
  const _FieldStatusRow({required this.status, required this.takenMessage});

  @override
  Widget build(BuildContext context) {
    if (status == _FieldCheckStatus.idle) return const SizedBox.shrink();
    final isChecking = status == _FieldCheckStatus.checking;
    final isAvailable = status == _FieldCheckStatus.available;
    final color = isChecking
        ? context.colors.textTertiary
        : isAvailable
        ? AppColors.success
        : AppColors.error;
    final icon = isChecking
        ? null
        : isAvailable
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final label = isChecking
        ? 'Vérification…'
        : isAvailable
        ? 'Disponible'
        : takenMessage;

    return Row(
      children: [
        if (isChecking)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Icon(icon, size: 16, color: color),
        AppGap.w6,
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 7 — Choisir rôle (auto-advance)
// ─────────────────────────────────────────────────────────────────────────────

class _UserTypePage extends StatelessWidget {
  final UserType? selected;
  final ValueChanged<UserType> onSelected;
  const _UserTypePage({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Qui êtes-vous ?',
            'Choisissez votre type de compte',
          ),
          AppGap.h36,
          ...UserType.values.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RegisterSelectableCard(
                icon: t == UserType.client
                    ? Icons.search_rounded
                    : Icons.handyman_outlined,
                label: t.label,
                subtitle: t.description,
                isSelected: selected == t,
                onTap: () => onSelected(t),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 8 — Photo de profil (freelancer uniquement)
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPage extends StatelessWidget {
  final File? photo;
  final ValueChanged<File?> onPhotoChanged;
  const _PhotoPage({required this.photo, required this.onPhotoChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Votre photo de profil',
            'Les profils avec photo reçoivent 5× plus de missions',
          ),
          AppGap.h40,

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: photo != null ? AppColors.ink : context.colors.border,
                  width: 2,
                ),
              ),
              padding: AppInsets.a8,
              child: PhotoPicker(
                photo: photo,
                size: 160,
                isCircle: true,
                onPhotoChanged: onPhotoChanged,
              ),
            ),
          ),
          AppGap.h12,
          Center(
            child: Text(
              photo != null
                  ? 'Appuyez pour modifier'
                  : 'Appuyez pour ajouter une photo',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
