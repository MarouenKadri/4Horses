import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/design/app_design_system.dart';

class ReadOnlyField extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  State<ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<ReadOnlyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ReadOnlyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileField(
      controller: _controller,
      label: widget.label,
      hintText: widget.label,
      icon: widget.icon,
      readOnly: true,
      showCursor: false,
      enableInteractiveSelection: false,
      canRequestFocus: false,
    );
  }
}

class ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool autocorrect;
  final bool readOnly;
  final bool? showCursor;
  final bool enableInteractiveSelection;
  final bool canRequestFocus;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final int maxLines;

  const ProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.autocorrect = false,
    this.readOnly = false,
    this.showCursor,
    this.enableInteractiveSelection = true,
    this.canRequestFocus = true,
    this.onTap,
    this.validator,
    this.textStyle,
    this.suffixText,
    this.suffixStyle,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      autocorrect: autocorrect,
      readOnly: readOnly,
      maxLines: maxLines,
      showCursor: showCursor,
      enableInteractiveSelection: enableInteractiveSelection,
      canRequestFocus: canRequestFocus,
      onTap: onTap,
      onChanged: onChanged,
      style:
          textStyle ??
          TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w400,
            color: context.colors.textPrimary,
          ),
      decoration:
          AppInputDecorations.profileField(
            context,
            hintText: hintText,
            radius: 18,
            readOnly: readOnly,
            prefixIcon: Icon(icon, size: 16, color: context.colors.textHint),
            suffixIcon: suffixIcon,
          ).copyWith(
            labelText: label,
            prefixIconConstraints: prefixIconConstraints,
            suffixText: suffixText,
            suffixStyle: suffixStyle,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            errorStyle: context.profileErrorStyle,
          ),
      validator: validator,
    );
  }
}

class InlineHelper extends StatelessWidget {
  final String text;

  const InlineHelper({super.key, required this.text});

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

String formatBirthDate(DateTime? birthDate) {
  if (birthDate == null) return '—';
  return '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}';
}

String formatGender(String? gender) {
  switch (gender) {
    case 'homme':
      return 'Homme';
    case 'femme':
      return 'Femme';
    case 'autre':
      return 'Autre';
    default:
      return '—';
  }
}
