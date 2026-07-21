import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';

class PaymentSecurityCard extends StatelessWidget {
  const PaymentSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppInsets.a18,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius14),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radius10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              AppGap.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SÉCURITÉ PAIEMENT',
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    'Votre protection à chaque étape',
                    style: context.text.labelMedium,
                  ),
                ],
              ),
            ],
          ),

          Divider(height: 24, color: context.colors.divider),

          // ─── Features ───
          _featureRow(
            context,
            Icons.shield_rounded,
            'Paiement sécurisé',
            'Fonds libérés uniquement à la fin',
          ),
          AppGap.h14,
          _featureRow(
            context,
            Icons.badge_rounded,
            'Identité vérifiée',
            'Chaque prestataire est contrôlé',
          ),
          AppGap.h14,
          _featureRow(
            context,
            Icons.star_rounded,
            'Avis authentiques',
            'Uniquement après mission réalisée',
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(subtitle, style: context.text.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
