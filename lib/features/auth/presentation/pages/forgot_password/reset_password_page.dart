import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../app/navigation/root_nav.dart';

class ResetPasswordPage extends StatefulWidget {
  final String identifier;

  const ResetPasswordPage({super.key, required this.identifier});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_rebuild);
    _confirmController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    final canReset =
        _passwordController.text.length >= 8 &&
        _confirmController.text == _passwordController.text;

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
                    currentStep: 3,
                    totalSteps: 3,
                    onBack: () => Navigator.pop(context),
                    stepLabel: 'Nouveau mot de passe',
                  ),
                  AppGap.h32,
                  const AppPageHeaderBlock(
                    title: 'Nouveau mot de passe',
                    subtitle:
                        'Créez un mot de passe sécurisé pour votre compte',
                  ),
                  AppGap.h32,
                  AppTextField(
                    label: 'Nouveau mot de passe',
                    hint: 'Minimum 8 caractères',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    controller: _passwordController,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mot de passe requis';
                      }
                      if (value.length < 8) return 'Minimum 8 caractères';
                      return null;
                    },
                  ),
                  AppGap.h20,
                  AppTextField(
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    controller: _confirmController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  AppGap.h24,
                  const Spacer(),
                  AppButton(
                    label: 'Réinitialiser le mot de passe',
                    onPressed: _handleResetPassword,
                    variant: ButtonVariant.black,
                    isLoading: _isLoading,
                    icon: Icons.check,
                  ),
                ],
              ),
            ),
          ),
          if (kbOpen && canReset)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(
                enabled: true,
                onTap: _handleResetPassword,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await context.read<AuthProvider>().updatePassword(
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const _PasswordResetSuccessPage()),
      (route) => false,
    );
  }
}

class _PasswordResetSuccessPage extends StatelessWidget {
  const _PasswordResetSuccessPage();

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
                  color: AppColors.primary,
                ),
              ),
            ),
            AppGap.h32,
            Text(
              'Mot de passe modifié !',
              style: context.text.headlineSmall?.copyWith(
                fontSize: AppFontSize.h2,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppGap.h12,
            Text(
              'Votre mot de passe a été réinitialisé\navec succès. Vous pouvez maintenant\nvous connecter.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                fontSize: AppFontSize.body,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            AppGap.h48,
            AppButton(
              label: 'Se connecter',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RootNav()),
                  (_) => false,
                );
              },
              variant: ButtonVariant.black,
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }
}
