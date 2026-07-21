import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../mixins/otp_timer_mixin.dart';
import '../../utils/auth_formatters.dart';
import '../../widgets/otp_input_row.dart';
import 'reset_password_page.dart';

class ResetOtpPage extends StatefulWidget {
  final String identifier;

  const ResetOtpPage({super.key, required this.identifier});

  @override
  State<ResetOtpPage> createState() => _ResetOtpPageState();
}

class _ResetOtpPageState extends State<ResetOtpPage>
    with OtpTimerMixin<ResetOtpPage> {
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
              stepLabel: 'Code de vérification',
            ),
            AppGap.h32,
            AppPageHeaderBlock(
              title: 'Vérification',
              subtitle: 'Code envoyé à\n${maskEmail(widget.identifier)}',
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

  Future<void> _handleResend() async {
    await context.read<AuthProvider>().sendPasswordResetOtp(widget.identifier);
    if (!mounted) return;
    for (var c in _controllers) {
      c.clear();
    }
    startResendTimer();
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleVerify() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final error = await context.read<AuthProvider>().verifyPasswordResetOtp(
      widget.identifier,
      _otpCode,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(identifier: widget.identifier),
      ),
    );
  }
}
