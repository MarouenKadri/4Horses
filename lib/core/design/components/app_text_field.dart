import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppInputTokens — source unique de vérité.
// Modifier une valeur ici → tous les champs de l'app se mettent à jour.
// ─────────────────────────────────────────────────────────────────────────────

class AppInputTokens {
  const AppInputTokens._();

  /// Couleur de la bordure au focus (tous les champs).
  static const Color focusColor = AppColors.ink;

  /// Épaisseur de la bordure au focus.
  static const double focusBorderWidth = 2.0;

  /// Épaisseur de la bordure normale.
  static const double borderWidth = 1.0;

  /// Rayon pour les champs formulaire standard.
  static const double formRadius = 12.0;

  /// Rayon pour les champs compacts (téléphone, recherche).
  static const double compactRadius = 12.0;

  /// Padding standard des champs formulaire.
  static const EdgeInsets formPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 15,
  );

  /// Padding compact.
  static const EdgeInsets compactPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 13,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppInputDecorations — factories centralisées.
// Tous les champs passent ici. Ajuster AppInputTokens suffit.
// ─────────────────────────────────────────────────────────────────────────────

class AppInputDecorations {
  const AppInputDecorations._();

  // ── Champ formulaire standard ─────────────────────────────────────────────
  static InputDecoration formField(
    BuildContext context, {
    String? hintText,
    TextStyle? hintStyle,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? suffixIcon,
    Color? fillColor,
    EdgeInsetsGeometry contentPadding = AppInputTokens.formPadding,
    double radius = AppInputTokens.formRadius,
    bool noBorder = false,
    String? errorText,
  }) {
    final divider = context.colors.border;
    final br = BorderRadius.circular(radius);
    final side = noBorder ? BorderSide.none : BorderSide(color: divider);
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          hintStyle ??
          context.text.bodyMedium?.copyWith(
            color: context.colors.textHint,
            fontSize: AppFontSize.body,
          ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? context.colors.surfaceAlt,
      counterText: '',
      contentPadding: contentPadding,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: br, borderSide: side),
      enabledBorder: OutlineInputBorder(borderRadius: br, borderSide: side),
      focusedBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: noBorder
            ? BorderSide.none
            : const BorderSide(
                color: AppInputTokens.focusColor,
                width: AppInputTokens.focusBorderWidth,
              ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: noBorder
            ? BorderSide.none
            : const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: noBorder
            ? BorderSide.none
            : const BorderSide(
                color: AppColors.error,
                width: AppInputTokens.focusBorderWidth,
              ),
      ),
    );
  }

  // ── Case OTP ──────────────────────────────────────────────────────────────
  static InputDecoration otpCell(BuildContext context, {required bool filled}) {
    final br = BorderRadius.circular(AppInputTokens.formRadius);
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: filled ? context.colors.surfaceAlt : context.colors.background,
      border: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(
          color: filled ? context.colors.textPrimary : context.colors.border,
          width: filled
              ? AppInputTokens.borderWidth * 1.5
              : AppInputTokens.borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: const BorderSide(
          color: AppInputTokens.focusColor,
          width: AppInputTokens.focusBorderWidth,
        ),
      ),
    );
  }

  // ── Champ profil (bottom sheets) — fond blanc, sans bordure ─────────────
  static InputDecoration profileField(
    BuildContext context, {
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),
    double radius = 14.0,
  }) {
    final hintColor = readOnly
        ? context.colors.textTertiary
        : context.colors.textHint;
    OutlineInputBorder b({bool error = false, bool focus = false}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: (error || focus)
              ? BorderSide(
                  color: error ? AppColors.error : AppInputTokens.focusColor,
                  width: 1.5,
                )
              : BorderSide.none,
        );
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: AppFontSize.md,
        fontWeight: FontWeight.w400,
        color: hintColor,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      filled: true,
      fillColor: context.colors.surface,
      counterText: '',
      border: b(),
      enabledBorder: b(),
      focusedBorder: b(focus: true),
      disabledBorder: b(),
      errorBorder: b(error: true),
      focusedErrorBorder: b(error: true),
    );
  }

  // ── Barre de recherche ────────────────────────────────────────────────────
  static InputDecoration searchField(
    BuildContext context, {
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
  }) {
    final br = BorderRadius.circular(AppInputTokens.compactRadius);
    const noSide = BorderSide.none;
    return InputDecoration(
      hintText: hintText,
      hintStyle: context.appBarSearchHintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? context.colors.surfaceAlt,
      contentPadding: contentPadding,
      border: OutlineInputBorder(borderRadius: br, borderSide: noSide),
      enabledBorder: OutlineInputBorder(borderRadius: br, borderSide: noSide),
      focusedBorder: OutlineInputBorder(borderRadius: br, borderSide: noSide),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBaseField — contrat partagé par tous les champs de l'app.
//
// Pattern : Template Method
//   • AppBaseFieldState définit la structure (label + champ)
//   • buildInput() est le "trou" que chaque sous-classe remplit
//   • La gestion du FocusNode est centralisée ici une seule fois
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppBaseField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppBaseField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });
}

abstract class AppBaseFieldState<T extends AppBaseField> extends State<T> {
  late FocusNode _focusNode;

  /// Indique si ce champ a le focus — disponible dans toutes les sous-classes.
  bool get isFocused => _focusNode.hasFocus;

  /// Le FocusNode géré par la base — à passer au TextFormField de la sous-classe.
  FocusNode get fieldFocusNode => _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  // ── Template Method — chaque sous-classe implémente son propre champ ──────
  Widget buildInput(BuildContext context);

  // ── Label partagé — peut être surchargé si besoin ─────────────────────────
  Widget buildLabel(BuildContext context) {
    return Text(
      widget.label,
      style: context.text.bodyMedium?.copyWith(
        fontSize: AppFontSize.base,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [buildLabel(context), AppGap.h8, buildInput(context)],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextField — champ texte générique (hérite de AppBaseField).
// ─────────────────────────────────────────────────────────────────────────────

class AppTextField extends AppBaseField {
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;

  const AppTextField({
    super.key,
    required super.label,
    super.controller,
    super.validator,
    super.onChanged,
    super.onSubmitted,
    super.autofocus,
    super.focusNode,
    super.readOnly,
    super.onTap,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends AppBaseFieldState<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget buildInput(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: fieldFocusNode,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: context.text.titleSmall?.copyWith(
        fontSize: AppFontSize.lg,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.formField(
        context,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: context.colors.textSecondary,
                size: 22,
              )
            : null,
        suffixIcon:
            widget.suffixIcon ??
            (widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: context.colors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null),
        fillColor: isFocused
            ? context.colors.surface
            : context.colors.surfaceAlt,
      ),
    );
  }
}
