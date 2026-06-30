import 'package:flutter/material.dart';
import '../tokens/app_spacing.dart';

/// Badge de statut générique : label coloré avec fond semi-transparent.
/// Usage : AppStatusBadge(label: mission.status.label, color: mission.status.color)
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 10.0 : 11.5;
    final hPad = compact ? 7.0 : 9.0;
    final vPad = compact ? 2.5 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.1,
        ),
      ),
    );
  }
}
