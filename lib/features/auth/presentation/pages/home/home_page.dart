import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/widgets/app_brand_mark.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../widgets/google_sign_in_button.dart';
import '../login/login_page.dart';
import '../register/register_flow.dart';
import 'widgets/categories_section.dart';
import 'widgets/freelancers_section.dart';

// ─── Page d'accueil visiteur ──────────────────────────────────────────────────

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _HeroSection()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AppSectionHeader(
                          title: 'Catégories populaires',
                          padding: EdgeInsets.zero,
                        ),
                        AppGap.h14,
                        const CategoriesRow(),
                        AppGap.h16,
                        AppSectionHeader(
                          title: 'Prestataires de confiance',
                          padding: EdgeInsets.zero,
                        ),
                        AppGap.h6,
                        Text(
                          'Des prestataires vérifiés, notés par la communauté.',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        AppGap.h12,
                        const FreelancersRow(),
                        AppGap.h8,
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const _BottomAuthBar(),
          ],
        ),
      ),
    );
  }
}

// ─── Section hero ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Marque — la même que les homes connectés ───
          const AppBrandMark(),

          AppGap.h22,

          // ─── Titre principal ───
          Text(
            'Trouvez le prestataire\nqu\'il vous faut',
            style: context.text.bodyMedium?.copyWith(
              fontSize: AppFontSize.h2,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
              height: 1.2,
            ),
          ),
          AppGap.h10,
          Text(
            'Ménage, jardinage, bricolage et bien plus encore.',
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),

          AppGap.h16,

          // ─── Ligne de confiance — texte, pas de pilules ───
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 15, color: AppColors.rating),
              AppGap.w4,
              Text(
                '4.8',
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                ' · 10 000+ prestataires vérifiés',
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Barre fixe en bas : Créer un compte / Se connecter ──────────────────────

class _BottomAuthBar extends StatelessWidget {
  const _BottomAuthBar();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Google ──────────────────────────────────────────────────
              GoogleSignInButton(
                isLoading: auth.isLoading,
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final err = await context
                            .read<AuthProvider>()
                            .signInWithGoogle();
                        if (err != null && context.mounted) {
                          showAppSnackBar(
                            context,
                            err,
                            type: SnackBarType.error,
                          );
                        }
                      },
              ),
              AppGap.h14,

              // ── Créer un compte ──────────────────────────────────────────
              AppButton(
                label: 'Créer un compte',
                variant: ButtonVariant.black,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterFlow()),
                ),
              ),
              AppGap.h16,

              // ── Lien connexion ───────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: RichText(
                  text: TextSpan(
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                      fontSize: AppFontSize.md,
                    ),
                    children: [
                      const TextSpan(text: 'Déjà un compte ? '),
                      TextSpan(
                        text: 'Se connecter',
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: AppFontSize.md,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
