import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/app_design_system.dart';

// Widget OTP partagé — cases numériques avec navigation focus automatique.
// [length] définit le nombre de cases (défaut 4 pour la registration, 6 pour SMS login).
// [onComplete] est appelé dès que toutes les cases sont remplies.
// [onChanged] est appelé à chaque frappe (utile pour setState parent).
class OtpInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onComplete;
  final VoidCallback? onChanged;
  final int length;

  const OtpInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onComplete,
    this.onChanged,
    this.length = 4,
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = length <= 4 ? 68.0 : 52.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(length, (i) => _buildCell(context, i, cellSize)),
    );
  }

  Widget _buildCell(BuildContext context, int i, double cellSize) {
    final filled = controllers[i].text.isNotEmpty;
    return SizedBox(
      width: cellSize,
      height: 76,
      child: TextField(
        controller: controllers[i],
        focusNode: focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: context.text.displayMedium?.copyWith(
          color: context.colors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: AppInputDecorations.otpCell(context, filled: filled),
        onChanged: (v) {
          if (v.isNotEmpty && i < length - 1) focusNodes[i + 1].requestFocus();
          if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
          onChanged?.call();
          final code = controllers.map((c) => c.text).join();
          if (code.length == length) onComplete();
        },
      ),
    );
  }
}
