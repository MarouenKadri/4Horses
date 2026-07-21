import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../app/widgets/app_brand_mark.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _version = '1.0.0';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('À propos', style: context.profilePageTitleStyle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          const Center(child: AppBrandMark()),
          AppGap.h8,
          Center(
            child: Text(
              'Version $_version',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ),
          AppGap.h28,
          Text(
            'Notre mission',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h10,
          Text(
            '4horses met en relation des clients qui ont besoin d\'un '
            'service — ménage, jardinage, bricolage et bien plus — avec '
            'des prestataires de confiance, disponibles près de chez eux. '
            'Un même compte peut publier des missions en tant que client '
            'et proposer ses services en tant que prestataire.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          AppGap.h28,
          _AboutSection(
            label: 'Informations légales',
            children: [
              _AboutTile(
                icon: Icons.description_outlined,
                title: 'Conditions générales d\'utilisation',
                onTap: () => _openUrl('https://4horses.app/terms'),
              ),
              _AboutTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () => _openUrl('https://4horses.app/privacy'),
              ),
            ],
          ),
          AppGap.h20,
          _AboutSection(
            label: 'Nous suivre',
            children: [
              _AboutTile(
                icon: Icons.language_rounded,
                title: 'Site web',
                onTap: () => _openUrl('https://4horses.app'),
              ),
              _AboutTile(
                icon: Icons.mail_outline_rounded,
                title: 'support@4horses.app',
                showChevron: false,
                onTap: () => _openUrl('mailto:support@4horses.app'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section label + rows plats ───────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _AboutSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDesign.radius14),
            border: Border.all(color: context.colors.border),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showChevron;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.colors.textSecondary),
            AppGap.w14,
            Expanded(
              child: Text(
                title,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.colors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
