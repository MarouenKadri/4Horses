import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/widgets/app_brand_mark.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../../mission/data/models/service_category.dart';
import '../../../../profile/profile_provider.dart';
import '../../../data/models/freelancer.dart';
import '../login/login_page.dart';
import '../register/register_flow.dart';

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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppBrandMark(),
                    AppGap.h12,
                    Text(
                      'Vos missions,\nnos mains.',
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: AppFontSize.h3,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                        height: 1.12,
                      ),
                    ),
                    AppGap.h14,

                    // ─── Galerie catégories + prestataires ───
                    const _DiscoveryCarousel(),
                    AppGap.h14,

                    // ─── Preuve chiffrée ───
                    Row(
                      children: [
                        const Expanded(
                          child: _StatCard(
                            value: '4.8★',
                            label: 'NOTE MOYENNE',
                          ),
                        ),
                        AppGap.w10,
                        Expanded(
                          child: _StatCard(
                            value: () {
                              final profileProvider = context
                                  .watch<ProfileProvider>();
                              final count = profileProvider.freelancers.length;
                              if (count == 0 &&
                                  profileProvider.isLoadingFreelancers) {
                                return '…';
                              }
                              return '$count+';
                            }(),
                            label: 'PRESTATAIRES',
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: context.colors.divider),
                    ),

                    // ─── Comment ça marche ───
                    Text(
                      'COMMENT ÇA MARCHE',
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    AppGap.h8,
                    const Expanded(child: _HowItWorksSteps()),
                  ],
                ),
              ),
            ),
            const _BottomAuthBar(),
          ],
        ),
      ),
    );
  }
}

// ─── Carte statistique ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: AppFontSize.h3,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.h4,
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Galerie catégories + prestataires ────────────────────────────────────────

class _DiscoveryCarousel extends StatefulWidget {
  const _DiscoveryCarousel();

  @override
  State<_DiscoveryCarousel> createState() => _DiscoveryCarouselState();
}

