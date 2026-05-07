import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';

class RoleSwitchSheet extends StatelessWidget {
  final String firstName;
  final String avatarUrl;
  final VoidCallback? onGoToAccount;

  const RoleSwitchSheet({
    super.key,
    required this.firstName,
    this.avatarUrl = '',
    this.onGoToAccount,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isClient = auth.currentRole == UserRole.client;
    final isLoading = auth.isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ─────────────────────────────────────────────
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          // ── Titre ──────────────────────────────────────────────
          Text(
            'Changer de mode',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          // ── Cards ──────────────────────────────────────────────
          _RoleCard(
            icon: Icons.person_rounded,
            label: 'Client',
            subtitle: 'Publiez des missions et\ntrouvez des prestataires',
            isSelected: isClient,
            onTap: isClient || isLoading
                ? null
                : () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().switchRole(UserRole.client);
                  },
          ),
          const SizedBox(height: 10),
          _RoleCard(
            icon: Icons.handyman_rounded,
            label: 'Prestataire',
            subtitle: 'Proposez vos services et\nrépondez aux missions',
            isSelected: !isClient,
            onTap: !isClient || isLoading
                ? null
                : () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().switchRole(UserRole.provider);
                  },
          ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(size: AppBarMetrics.loadingIndicatorSize),
                AppGap.w8,
                const Text(
                  'Changement en cours...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isSelected ? 0.15 : 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.inkDark,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
