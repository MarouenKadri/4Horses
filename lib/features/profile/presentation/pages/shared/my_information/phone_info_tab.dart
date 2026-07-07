import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../profile_provider.dart';
import 'my_information_fields.dart';

class PhoneInfoTab extends StatefulWidget {
  const PhoneInfoTab({super.key});

  @override
  State<PhoneInfoTab> createState() => PhoneInfoTabState();
}

class PhoneInfoTabState extends State<PhoneInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final phone = profile?.phone?.isNotEmpty == true ? profile!.phone! : '—';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        ReadOnlyField(
          label: 'Numéro actuel',
          value: phone,
          icon: Icons.phone_outlined,
        ),
        AppGap.h24,
        Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileField(
                controller: _phoneCtrl,
                label: 'Nouveau numéro',
                hintText: 'Nouveau numéro',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final normalized = v.trim();
                  final digits = normalized.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 8 || digits.length > 15) {
                    return 'Numéro de téléphone invalide';
                  }
                  final current =
                      context.read<ProfileProvider>().profile?.phone ?? '';
                  if (normalized == current) {
                    return 'Doit être différent du numéro actuel';
                  }
                  return null;
                },
              ),
              AppGap.h16,
              const InlineHelper(
                text:
                    'Ce numéro est utilisé pour les notifications importantes.',
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
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final updated = current.copyWith(phone: _phoneCtrl.text.trim());
    final err = await profileProvider.updateProfile(updated);
    if (!mounted) return;

    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
      return;
    }

    _phoneCtrl.clear();
    showAppSnackBar(
      context,
      'Numéro de téléphone mis à jour',
      type: SnackBarType.success,
    );
  }
}
