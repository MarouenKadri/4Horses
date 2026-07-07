import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Mot de passe', style: context.profilePageTitleStyle),
      ),
      bottomNavigationBar: AppActionFooter(
        child: AppButton(
          label: 'Enregistrer',
          onPressed: isLoading ? null : _submit,
          isLoading: isLoading,
          variant: ButtonVariant.black,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: [
            _PasswordField(
              controller: _currentCtrl,
              label: 'Mot de passe actuel',
              obscure: _hideCurrent,
              onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            AppGap.h16,
            _PasswordField(
              controller: _newCtrl,
              label: 'Nouveau mot de passe',
              hintText: 'Minimum 8 caractères',
              obscure: _hideNew,
              onToggle: () => setState(() => _hideNew = !_hideNew),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                if (v.length < 8) return 'Minimum 8 caractères';
                if (!v.contains(RegExp(r'[A-Za-z]'))) {
                  return 'Doit contenir au moins 1 lettre';
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return 'Doit contenir au moins 1 chiffre';
                }
                return null;
              },
            ),
            AppGap.h16,
            _PasswordField(
              controller: _confirmCtrl,
              label: 'Confirmer le nouveau mot de passe',
              obscure: _hideConfirm,
              onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                if (v != _newCtrl.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            AppGap.h16,
            const _InlineHelper(
              text:
                  'Utilisez au moins 8 caractères avec des lettres et des chiffres.',
            ),
            AppGap.h24,
            const _PasswordStrengthTips(),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthProvider>().updatePassword(
      _newCtrl.text.trim(),
    );
    if (!mounted) return;
    if (error != null) {
      showAppSnackBar(context, error, type: SnackBarType.error);
      return;
    }

    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    showAppSnackBar(
      context,
      'Mot de passe mis à jour',
      type: SnackBarType.success,
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.hintText,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration:
          AppInputDecorations.profileField(
            context,
            hintText: hintText ?? label,
            radius: 18,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: context.colors.textHint,
            ),
          ).copyWith(
            labelText: label,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            errorStyle: context.profileErrorStyle,
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: context.colors.textPrimary,
              ),
              onPressed: onToggle,
            ),
          ),
    );
  }
}

class _InlineHelper extends StatelessWidget {
  final String text;

  const _InlineHelper({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.text.bodyMedium?.copyWith(
        color: context.colors.textSecondary,
        height: 1.45,
      ),
    );
  }
}

class _PasswordStrengthTips extends StatelessWidget {
  const _PasswordStrengthTips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a14,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conseils de sécurité',
            style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h10,
          _tip(context, 'Au moins 8 caractères'),
          AppGap.h6,
          _tip(context, 'Mélangez lettres et chiffres'),
          AppGap.h6,
          _tip(context, 'Évitez les mots courants'),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: context.colors.textSecondary,
        ),
        AppGap.w8,
        Text(text, style: context.text.bodySmall),
      ],
    );
  }
}
