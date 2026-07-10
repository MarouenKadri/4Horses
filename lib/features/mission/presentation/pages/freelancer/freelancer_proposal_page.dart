import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FreelancerProposalPage — composer sa proposition (tarif + message)
///
/// Page dédiée, pas une sheet : composition avec clavier + engagement,
/// même paradigme que le composer de posts. Un swipe accidentel ne peut
/// plus faire perdre un message tapé.
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerProposalPage extends StatefulWidget {
  final Mission mission;
  final TextEditingController priceController;
  final TextEditingController messageController;
  final void Function(double price, String message) onSubmit;

  const FreelancerProposalPage({
    super.key,
    required this.mission,
    required this.priceController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  State<FreelancerProposalPage> createState() => _FreelancerProposalPageState();
}

class _FreelancerProposalPageState extends State<FreelancerProposalPage> {
  late final List<int> _quickAmounts;
  int _messageLength = 0;

  @override
  void initState() {
    super.initState();
    final base = widget.mission.budget.totalAmount.toInt();
    _quickAmounts = base > 0
        ? [
            (base * 0.8).round(),
            (base * 0.9).round(),
            base,
            (base * 1.1).round(),
            (base * 1.2).round(),
          ]
        : [50, 80, 100, 120, 150];
    _messageLength = widget.messageController.text.length;
    widget.messageController.addListener(_onMsg);
  }

  void _onMsg() {
    if (mounted) {
      setState(() => _messageLength = widget.messageController.text.length);
    }
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onMsg);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final priceText = widget.priceController.text;
    final canSubmit =
        priceText.isNotEmpty &&
        int.tryParse(priceText) != null &&
        int.parse(priceText) > 0;

    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header : ✕ + titre, comme le composer de posts ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.w14,
                  Expanded(
                    child: Text(
                      'Votre proposition',
                      style: context.text.headlineLarge?.copyWith(
                        fontSize: AppFontSize.xl,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Champs ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.mission.title} • ${widget.mission.formattedDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.missionEmphasisBodyStyle,
                    ),
                    AppGap.h24,
                    Text(
                      'Votre tarif',
                      style: context.missionSectionLabelStyle.copyWith(
                        letterSpacing: 0.2,
                      ),
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.priceController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: context.text.displayMedium?.copyWith(
                        fontSize: AppFontSize.h2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: context.colors.textPrimary,
                      ),
                      decoration:
                          AppInputDecorations.formField(
                            context,
                            hintText: '0',
                            hintStyle: context.text.displayMedium?.copyWith(
                              fontSize: AppFontSize.h2,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: context.colors.border,
                            ),
                            contentPadding: EdgeInsets.zero,
                            noBorder: true,
                            fillColor: Colors.transparent,
                          ).copyWith(
                            prefixText: '€ ',
                            prefixStyle: context.text.headlineLarge?.copyWith(
                              fontSize: AppFontSize.h3,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                          ),
                    ),
                    AppGap.h8,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((amount) {
                        final isActive =
                            widget.priceController.text == amount.toString();
                        return GestureDetector(
                          onTap: () {
                            widget.priceController.text = amount.toString();
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? context.colors.textPrimary.withValues(
                                      alpha: 0.08,
                                    )
                                  : context.colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? context.colors.textPrimary
                                    : context.colors.border,
                              ),
                            ),
                            child: Text(
                              '$amount €',
                              style: context.missionStepChipStyle.copyWith(
                                color: isActive
                                    ? context.colors.textPrimary
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AppGap.h28,
                    Row(
                      children: [
                        Text(
                          'Message au client',
                          style: context.missionSectionLabelStyle.copyWith(
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_messageLength/400',
                          style: context.missionSubtleCaptionStyle.copyWith(
                            color: context.colors.textHint,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.messageController,
                      maxLines: 5,
                      maxLength: 400,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                      style: context.missionBodyStyle.copyWith(height: 1.5),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText:
                            'Présentez-vous, vos atouts, votre expérience...',
                        hintStyle: context.missionBodyStyle.copyWith(
                          height: 1.5,
                          color: context.colors.textHint,
                        ),
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        radius: AppDesign.radius12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── CTA sticky ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
              decoration: BoxDecoration(
                color: context.colors.background,
                border: Border(top: BorderSide(color: context.colors.divider)),
              ),
              child: AppButton(
                label: 'Envoyer ma proposition',
                variant: ButtonVariant.black,
                isEnabled: canSubmit,
                onPressed: canSubmit
                    ? () => widget.onSubmit(
                        double.parse(widget.priceController.text),
                        widget.messageController.text,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
