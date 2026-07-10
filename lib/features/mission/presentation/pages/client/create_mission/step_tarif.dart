import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'create_mission_models.dart';
import 'mission_step_ui.dart';

class StepTarif extends StatefulWidget {
  final String budgetType;
  final double hourlyRate;
  final double estimatedHours;
  final double fixedBudget;
  final Function(double) onHourlyRateChanged;
  final Function(double) onEstimatedHoursChanged;
  final Function(double) onFixedBudgetChanged;

  const StepTarif({
    super.key,
    required this.budgetType,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.fixedBudget,
    required this.onHourlyRateChanged,
    required this.onEstimatedHoursChanged,
    required this.onFixedBudgetChanged,
  });

  @override
  State<StepTarif> createState() => _StepTarifState();
}

class _StepTarifState extends State<StepTarif> {
  late TextEditingController _rateCtrl;
  late TextEditingController _fixedCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController(
      text: widget.hourlyRate > 0 ? widget.hourlyRate.round().toString() : '',
    );
    _fixedCtrl = TextEditingController(
      text: widget.fixedBudget > 0 ? widget.fixedBudget.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _fixedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.budgetType == CreateBudgetType.fixed
        ? _buildFixed()
        : _buildHourly();
  }

  Widget _buildHourly() {
    const quickRates = [15, 20, 25, 30, 40, 50, 65, 80];
    final total = widget.hourlyRate * widget.estimatedHours;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'Quel tarif horaire ?',
            subtitle:
                'Choisissez ou saisissez un montant adapte a votre mission.',
          ),
          const SizedBox(height: 30),
          _AmountInput(
            controller: _rateCtrl,
            label: 'Tarif horaire',
            suffix: 'EUR / h',
            onChanged: (v) {
              final val = double.tryParse(v);
              widget.onHourlyRateChanged(val ?? 0);
            },
          ),
          AppGap.h20,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickRates.map((rate) {
              final selected = widget.hourlyRate.round() == rate;
              return _RateChip(
                label: '$rate EUR/h',
                selected: selected,
                onTap: () {
                  widget.onHourlyRateChanged(rate.toDouble());
                  _rateCtrl.text = rate.toString();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 34),
          const MissionSectionLabel(label: 'Duree estimee'),
          AppGap.h14,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterBtn(
                icon: Icons.remove,
                onTap: () {
                  if (widget.estimatedHours > 1) {
                    widget.onEstimatedHoursChanged(widget.estimatedHours - 0.5);
                  }
                },
              ),
              AppGap.w28,
              Text(
                '${widget.estimatedHours.toStringAsFixed(widget.estimatedHours == widget.estimatedHours.truncateToDouble() ? 0 : 1)} h',
                style: context.missionSectionTitleStyle.copyWith(
                  fontSize: AppFontSize.h1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppGap.w28,
              _CounterBtn(
                icon: Icons.add,
                onTap: () {
                  if (widget.estimatedHours < 12) {
                    widget.onEstimatedHoursChanged(widget.estimatedHours + 0.5);
                  }
                },
              ),
            ],
          ),
          AppGap.h14,
          if (widget.hourlyRate > 0)
            Center(
              child: MissionStepHelper(
                text: 'Total estime : ${total.round()} EUR',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFixed() {
    const quickAmounts = [50, 100, 150, 200, 300, 500];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'Quel est votre budget ?',
            subtitle:
                'Renseignez un montant clair pour recevoir des propositions precises.',
          ),
          const SizedBox(height: 30),
          _AmountInput(
            controller: _fixedCtrl,
            label: 'Budget fixe',
            suffix: 'EUR',
            useLightHint: true,
            onChanged: (v) {
              widget.onFixedBudgetChanged(double.tryParse(v) ?? 0);
            },
          ),
          AppGap.h20,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAmounts.map((amount) {
              final selected = widget.fixedBudget.round() == amount;
              return _RateChip(
                label: '$amount EUR',
                selected: selected,
                onTap: () {
                  widget.onFixedBudgetChanged(amount.toDouble());
                  _fixedCtrl.text = amount.toString();
                },
              );
            }).toList(),
          ),
          AppGap.h14,
          const MissionStepHelper(
            text:
                'Vous pourrez ajuster ce montant plus tard avec votre prestataire.',
          ),
        ],
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final Function(String) onChanged;
  final bool useLightHint;

  const _AmountInput({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
    this.useLightHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: context.text.displayMedium?.copyWith(
        fontSize: AppFontSize.d3,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
        letterSpacing: -1,
      ),
      decoration:
          AppInputDecorations.profileField(
            context,
            hintText: '0',
            radius: AppDesign.radius12,
          ).copyWith(
            labelText: label,
            hintStyle: context.text.displayMedium?.copyWith(
              color: context.colors.textHint,
              fontSize: AppFontSize.d3,
              fontWeight: useLightHint ? FontWeight.w300 : FontWeight.w600,
              letterSpacing: -1,
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 18, 0, 18),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                suffix,
                style: context.missionStepMutedStyle.copyWith(
                  fontSize: AppFontSize.base,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            errorStyle: context.profileErrorStyle,
          ),
      onChanged: onChanged,
    );
  }
}

class _RateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.textPrimary.withValues(alpha: 0.08)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? context.colors.textPrimary
                : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: context.missionStepChipStyle.copyWith(
            color: selected
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border),
        ),
        child: Icon(icon, color: context.colors.textPrimary, size: 18),
      ),
    );
  }
}
