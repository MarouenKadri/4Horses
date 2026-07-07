import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';

class MissionStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const MissionStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.missionStepTitleStyle),
        AppGap.h8,
        Text(subtitle, style: context.missionStepSubtitleStyle),
      ],
    );
  }
}

class MissionStepHelper extends StatelessWidget {
  final String text;

  const MissionStepHelper({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.missionStepHelperStyle);
  }
}

class MissionSectionLabel extends StatelessWidget {
  final String label;

  const MissionSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.missionStepSectionLabelStyle,
    );
  }
}
