import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/registration_data.dart';
import '../../utils/auth_formatters.dart';
import 'otp_verification_page.dart';

enum VerificationMethod { sms, email }

class VerificationMethodPage extends StatefulWidget {
  final RegistrationData data;
  final Widget? nextPage;
  final VoidCallback? onVerified;

  const VerificationMethodPage({
    super.key,
    required this.data,
    this.nextPage,
    this.onVerified,
  });

  @override
  State<VerificationMethodPage> createState() => _VerificationMethodPageState();
}

class _VerificationMethodPageState extends State<VerificationMethodPage> {
  VerificationMethod? _selectedMethod;
  bool _isLoading = false;

  bool get _hasPhone =>
      widget.data.phone != null && widget.data.phone!.isNotEmpty;

  String get _maskedPhone => maskPhone(widget.data.phone ?? '');
  String get _maskedEmail => maskEmail(widget.data.email ?? '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppProgressHeader(
              currentStep: 1,
              totalSteps: 3,
              onBack: () => Navigator.pop(context),
              stepLabel: 'Méthode de vérification',
            ),
            AppGap.h32,
            const AppPageHeaderBlock(
              title: 'Vérification',
              subtitle: 'Comment souhaitez-vous recevoir votre code ?',
            ),
            AppGap.h32,
            if (_hasPhone) ...[
              _MethodCard(
                icon: Icons.sms_rounded,
                title: 'Par SMS',
                subtitle: _maskedPhone,
                isSelected: _selectedMethod == VerificationMethod.sms,
                onTap: () =>
                    setState(() => _selectedMethod = VerificationMethod.sms),
              ),
              AppGap.h16,
            ],
            _MethodCard(
              icon: Icons.email_rounded,
              title: 'Par Email',
              subtitle: _maskedEmail,
              isSelected: _selectedMethod == VerificationMethod.email,
              onTap: () =>
                  setState(() => _selectedMethod = VerificationMethod.email),
            ),
            AppGap.h24,
            const AppInfoBanner(
              icon: Icons.info_rounded,
              message: 'Un code à 6 chiffres vous sera envoyé',
            ),
            const Spacer(),
            AppButton(
              label: 'Envoyer le code',
              onPressed: _selectedMethod != null ? _sendCode : null,
              variant: ButtonVariant.black,
              isLoading: _isLoading,
              isEnabled: _selectedMethod != null,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            data: widget.data,
            method: _selectedMethod!,
            nextPage: widget.nextPage,
            onVerified: widget.onVerified,
          ),
        ),
      );
    }
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
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
      child: AppSurfaceCard(
        padding: AppInsets.a20,
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius16),
        border: Border.all(
          color: isSelected
              ? context.colors.textPrimary
              : context.colors.border,
          width: isSelected ? 1.5 : 1,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: const BoxDecoration(),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.textPrimary.withValues(alpha: 0.08)
                      : context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDesign.radius14),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                  size: 22,
                ),
              ),
              AppGap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      subtitle,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: AppFontSize.base,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? context.colors.textPrimary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? context.colors.textPrimary
                        : context.colors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
