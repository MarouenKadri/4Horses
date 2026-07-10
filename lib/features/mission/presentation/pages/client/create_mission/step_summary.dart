import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import 'mission_step_ui.dart';

class StepSummary extends StatelessWidget {
  final String? service;
  final String? subService;
  final DateTime? date;
  final TimeOfDay? time;
  final String address;
  final String description;
  final List<String> photos;
  final String budgetType;
  final double totalBudget;
  final double estimatedHours;
  final List<Map<String, dynamic>> services;
  final bool isEdit;

  const StepSummary({
    super.key,
    required this.service,
    required this.subService,
    required this.date,
    required this.time,
    required this.address,
    required this.description,
    required this.photos,
    required this.budgetType,
    required this.totalBudget,
    required this.estimatedHours,
    required this.services,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final serviceData = services.firstWhere(
      (s) => s['id'] == service,
      orElse: () => <String, dynamic>{
        'name': '',
        'icon': Icons.help_outline_rounded,
        'color': AppColors.textTertiary,
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionStepHeader(
            title: 'Resume de votre mission',
            subtitle: isEdit
                ? 'Verifiez les details avant d\'enregistrer.'
                : 'Verifiez les details avant de publier.',
          ),
          AppGap.h24,
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppDesign.radius12),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(left: 1),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        serviceData['icon'] as IconData,
                        size: 22,
                        color: AppColors.gray700,
                      ),
                    ),
                    AppGap.w14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (subService?.isNotEmpty ?? false)
                                ? subService!
                                : serviceData['name'] as String,
                            style: context.missionEntityNameStyle.copyWith(
                              fontSize: AppFontSize.h2,
                            ),
                          ),
                          AppGap.h4,
                          Text(
                            serviceData['name'] as String,
                            style: context.missionStepMutedStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppGap.h20,
                Divider(height: 1, color: context.colors.divider),
                AppGap.h18,
                SummaryRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Date',
                  value: date != null
                      ? '${_getDayName(date!.weekday)} ${date!.day} ${_getMonthName(date!.month)}'
                      : '-',
                ),
                AppGap.h16,
                SummaryRow(
                  icon: Icons.schedule_outlined,
                  label: 'Heure',
                  value: time != null
                      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                      : '-',
                ),
                AppGap.h16,
                SummaryRow(
                  icon: Icons.place_outlined,
                  label: 'Adresse',
                  value: address.isNotEmpty ? address : '-',
                ),
                if (description.isNotEmpty) ...[
                  AppGap.h16,
                  SummaryRow(
                    icon: Icons.notes_outlined,
                    label: 'Description',
                    value: description,
                  ),
                ],
                if (photos.isNotEmpty) ...[
                  AppGap.h18,
                  const MissionSectionLabel(label: 'Photos'),
                  AppGap.h10,
                  SizedBox(
                    height: 84,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        final isLocalFile = !photo.startsWith('http');
                        return Container(
                          width: 84,
                          margin: EdgeInsets.only(
                            right: index < photos.length - 1 ? 10 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: context.colors.surfaceAlt,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isLocalFile
                                ? Image.file(
                                    File(photo),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const _BrokenPhoto(),
                                  )
                                : Image.network(
                                    photo,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const _BrokenPhoto(),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                AppGap.h22,
                Divider(height: 1, color: context.colors.divider),
                AppGap.h18,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budgetType == 'hourly'
                                ? 'Budget estime'
                                : budgetType == 'fixed'
                                ? 'Budget fixe'
                                : 'Sur devis',
                            style: context.missionSubtleCaptionStyle,
                          ),
                          if (budgetType == 'hourly') ...[
                            AppGap.h4,
                            Text(
                              '${estimatedHours.toStringAsFixed(estimatedHours.truncateToDouble() == estimatedHours ? 0 : 1)} heures estimees',
                              style: context.missionStepMutedStyle.copyWith(
                                fontSize: AppFontSize.mdHalf,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (budgetType != 'quote')
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${totalBudget.round()}',
                              style: context.missionStepHeadlineValueStyle,
                            ),
                            TextSpan(
                              text: ' EUR',
                              style: context.missionStepCurrencyStyle,
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Sur devis',
                        style: context.missionSectionTitleStyle.copyWith(
                          fontSize: AppFontSize.xl,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          AppGap.h18,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MissionStepHelper(
              text: isEdit
                  ? 'Vos modifications seront visibles immédiatement par les prestataires.'
                  : 'Votre demande sera transmise aux meilleurs experts disponibles.',
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    return months[month - 1];
  }
}

class SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.colors.textTertiary),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.missionSubtleCaptionStyle.copyWith(
                  fontSize: AppFontSize.xsHalf,
                ),
              ),
              AppGap.h4,
              Text(value, style: context.missionStepValueStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrokenPhoto extends StatelessWidget {
  const _BrokenPhoto();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: context.colors.textHint,
          size: 22,
        ),
      ),
    );
  }
}
