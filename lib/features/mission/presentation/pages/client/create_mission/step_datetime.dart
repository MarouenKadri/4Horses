import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'mission_step_ui.dart';

/// ─────────────────────────────────────────────────────────────
/// 📅 Step 2 — Date uniquement
/// ─────────────────────────────────────────────────────────────
class StepDate extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onCompleted;

  const StepDate({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final quickDates = [
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
      now.add(const Duration(days: 3)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'Quel jour ?',
            subtitle: 'Choisissez une date pour planifier votre mission.',
          ),
          const SizedBox(height: 30),
          Row(
            children: quickDates.map((date) {
              final isSelected =
                  selectedDate?.day == date.day &&
                  selectedDate?.month == date.month &&
                  selectedDate?.year == date.year;
              final isToday = date.day == now.day && date.month == now.month;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateSelected(date);
                    Future.delayed(
                      const Duration(milliseconds: 150),
                      onCompleted,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      right: date != quickDates.last ? 10 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppDesign.radius12),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.textPrimary
                            : context.colors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isToday
                              ? 'AUJ.'
                              : _dayName(date.weekday).toUpperCase(),
                          style: context.missionStepSectionLabelStyle.copyWith(
                            fontSize: AppFontSize.tinyHalf,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.8,
                          ),
                        ),
                        AppGap.h10,
                        Text(
                          '${date.day}',
                          style: context.missionSectionTitleStyle.copyWith(
                            fontSize: AppFontSize.h1,
                            height: 1,
                          ),
                        ),
                        AppGap.h6,
                        Text(
                          _monthName(date.month).toUpperCase(),
                          style: context.missionStepSectionLabelStyle.copyWith(
                            fontSize: AppFontSize.tinyHalf,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.8,
                          ),
                        ),
                        AppGap.h10,
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colors.textPrimary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppGap.h18,
          AppButton(
            label: 'Autre date',
            variant: ButtonVariant.outline,
            icon: Icons.calendar_month_outlined,
            iconTrailing: false,
            height: 54,
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 90)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.inkDark,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                HapticFeedback.selectionClick();
                onDateSelected(date);
                Future.delayed(const Duration(milliseconds: 150), onCompleted);
              }
            },
          ),
        ],
      ),
    );
  }

  String _dayName(int w) =>
      ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][w - 1];
  String _monthName(int m) => [
    'jan',
    'fev',
    'mar',
    'avr',
    'mai',
    'juin',
    'juil',
    'aout',
    'sep',
    'oct',
    'nov',
    'dec',
  ][m - 1];
}

/// ─────────────────────────────────────────────────────────────
/// ⏰ Step 3 — Heure uniquement
/// ─────────────────────────────────────────────────────────────
class StepTime extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final VoidCallback onCompleted;

  const StepTime({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeSelected,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final quickTimes = [
      const TimeOfDay(hour: 7, minute: 0),
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'À quelle heure ?',
            subtitle: 'Choisissez le créneau qui vous convient le mieux.',
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: quickTimes.map((time) {
              final isSelected =
                  selectedTime?.hour == time.hour &&
                  selectedTime?.minute == time.minute;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTimeSelected(time);
                  Future.delayed(
                    const Duration(milliseconds: 180),
                    onCompleted,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.textPrimary.withValues(alpha: 0.08)
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius12),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.textPrimary
                          : context.colors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: context.missionButtonStyle.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppGap.h18,
          AppButton(
            label: 'Autre heure',
            variant: ButtonVariant.outline,
            icon: Icons.schedule_outlined,
            iconTrailing: false,
            height: 54,
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.inkDark,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (time != null) {
                HapticFeedback.selectionClick();
                onTimeSelected(time);
                Future.delayed(const Duration(milliseconds: 180), onCompleted);
              }
            },
          ),
        ],
      ),
    );
  }
}
