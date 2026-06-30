import 'package:flutter/material.dart';

import '../app_design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppEmailField — hérite de AppBaseField.
// Keyboard email, autocorrect désactivé, icône mail intégrée.
// ─────────────────────────────────────────────────────────────────────────────

class AppEmailField extends AppBaseField {
  final String? hint;
  final TextInputAction? textInputAction;

  const AppEmailField({
    super.key,
    required super.label,
    super.controller,
    super.validator,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    this.hint,
    this.textInputAction,
  });

  @override
  State<AppEmailField> createState() => _AppEmailFieldState();
}

class _AppEmailFieldState extends AppBaseFieldState<AppEmailField> {
  @override
  Widget buildInput(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: fieldFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      style: context.text.bodyLarge?.copyWith(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: widget.hint ?? 'exemple@mail.com',
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          color: context.colors.textHint,
          size: 16,
        ),
        radius: 18,
      ).copyWith(
        labelText: widget.label,
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}
