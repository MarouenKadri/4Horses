import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/design/app_design_system.dart';

/// Carte de suivi en plein écran — ouverte depuis la mini-carte compacte
/// des pages de suivi (client/freelancer), pour voir le trajet en détail.
class TrackingMapPage extends StatelessWidget {
  final LatLng? freelancerPosition;
  final LatLng? destination;
  final Widget? freelancerMarker;
  final String address;

  const TrackingMapPage({
    super.key,
    required this.freelancerPosition,
    required this.destination,
    this.freelancerMarker,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Trajet',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: AppMap.tracking(
              freelancerPosition: freelancerPosition,
              destination: destination,
              freelancerMarker: freelancerMarker ?? const AppMapPuck(),
              waitingText: 'Localisation en cours…',
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  AppGap.w6,
                  Expanded(
                    child: Text(address, style: context.text.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
