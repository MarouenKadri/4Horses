import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import 'reset_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    final canSend = _emailController.text.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          AppPageBody(
            useSafeAreaTop: true,
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppProgressHeader(
                    currentStep: 1,
                    totalSteps: 3,
                    onBack: () => Navigator.pop(context),
                    stepLabel: 'Adresse e-mail',
                  ),
                  AppGap.h32,
                  const AppPageHeaderBlock(
                    title: 'Mot de passe oublié ?',
                    subtitle:
                        'Entrez votre email pour recevoir un code de réinitialisation',
                  ),
                  AppGap.h32,
                  AppTextField(
                    label: 'Email',
                    hint: 'exemple@mail.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email requis';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  AppGap.h24,
                  const Spacer(),
                  AppButton(
                    label: 'Envoyer le code',
                    onPressed: _handleSendCode,
                    variant: ButtonVariant.black,
                    isLoading: _isLoading,
                    icon: Icons.send,
                  ),
                ],
              ),
            ),
          ),
          if (kbOpen && canSend)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(
                enabled: true,
                onTap: _handleSendCode,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final error = await context.read<AuthProvider>().sendPasswordResetOtp(
      email,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResetOtpPage(identifier: email)),
    );
  }
}
