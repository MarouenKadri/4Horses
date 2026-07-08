import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/registration_data.dart';
import '../../mixins/otp_timer_mixin.dart';
import '../../utils/auth_formatters.dart';
import '../../widgets/otp_input_row.dart';
import 'verification_method_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final RegistrationData data;
  final VerificationMethod method;
  final Widget? nextPage;
  final VoidCallback? onVerified;

  const OtpVerificationPage({
    super.key,
    required this.data,
    required this.method,
    this.nextPage,
    this.onVerified,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with OtpTimerMixin<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isSms => widget.method == VerificationMethod.sms;

  String get _maskedDestination => _isSms
      ? maskPhone(widget.data.phone ?? '')
      : maskEmail(widget.data.email ?? '');

  String get _otpCode => _controllers.map((c) => c.text).join();

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
              currentStep: 2,
              totalSteps: 3,
              onBack: () => Navigator.pop(context),
              stepLabel: 'Code OTP',
            ),
            AppGap.h32,
            AppPageHeaderBlock(
              title: 'Entrez le code',
              subtitle:
                  'Code envoyé ${_isSms ? 'par SMS au' : 'par email à'}\n$_maskedDestination',
            ),
            AppGap.h40,
            OtpInputRow(
              controllers: _controllers,
              focusNodes: _focusNodes,
              onComplete: _handleVerify,
              onChanged: () => setState(() {}),
            ),
            AppGap.h32,
            Center(
              child: canResend
                  ? AppButton(
                      label: 'Renvoyer le code',
                      variant: ButtonVariant.ghost,
                      icon: Icons.refresh_rounded,
                      width: null,
                      onPressed: _handleResend,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 18,
                          color: context.colors.textSecondary,
                        ),
                        AppGap.w8,
                        Text(
                          'Renvoyer dans ${resendTimer}s',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
            AppGap.h24,
            const Spacer(),
            AppButton(
              label: 'Vérifier',
              onPressed: _otpCode.length == 4 ? _handleVerify : null,
              variant: ButtonVariant.black,
              isLoading: _isLoading,
              isEnabled: _otpCode.length == 4,
            ),
          ],
        ),
      ),
    );
  }

  void _handleResend() {
    for (var c in _controllers) {
      c.clear();
    }
    startResendTimer();
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleVerify() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (widget.onVerified != null) {
      Navigator.pop(context);
      widget.onVerified!();
    } else {
      final destination = widget.nextPage ?? _SuccessPage(data: widget.data);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    }
  }
}

class _SuccessPage extends StatelessWidget {
  final RegistrationData data;

  const _SuccessPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 70,
                  color: AppColors.ink,
                ),
              ),
            ),
            AppGap.h32,
            Text(
              'Bienvenue ${data.firstName} !',
              style: context.text.headlineMedium?.copyWith(
                fontSize: AppFontSize.h1Lg,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h12,
            Text(
              'Votre compte a été créé avec succès.\nVous pouvez maintenant utiliser BYRSA.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                fontSize: AppFontSize.body,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            AppGap.h48,
            AppButton(
              label: 'Commencer',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
              variant: ButtonVariant.black,
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
