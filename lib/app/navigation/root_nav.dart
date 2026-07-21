import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design/app_design_system.dart';

import '../auth_provider.dart';
import '../enum/user_role.dart';

import '../../features/auth/presentation/pages/home/home_page.dart';
import '../../features/auth/presentation/pages/register/google_onboarding_flow.dart';
import 'app_nav.dart';

class RootNav extends StatelessWidget {
  const RootNav({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.needsRoleSelection) {
      return const GoogleOnboardingFlow();
    }

    if (!auth.isLogged) {
      return const Scaffold(body: WelcomePage());
    }

    // _ModeSwitchSplash is only for role-switching (pendingRole set).
    // During login/logout, isLoading can be true but pendingRole is null — skip the splash.
    if (auth.isLoading && auth.pendingRole != null) {
      return _ModeSwitchSplash(targetRole: auth.pendingRole!);
    }

    return const AppNav();
  }
}

// ─── Splash de transition ─────────────────────────────────────────────────────

class _ModeSwitchSplash extends StatefulWidget {
  final UserRole targetRole;
  const _ModeSwitchSplash({required this.targetRole});

  @override
  State<_ModeSwitchSplash> createState() => _ModeSwitchSplashState();
}

class _ModeSwitchSplashState extends State<_ModeSwitchSplash>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _progressCtrl;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _progress;

  bool get _isClient => widget.targetRole == UserRole.client;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();

    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClient    = _isClient;
    final modeLabel   = isClient ? 'Mode Client'      : 'Mode Prestataire';
    final modeIcon    = isClient ? Icons.person_rounded : Icons.handyman_rounded;
    final modeTagline = isClient
        ? 'Préparation de votre espace client'
        : 'Préparation de votre espace prestataire';

    return Scaffold(
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BYRSA',
                      style: context.text.titleLarge?.copyWith(
                        fontSize: AppFontSize.xl,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    AppGap.h28,
                    AppIconCircle(
                      icon: modeIcon,
                      size: 64,
                      iconSize: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      iconColor: AppColors.primary,
                    ),
                    AppGap.h20,
                    Text(
                      modeLabel,
                      style: context.text.headlineSmall?.copyWith(
                        fontSize: AppFontSize.h2,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppGap.h8,
                    Text(
                      modeTagline,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: AppFontSize.base,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    AppGap.h28,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDesign.radius4),
                      child: SizedBox(
                        width: 180,
                        child: AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor: context.colors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ),
                    AppGap.h12,
                    Text(
                      'Changement de mode...',
                      style: context.text.bodySmall?.copyWith(
                        fontSize: AppFontSize.sm,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
