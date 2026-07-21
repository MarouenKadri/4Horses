import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'user_common_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Composants partagés — Paiements (Client & Freelancer)
// ═══════════════════════════════════════════════════════════════════════════

// ─── Champ avec ombre ────────────────────────────────────────────────────────

class PaymentShadowField extends StatelessWidget {
  final Widget child;
  const PaymentShadowField({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppPaymentMetrics.shadowBlurRadius,
            offset: const Offset(0, AppPaymentMetrics.shadowOffsetY),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Bouton "Ajouter" unifié ──────────────────────────────────────────────────

class PaymentAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PaymentAddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppPaymentMetrics.addButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: AppPaymentMetrics.commonIconSize,
              color: context.colors.textSecondary,
            ),
            AppGap.w8,
            Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Titre de section (small caps) ───────────────────────────────────────────

class PaymentSectionLabel extends StatelessWidget {
  final String label;
  const PaymentSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.text.labelSmall?.copyWith(
        color: context.colors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
      ),
    );
  }
}

// ─── Note d'information sobre ─────────────────────────────────────────────────

class PaymentInfoNote extends StatelessWidget {
  final IconData icon;
  final String body;
  final String? title;

  const PaymentInfoNote({
    super.key,
    required this.icon,
    required this.body,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a14,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppPaymentMetrics.infoIconSize,
            color: context.colors.textTertiary,
          ),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h3,
                ],
                Text(
                  body,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet confirmation suppression ──────────────────────────────────────────

class PaymentDeleteConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onConfirm;

  const PaymentDeleteConfirmSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      title: title,
      color: context.colors.surface,
      footer: Column(
        children: [
          AppButton(
            label: 'Supprimer',
            variant: ButtonVariant.destructive,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
          AppGap.h12,
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppPaymentMetrics.deleteSheetIconWrapSize,
              height: AppPaymentMetrics.deleteSheetIconWrapSize,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: AppPaymentMetrics.deleteSheetIconSize,
              ),
            ),
          ),
          AppGap.h14,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile de transaction (partagée historique client & freelancer) ───────────

class PaymentTxTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const PaymentTxTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: AppInsets.h16v14,
        child: Row(
          children: [
            // ─── Icône ───
            Container(
              width: AppPaymentMetrics.txLeadingBoxSize,
              height: AppPaymentMetrics.txLeadingBoxSize,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(
                  AppPaymentMetrics.txLeadingRadius,
                ),
              ),
              child: Icon(
                icon,
                size: AppPaymentMetrics.commonIconSize,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.w14,
            // ─── Titre + sous-titre ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppGap.w12,
            // ─── Montant + badge ───
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPositive
                        ? AppColors.primary
                        : context.colors.textPrimary,
                  ),
                ),
                if (badge != null) ...[
                  AppGap.h3,
                  Text(
                    badge!,
                    style: context.text.labelSmall?.copyWith(
                      color: badgeColor ?? context.colors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pills de filtre (Tout / Revenus / ...) ───────────────────────────────────

class PaymentFilterPills extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  const PaymentFilterPills({
    super.key,
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppPaymentMetrics.filterPillHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.h16,
        itemCount: filters.length,
        separatorBuilder: (_, __) => AppGap.w8,
        itemBuilder: (context, i) {
          final f = filters[i];
          final active = f == selected;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: AppPaymentMetrics.filterAnimationMs,
              ),
              padding: AppInsets.h16,
              decoration: BoxDecoration(
                color: active ? context.colors.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: active
                      ? context.colors.textPrimary
                      : context.colors.border,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                f,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active
                      ? context.colors.background
                      : context.colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum PaymentMissionPipelineStage { secured, waiting24h, paid, dispute }

class PaymentMissionPipelineInline extends StatelessWidget {
  final PaymentMissionPipelineStage stage;
  final String? caption;

  const PaymentMissionPipelineInline({
    super.key,
    required this.stage,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = switch (stage) {
      PaymentMissionPipelineStage.secured => 0,
      PaymentMissionPipelineStage.waiting24h => 1,
      PaymentMissionPipelineStage.paid => 2,
      PaymentMissionPipelineStage.dispute => 1,
    };
    final accent = stage == PaymentMissionPipelineStage.dispute
        ? context.colors.error
        : context.colors.primary;
    final text = caption ?? _defaultCaption(stage);

    return Container(
      width: double.infinity,
      padding: AppInsets.h10v8,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PipelineDot(
                active: currentStep >= 0,
                done: currentStep > 0,
                accent: accent,
              ),
              _PipelineConnector(done: currentStep > 0, accent: accent),
              _PipelineDot(
                active: currentStep >= 1,
                done: currentStep > 1,
                accent: accent,
              ),
              _PipelineConnector(done: currentStep > 1, accent: accent),
              _PipelineDot(
                active: currentStep >= 2,
                done: false,
                accent: accent,
              ),
            ],
          ),
          AppGap.h4,
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  String _defaultCaption(PaymentMissionPipelineStage stage) {
    return switch (stage) {
      PaymentMissionPipelineStage.secured => 'Paiement sécurisé',
      PaymentMissionPipelineStage.waiting24h =>
        'Versement automatique sous 24h',
      PaymentMissionPipelineStage.paid => 'Paiement versé',
      PaymentMissionPipelineStage.dispute => 'Litige ouvert, versement bloqué',
    };
  }
}

class _PipelineDot extends StatelessWidget {
  final bool active;
  final bool done;
  final Color accent;

  const _PipelineDot({
    required this.active,
    required this.done,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: AppPaymentMetrics.pipelineDotSize,
        height: AppPaymentMetrics.pipelineDotSize,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      );
    }
    if (active) {
      return Container(
        width: AppPaymentMetrics.pipelineDotSize,
        height: AppPaymentMetrics.pipelineDotSize,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 1.3),
        ),
      );
    }
    return Container(
      width: AppPaymentMetrics.pipelineDotSize,
      height: AppPaymentMetrics.pipelineDotSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.border, width: 1.2),
      ),
    );
  }
}

class _PipelineConnector extends StatelessWidget {
  final bool done;
  final Color accent;

  const _PipelineConnector({required this.done, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: AppPaymentMetrics.pipelineConnectorHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: AppPaymentMetrics.pipelineConnectorMargin,
        ),
        decoration: BoxDecoration(
          color: done ? accent.withValues(alpha: 0.7) : context.colors.border,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

// ─── Sheet ajout carte — réutilisable (brand detection + auto-advance) ────────

enum _AddCardBrand { unknown, visa, mastercard, amex }

class AddCardSheet extends StatefulWidget {
  final void Function(String brand, String last4, String expiry) onCardAdded;
  const AddCardSheet({super.key, required this.onCardAdded});

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _nameFocus = FocusNode();

  _AddCardBrand _brand = _AddCardBrand.unknown;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  int get _maxDigits => _brand == _AddCardBrand.amex ? 15 : 16;
  int get _cvvLen => _brand == _AddCardBrand.amex ? 4 : 3;

  _AddCardBrand _detect(String digits) {
    if (digits.isEmpty) return _AddCardBrand.unknown;
    if (digits.startsWith('4')) return _AddCardBrand.visa;
    if (digits.length >= 2) {
      final p2 = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (p2 == 34 || p2 == 37) return _AddCardBrand.amex;
      if (p2 >= 51 && p2 <= 55) return _AddCardBrand.mastercard;
    }
    if (digits.length >= 4) {
      final p4 = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (p4 >= 2221 && p4 <= 2720) return _AddCardBrand.mastercard;
    }
    return _AddCardBrand.unknown;
  }

  void _onNumberChanged(String v) {
    final raw = v.replaceAll(' ', '');
    final newBrand = _detect(raw);
    final maxD = newBrand == _AddCardBrand.amex ? 15 : 16;

    final clamped = raw.length > maxD ? raw.substring(0, maxD) : raw;
    final formatted = clamped
        .replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m.group(0)} ')
        .trim();
    if (formatted != v) {
      _numberCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() => _brand = newBrand);
    if (clamped.length >= maxD) _expiryFocus.requestFocus();
  }

  void _onExpiryChanged(String v) {
    if (v.length == 2 && !v.contains('/')) {
      _expiryCtrl.value = TextEditingValue(
        text: '$v/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }
    setState(() {});
    if (_expiryCtrl.text.length >= 5) _cvvFocus.requestFocus();
  }

  void _onCvvChanged(String v) {
    if (v.length >= _cvvLen) _nameFocus.requestFocus();
  }

  String get _brandLabel => switch (_brand) {
    _AddCardBrand.visa => 'Visa',
    _AddCardBrand.mastercard => 'Mastercard',
    _AddCardBrand.amex => 'Amex',
    _AddCardBrand.unknown => 'Carte',
  };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final digits = _numberCtrl.text.replaceAll(' ', '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    Navigator.pop(context);
    widget.onCardAdded(_brandLabel, last4, _expiryCtrl.text);
  }

  Widget _brandBadge() {
    if (_brand == _AddCardBrand.unknown) return const SizedBox(width: 16);
    final (label, color) = switch (_brand) {
      _AddCardBrand.visa => ('VISA', AppColors.blueAction),
      _AddCardBrand.mastercard => ('MC', AppColors.mastercardOrange),
      _AddCardBrand.amex => ('AMEX', AppColors.ink),
      _AddCardBrand.unknown => ('', Colors.transparent),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(_brand),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: context.paymentBrandBadgeStyle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digits = _numberCtrl.text.replaceAll(' ', '');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Form(
        key: _formKey,
        child: AppSheetSurface(
          color: context.colors.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Header fixe ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppBottomSheetHandle(),
                      AppGap.h20,
                      Text(
                        'Ajouter une carte',
                        textAlign: TextAlign.center,
                        style: context.sheetFormTitleStyle,
                      ),
                      AppGap.h16,
                    ],
                  ),
                ),
                // ─── Zone scrollable bornée ───
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LiveCardPreview(
                          digits: digits,
                          expiry: _expiryCtrl.text,
                          name: _nameCtrl.text,
                          brand: _brand,
                        ),
                        AppGap.h16,
                        TextFormField(
                          controller: _numberCtrl,
                          keyboardType: TextInputType.number,
                          style: context.profileInputStyle.copyWith(
                            letterSpacing: 1.5,
                          ),
                          onChanged: _onNumberChanged,
                          decoration:
                              AppInputDecorations.profileField(
                                context,
                                hintText: '1234 5678 9012 3456',
                                radius: 18,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 10,
                                  ),
                                  child: Icon(
                                    Icons.credit_card_rounded,
                                    size: 16,
                                    color: context.colors.textHint,
                                  ),
                                ),
                              ).copyWith(
                                labelText: 'Numéro de carte',
                                errorStyle: context.profileErrorStyle,
                                suffixIcon: _brandBadge(),
                              ),
                          validator: (v) =>
                              (v == null ||
                                  v.replaceAll(' ', '').length < _maxDigits)
                              ? 'Numéro invalide'
                              : null,
                        ),
                        AppGap.h10,
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryCtrl,
                                focusNode: _expiryFocus,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                style: context.profileInputStyle,
                                onChanged: _onExpiryChanged,
                                decoration:
                                    AppInputDecorations.profileField(
                                      context,
                                      hintText: 'MM/AA',
                                      radius: 18,
                                    ).copyWith(
                                      labelText: 'Expiration',
                                      counterText: '',
                                      errorStyle: context.profileErrorStyle,
                                    ),
                                validator: (v) => (v == null || v.length < 5)
                                    ? 'Invalide'
                                    : null,
                              ),
                            ),
                            AppGap.w10,
                            Expanded(
                              child: TextFormField(
                                controller: _cvvCtrl,
                                focusNode: _cvvFocus,
                                keyboardType: TextInputType.number,
                                maxLength: _cvvLen,
                                obscureText: true,
                                style: context.profileInputStyle,
                                onChanged: _onCvvChanged,
                                decoration:
                                    AppInputDecorations.profileField(
                                      context,
                                      hintText: '•••',
                                      radius: 18,
                                    ).copyWith(
                                      labelText: 'CVV',
                                      counterText: '',
                                      errorStyle: context.profileErrorStyle,
                                    ),
                                validator: (v) =>
                                    (v == null || v.length < _cvvLen)
                                    ? 'Invalide'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        AppGap.h10,
                        TextFormField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setState(() {}),
                          style: context.profileInputStyle,
                          decoration:
                              AppInputDecorations.profileField(
                                context,
                                hintText: 'JEAN DUPONT',
                                radius: 18,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 10,
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: 16,
                                    color: context.colors.textHint,
                                  ),
                                ),
                              ).copyWith(
                                labelText: 'Titulaire de la carte',
                                errorStyle: context.profileErrorStyle,
                              ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nom requis'
                              : null,
                        ),
                        AppGap.h16,
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: context.colors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Données chiffrées · jamais stockées sur nos serveurs',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.textTertiary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ─── Footer fixe ───
                Divider(color: context.colors.divider, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileSheetPrimaryAction(
                        label: 'Ajouter la carte',
                        onPressed: _submit,
                      ),
                      AppGap.h12,
                      Center(
                        child: ProfileSheetSecondaryAction(
                          label: 'Annuler',
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Aperçu carte live ────────────────────────────────────────────────────────

class _LiveCardPreview extends StatelessWidget {
  final String digits;
  final String expiry;
  final String name;
  final _AddCardBrand brand;

  const _LiveCardPreview({
    required this.digits,
    required this.expiry,
    required this.name,
    required this.brand,
  });

  String get _displayNumber {
    final isAmex = brand == _AddCardBrand.amex;
    final maxLen = isAmex ? 15 : 16;
    final raw = digits.length > maxLen
        ? digits.substring(0, maxLen)
        : digits.padRight(maxLen, '•');
    if (isAmex) {
      return '${raw.substring(0, 4)}  ${raw.substring(4, 10)}  ${raw.substring(10, 15)}';
    }
    return '${raw.substring(0, 4)}  ${raw.substring(4, 8)}  ${raw.substring(8, 12)}  ${raw.substring(12, 16)}';
  }

  String get _brandLabel => switch (brand) {
    _AddCardBrand.visa => 'VISA',
    _AddCardBrand.mastercard => 'MASTERCARD',
    _AddCardBrand.amex => 'AMEX',
    _AddCardBrand.unknown => '',
  };

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'TITULAIRE' : name.toUpperCase();
    final displayExpiry = expiry.isEmpty ? '••/••' : expiry;

    return SizedBox(
      height: 172,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.inkDark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Chip + marque ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: brand == _AddCardBrand.unknown
                      ? const SizedBox(key: ValueKey('none'), width: 60)
                      : Text(
                          key: ValueKey(brand),
                          _brandLabel,
                          style: context.paymentCardBrandStyle,
                        ),
                ),
              ],
            ),
            const Spacer(),
            // ─── Numéro ────────────────────────────────────
            Text(_displayNumber, style: context.paymentCardNumberStyle),
            const SizedBox(height: 16),
            // ─── Expiry + nom ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXPIRE', style: context.paymentCardMicroLabelStyle),
                    const SizedBox(height: 2),
                    Text(displayExpiry, style: context.paymentCardExpiryStyle),
                  ],
                ),
                Text(
                  displayName,
                  style: name.trim().isEmpty
                      ? context.paymentCardNameStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.25),
                        )
                      : context.paymentCardNameStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
