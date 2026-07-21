import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design/app_design_system.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../../features/profile/profile_provider.dart';

class AppSheetProfileHeader extends StatelessWidget {
  final VoidCallback? onAccountTap;
  final bool dark;

  const AppSheetProfileHeader({
    super.key,
    this.onAccountTap,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final isClient = auth.currentRole == UserRole.client;
    final firstName = profile?.firstName ?? '';
    final avatarUrl = profile?.avatarUrl ?? '';
    final initials = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : (isClient ? 'C' : 'F');

    final textColor = dark ? AppColors.snow : context.colors.textPrimary;
    final subtitleColor = dark ? AppColors.gray500 : context.colors.textSecondary;
    final dividerColor = dark ? AppColors.whiteAlpha12 : context.colors.divider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAccountTap != null
                ? () {
                    Navigator.pop(context);
                    onAccountTap!();
                  }
                : null,
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AppBarMetrics.sheetAvatarSize,
                    height: AppBarMetrics.sheetAvatarSize,
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _AvatarFallback(
                              initials: initials,
                              dark: dark,
                            ),
                          )
                        : _AvatarFallback(initials: initials, dark: dark),
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName.isNotEmpty ? firstName : 'Mon compte',
                        style: context.appBarSheetAccountTitleStyle.copyWith(
                          fontSize: AppFontSize.body,
                          color: textColor,
                        ),
                      ),
                      AppGap.h2,
                      Text(
                        isClient ? 'Mode Client actif' : 'Mode Prestataire actif',
                        style: context.appBarSheetAccountSubtitleStyle.copyWith(
                          fontSize: AppFontSize.md,
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onAccountTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: subtitleColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: dividerColor),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;
  final bool dark;

  const _AvatarFallback({required this.initials, this.dark = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark
          ? Colors.white.withValues(alpha: 0.08)
          : context.colors.surfaceAlt,
      child: Center(
        child: Text(
          initials,
          style: context.appBarAvatarLabelStyle.copyWith(
            fontSize: AppBarMetrics.sheetAvatarFontSize,
            fontWeight: FontWeight.w600,
            color: dark ? AppColors.snow : context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
