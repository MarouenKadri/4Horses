import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/registration_data.dart';
import '../../../data/models/user_type.dart';
import 'steps/register_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoogleOnboardingFlow — 4-step onboarding for Google Sign-In users
// Steps: Date de naissance → Genre → Téléphone → Type de compte
// ─────────────────────────────────────────────────────────────────────────────

class GoogleOnboardingFlow extends StatefulWidget {
  const GoogleOnboardingFlow({super.key});

  @override
  State<GoogleOnboardingFlow> createState() => _GoogleOnboardingFlowState();
}

class _GoogleOnboardingFlowState extends State<GoogleOnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // ── Data collected ─────────────────────────────────────────────────────────
  DateTime? _birthDate;
  Gender? _gender;
  final _phoneCtrl = TextEditingController();
  UserType? _userType;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

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

  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _birthDate != null;
      case 1:
        return _gender != null;
      case 2:
        return _phoneCtrl.text.trim().length >= 9;
      case 3:
        return _userType != null;
      default:
        return false;
    }
  }

  Future<void> _submit() async {
    if (_userType == null) return;
    setState(() => _isSubmitting = true);
    final error = await context.read<AuthProvider>().completeGoogleSetup(
      userType: _userType!,
      birthDate: _birthDate,
      gender: _gender,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      showAppSnackBar(context, error, type: SnackBarType.error);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    // Pages with text input where keyboard bar should appear
    const textSteps = {2};
    final kbOnTextStep = kbOpen && textSteps.contains(_page);
    final showKbBar = kbOnTextStep && _canAdvance();

    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: Column(
          children: [
            AppProgressHeader(
              currentStep: _page + 1,
              totalSteps: 4,
              onBack: _goBack,
              stepLabel: const [
                'Date de naissance',
                'Genre',
                'Téléphone',
                'Votre rôle',
              ][_page],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _BirthdateStep(
                    onChanged: (dt) => setState(() => _birthDate = dt),
                  ),
                  _GenderStep(
                    selected: _gender,
                    onSelected: (g) {
                      setState(() => _gender = g);
                      Future.delayed(const Duration(milliseconds: 280), () {
                        if (mounted && _page == 1) _advance();
                      });
                    },
                  ),
                  _PhoneStep(controller: _phoneCtrl),
                  _UserTypeStep(
                    selected: _userType,
                    onSelected: (ut) {
                      setState(() => _userType = ut);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted && _page == 3) _submit();
                      });
                    },
                  ),
                ],
              ),
            ),
            if (showKbBar)
              AppKeyboardActionBar(enabled: _canAdvance(), onTap: _advance)
            else if (!kbOpen)
              _BottomBar(
                page: _page,
                canAdvance: _canAdvance(),
                isSubmitting: _isSubmitting,
                onNext: _page == 3 ? _submit : _advance,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int page;
  final bool canAdvance;
  final bool isSubmitting;
  final VoidCallback onNext;

  const _BottomBar({
    required this.page,
    required this.canAdvance,
    required this.isSubmitting,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: AppButton(
        label: page == 3 ? 'Terminer' : 'Continuer',
        onPressed: canAdvance && !isSubmitting ? onNext : null,
        variant: ButtonVariant.black,
        isLoading: isSubmitting,
        isEnabled: canAdvance,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Date de naissance
// ─────────────────────────────────────────────────────────────────────────────

class _BirthdateStep extends StatefulWidget {
  final ValueChanged<DateTime?> onChanged;
  const _BirthdateStep({required this.onChanged});

  @override
  State<_BirthdateStep> createState() => _BirthdateStepState();
}

class _BirthdateStepState extends State<_BirthdateStep> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll('/', '').replaceAll(' ', '');
    if (digits.length < 8) {
      _error = null;
      widget.onChanged(null);
      setState(() {});
      return;
    }
    try {
      final day = int.parse(digits.substring(0, 2));
      final month = int.parse(digits.substring(2, 4));
      final year = int.parse(digits.substring(4, 8));
      final dt = DateTime(year, month, day);
      final now = DateTime.now();
      final age =
          now.year -
          dt.year -
          ((now.month < dt.month || (now.month == dt.month && now.day < dt.day))
              ? 1
              : 0);
      if (dt.day != day || dt.month != month) {
        _error = 'Date invalide';
        widget.onChanged(null);
      } else if (age < 18) {
        _error = 'Vous devez avoir 18 ans minimum';
        widget.onChanged(null);
      } else if (year < 1900) {
        _error = 'Année invalide';
        widget.onChanged(null);
      } else {
        _error = null;
        widget.onChanged(dt);
      }
    } catch (_) {
      _error = 'Date invalide';
      widget.onChanged(null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Votre date\nde naissance',
            subtitle: 'Nous vérifierons que vous avez bien 18 ans',
          ),
          AppGap.h40,
          AppDateField(
            label: 'Date de naissance',
            controller: _ctrl,
            onChanged: _onChanged,
            errorText: _error,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Genre
// ─────────────────────────────────────────────────────────────────────────────

class _GenderStep extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender> onSelected;

  const _GenderStep({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Votre genre',
            subtitle: 'Cette information reste confidentielle',
          ),
          AppGap.h40,
          for (final g in Gender.values) ...[
            RegisterSelectableCard(
              icon: g == Gender.homme
                  ? Icons.man_rounded
                  : g == Gender.femme
                  ? Icons.woman_rounded
                  : Icons.people_rounded,
              label: g.label,
              isSelected: selected == g,
              onTap: () => onSelected(g),
            ),
            AppGap.h12,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Téléphone
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Votre numéro\nde téléphone',
            subtitle: 'Pour être contacté par les clients',
          ),
          AppGap.h40,
          AppTextField(
            label: 'Téléphone',
            hint: '06 00 00 00 00',
            prefixIcon: Icons.phone_rounded,
            controller: controller,
            keyboardType: TextInputType.phone,
          ),
          AppGap.h16,
          const AppInfoBanner(
            icon: Icons.lock_outline_rounded,
            message: 'Votre numéro ne sera jamais partagé publiquement',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Type de compte
// ─────────────────────────────────────────────────────────────────────────────

class _UserTypeStep extends StatelessWidget {
  final UserType? selected;
  final ValueChanged<UserType> onSelected;

  const _UserTypeStep({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeaderBlock(
            title: 'Vous êtes…',
            subtitle: 'Choisissez votre profil pour continuer',
          ),
          AppGap.h40,
          RegisterSelectableCard(
            icon: Icons.search_rounded,
            label: 'Client',
            subtitle: 'Je cherche un prestataire',
            isSelected: selected == UserType.client,
            onTap: () => onSelected(UserType.client),
          ),
          AppGap.h12,
          RegisterSelectableCard(
            icon: Icons.work_rounded,
            label: 'Prestataire',
            subtitle: 'Je propose mes services',
            isSelected: selected == UserType.freelancer,
            onTap: () => onSelected(UserType.freelancer),
          ),
          AppGap.h24,
          const AppInfoBanner(
            icon: Icons.info_outline_rounded,
            message:
                'Vous pourrez changer de mode client/prestataire dans les paramètres',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared — Selectable card
// ─────────────────────────────────────────────────────────────────────────────
