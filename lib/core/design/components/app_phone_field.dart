import 'package:flutter/material.dart';

import '../app_design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppPhoneField — hérite de AppBaseField.
// Gère le sélecteur de pays, le formatage par pays et l'indicatif.
// ─────────────────────────────────────────────────────────────────────────────

class AppPhoneField extends AppBaseField {
  /// Pays sélectionné par défaut (France si omis).
  final CountryCode? initialCountry;

  /// Appelé quand l'utilisateur change de pays.
  final ValueChanged<CountryCode>? onCountryChanged;

  const AppPhoneField({
    super.key,
    required super.label,
    super.controller,
    super.validator,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    this.initialCountry,
    this.onCountryChanged,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends AppBaseFieldState<AppPhoneField> {
  late CountryCode _country;

  @override
  void initState() {
    super.initState();
    _country = widget.initialCountry ?? kCountries.first;
  }

  Future<void> _showCountryPicker() async {
    await showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: CountryPickerSheet(
        selected: _country,
        onSelected: (c) {
          setState(() => _country = c);
          widget.onCountryChanged?.call(c);
          Navigator.pop(context);
          widget.controller?.clear();
        },
      ),
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: fieldFocusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneFormatter(_country.maxDigits)],
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      style: context.text.bodyLarge?.copyWith(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      ),
      decoration:
          AppInputDecorations.profileField(
            context,
            hintText: _country.hint,
            prefixIcon: GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_country.flag, style: context.text.headlineMedium),
                    AppGap.w4,
                    Text(
                      _country.dialCode,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    AppGap.w2,
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 16,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            radius: 18,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          ).copyWith(
            labelText: widget.label,
            errorStyle: context.profileErrorStyle,
          ),
    );
  }
}
