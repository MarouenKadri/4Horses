import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'create_mission_models.dart';
import 'mission_step_ui.dart';

class StepBudgetType extends StatelessWidget {
  final String budgetType;
  final Function(String) onBudgetTypeChanged;
  final VoidCallback onCompleted;

  const StepBudgetType({
    super.key,
    required this.budgetType,
    required this.onBudgetTypeChanged,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'Comment souhaitez-vous payer ?',
            subtitle:
                'Choisissez la formule qui correspond le mieux à votre mission.',
          ),
          const SizedBox(height: 30),
          _BudgetTypeCard(
            icon: Icons.schedule_outlined,
            title: 'Paiement a l\'heure',
            subtitle: 'Payez selon le temps passe',
            isSelected: budgetType == CreateBudgetType.hourly,
            onTap: () {
              onBudgetTypeChanged(CreateBudgetType.hourly);
              Future.delayed(const Duration(milliseconds: 250), onCompleted);
            },
          ),
          AppGap.h14,
          _BudgetTypeCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget fixe',
            subtitle: 'Definissez un montant total',
            isSelected: budgetType == CreateBudgetType.fixed,
            onTap: () {
              onBudgetTypeChanged(CreateBudgetType.fixed);
              Future.delayed(const Duration(milliseconds: 250), onCompleted);
            },
          ),
        ],
      ),
    );
  }
}

class _BudgetTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(
            color: isSelected
                ? context.colors.textPrimary
                : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: context.colors.textSecondary),
            AppGap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isSelected
                  ? context.colors.textPrimary
                  : context.colors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
