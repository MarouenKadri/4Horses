// Backward-compatible re-export. New code should use AppMap.picker() directly.
export '../../core/design/components/app_map.dart'
    show AppMap, AppMapSelection, AppMapPin, AppMapTile;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/design/components/app_map.dart';

/// Legacy alias — wraps [AppMap.picker] so existing call sites keep compiling.
class AppLocationPickerMap extends StatelessWidget {
  final LatLng? initialLatLng;
  final String initialAddress;
  final ValueChanged<AppMapSelection> onChanged;
  final double height;
  final String searchHintText;
  final String emptyLabel;
  final String tapHintText;

  const AppLocationPickerMap({
    super.key,
    required this.initialLatLng,
    required this.initialAddress,
    required this.onChanged,
    this.height = 220,
    this.searchHintText = 'Rechercher une adresse…',
    this.emptyLabel = 'Aucune localisation définie',
    this.tapHintText = 'Appuyez pour poser le pin',
  });

  @override
  Widget build(BuildContext context) {
    return AppMap.picker(
      initialLatLng: initialLatLng,
      initialAddress: initialAddress,
      onChanged: onChanged,
      height: height,
      searchHint: searchHintText,
      emptyLabel: emptyLabel,
      tapHint: tapHintText,
    );
  }
}

/// Legacy alias for [AppMapSelection].
typedef AppLocationSelection = AppMapSelection;
