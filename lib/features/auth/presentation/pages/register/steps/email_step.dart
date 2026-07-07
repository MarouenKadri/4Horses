import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'register_shared.dart';

class RegisterEmailStep extends StatelessWidget {
  final TextEditingController ctrl;
  final RegisterFieldStatus status;

  const RegisterEmailStep({
    super.key,
    required this.ctrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          registerPageHeader(
            context,
            'Votre email',
            'Pour vous connecter à votre compte',
          ),
          AppGap.h36,
          AppTextField(
            label: 'Adresse email',
            hint: 'exemple@mail.com',
            prefixIcon: Icons.email_outlined,
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
          ),
          AppGap.h12,
          RegisterFieldStatusRow(
            status: status,
            takenMessage: 'Cet email est déjà utilisé',
          ),
        ],
      ),
    );
  }
}
