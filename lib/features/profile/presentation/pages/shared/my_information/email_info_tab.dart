import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/auth_provider.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../profile_provider.dart';
import 'my_information_fields.dart';

class EmailInfoTab extends StatefulWidget {
  const EmailInfoTab({super.key});

  @override
  State<EmailInfoTab> createState() => EmailInfoTabState();
}

class EmailInfoTabState extends State<EmailInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final email = profile?.email ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        ReadOnlyField(
          label: 'Email actuel',
          value: email.isNotEmpty ? email : '—',
          icon: Icons.mail_outline_rounded,
        ),
        AppGap.h24,
        Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileField(
                controller: _newCtrl,
                label: 'Nouvel email',
                hintText: 'Nouvel email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final normalized = v.trim();
                  if (!RegExp(
                    r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(normalized)) {
                    return 'Adresse email invalide';
                  }
                  if (normalized == email) {
                    return "Doit être différent de l'email actuel";
                  }
                  return null;
                },
              ),
              AppGap.h12,
              ProfileField(
                controller: _confirmCtrl,
                label: 'Confirmer le nouvel email',
                hintText: 'Confirmer le nouvel email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  if (v.trim() != _newCtrl.text.trim()) {
                    return 'Les emails ne correspondent pas';
                  }
                  return null;
                },
              ),
              AppGap.h16,
              const InlineHelper(
                text:
                    'Un email de confirmation vous sera envoyé après modification.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> submitFromParent() => _submit();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final newEmail = _newCtrl.text.trim();
    final err = await context.read<AuthProvider>().updateEmail(newEmail);
    if (!mounted) return;

    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
      return;
    }

    _newCtrl.clear();
    _confirmCtrl.clear();
    showAppSnackBar(
      context,
      'Email mis à jour. Confirmez via le lien envoyé.',
      type: SnackBarType.success,
    );
  }
}
