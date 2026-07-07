import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textPrimary,
          side: BorderSide(color: context.colors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleLogo(size: 20),
                  AppGap.w10,
                  Text(
                    'Continuer avec Google',
                    style: context.text.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            AppColors.googleBlue, // blue
            AppColors.googleGreen, // green
            AppColors.googleYellow, // yellow
            AppColors.googleRed, // red
            AppColors.googleBlue, // back to blue
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.08),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w700,
              color: AppColors.googleBlue,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