class _DiscoveryCarouselState extends State<_DiscoveryCarousel> {
  static final _fallbackFreelancers = <_DiscoveryFreelancer>[
    _DiscoveryFreelancer(
      const Freelancer(
        name: 'Fatima',
        job: 'Ménage · Repassage',
        rating: 4.9,
        subtitle: 'Ménage · Repassage',
        imageUrl:
            'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
      ),
      category: ServiceCategory.menage,
    ),
    _DiscoveryFreelancer(
      const Freelancer(
        name: 'Lucas',
        job: 'Bricolage · Montage',
        rating: 4.8,
        subtitle: 'Bricolage · Montage',
        imageUrl:
            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
      ),
      category: ServiceCategory.bricolage,
    ),
    _DiscoveryFreelancer(
      const Freelancer(
        name: 'Emma',
        job: 'Jardinage · Entretien',
        rating: 4.9,
        subtitle: 'Jardinage · Entretien',
        imageUrl:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
      ),
      category: ServiceCategory.jardinage,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  _DiscoveryFreelancer? _fromRow(Map<String, dynamic> row) {
    final firstName = (row['first_name'] ?? '') as String;
    final lastName = (row['last_name'] ?? '') as String;
    final fullName = '$firstName $lastName'.trim();
    final avatarUrl = (row['avatar_url'] ?? '') as String;
    final rawCategories = row['service_categories'];
    final categoryNames = ServiceCategory.resolveNames(rawCategories);
    // On n'affiche que les profils complets (photo + service renseignés) :
    // sinon la carte tombe sur des initiales et un badge générique.
    if (fullName.isEmpty || avatarUrl.isEmpty || categoryNames.isEmpty) {
      return null;
    }
    final firstRawCategory = (rawCategories is List && rawCategories.isNotEmpty)
        ? rawCategories.first
        : null;
    final ratingRaw = row['rating'];
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;
    final displayName = _capitalize(
      firstName.trim().isNotEmpty ? firstName.trim() : fullName,
    );
    return _DiscoveryFreelancer(
      Freelancer(
        name: displayName,
        job: categoryNames.first,
        rating: rating > 0 ? rating : 4.8,
        subtitle: categoryNames.join(' · '),
        imageUrl: avatarUrl,
        isVerified: (row['is_verified'] ?? false) as bool,
      ),
      category: ServiceCategory.resolve(firstRawCategory),
      freelancerId: row['id'] as String?,
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final loaded = context
        .watch<ProfileProvider>()
        .freelancers
        .map(_fromRow)
        .whereType<_DiscoveryFreelancer>()
        .toList(growable: false);
    final freelancers = loaded.isEmpty ? _fallbackFreelancers : loaded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESTATAIRES À LA UNE',
          style: context.text.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: context.colors.textTertiary,
          ),
        ),
        AppGap.h8,
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: freelancers.length,
            separatorBuilder: (_, __) => AppGap.w10,
            itemBuilder: (context, index) {
              final item = freelancers[index];
              return _FreelancerServiceCard(
                item: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreelancerProfileView(
                      freelancerId: item.freelancerId,
                      freelancerName: item.freelancer.name,
                      freelancerAvatar: item.freelancer.imageUrl,
                      rating: item.freelancer.rating,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DiscoveryFreelancer {
  final Freelancer freelancer;
  final ServiceCategory? category;
  final String? freelancerId;
  const _DiscoveryFreelancer(
    this.freelancer, {
    this.category,
    this.freelancerId,
  });
}

// ─── Carte prestataire — photo plein cadre, badge service unique ──────────────

class _FreelancerServiceCard extends StatelessWidget {
  final _DiscoveryFreelancer item;
  final VoidCallback onTap;
  const _FreelancerServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final f = item.freelancer;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        child: SizedBox(
          width: 112,
          height: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              f.imageUrl.isNotEmpty
                  ? Image.network(
                      f.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _FreelancerAvatarFallback(name: f.name),
                    )
                  : _FreelancerAvatarFallback(name: f.name),

              // ── Dégradé bas pour la lisibilité du texte ──
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.blackAlpha55,
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // ── Badge vérifié ──
              if (f.isVerified)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),

              // ── Nom + note ──
              Positioned(
                left: 10,
                right: 10,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.job.isNotEmpty) ...[
                      Text(
                        f.job,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      f.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    if (f.rating > 0) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.rating,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            f.rating.toStringAsFixed(1),
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreelancerAvatarFallback extends StatelessWidget {
  final String name;
  const _FreelancerAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.30),
            AppColors.primary.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: context.text.displayMedium?.copyWith(
            fontSize: AppFontSize.d2,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Étapes « Comment ça marche » ─────────────────────────────────────────────

class _HowItWorksSteps extends StatelessWidget {
  const _HowItWorksSteps();

  static const _steps = [
    (
      title: 'Décrivez votre besoin',
      subtitle: 'Service, date souhaitée et budget — ça prend une minute.',
    ),
    (
      title: 'Choisissez un prestataire',
      subtitle: 'Profils vérifiés, notés par la communauté.',
    ),
    (
      title: 'Suivez et payez en sécurité',
      subtitle: 'Paiement libéré uniquement après la mission.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _StepRow(
            index: i + 1,
            title: _steps[i].title,
            subtitle: _steps[i].subtitle,
            isFirst: i == 0,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _StepRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFirst ? AppColors.primaryDark : context.colors.surfaceAlt,
        border: Border.all(
          color: isFirst ? AppColors.primaryDark : context.colors.border,
          width: 1.5,
        ),
      ),
      child: Text(
        '$index',
        style: context.text.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: isFirst ? Colors.white : context.colors.textSecondary,
        ),
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.h2,
        Text(
          subtitle,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.textTertiary,
            height: 1.35,
          ),
        ),
      ],
    );

    if (isLast) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          circle,
          AppGap.w14,
          Expanded(child: body),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            bottom: 0,
            left: 13.25,
            child: Container(width: 1.5, color: context.colors.border),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              circle,
              AppGap.w14,
              Expanded(child: body),
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
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Créer un compte ──────────────────────────────────────────
              AppButton(
                label: 'Créer un compte',
                variant: ButtonVariant.black,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterFlow()),
                ),
              ),
              AppGap.h8,

              // ── Séparateur "OU" ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Divider(color: context.colors.divider, height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU',
                      style: context.text.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: context.colors.divider, height: 1),
                  ),
                ],
              ),
              AppGap.h8,

              // ── Se connecter ─────────────────────────────────────────────
              AppButton(
                label: 'Se connecter',
                variant: ButtonVariant.outline,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
