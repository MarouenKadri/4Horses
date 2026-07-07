import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission_address.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📍 Page Carte — Lieu d'intervention (OpenStreetMap, aucune clé API)
/// ═══════════════════════════════════════════════════════════════════════════

class MissionMapPage extends StatefulWidget {
  final MissionAddress address;

  const MissionMapPage({super.key, required this.address});

  @override
  State<MissionMapPage> createState() => _MissionMapPageState();
}

class _MissionMapPageState extends State<MissionMapPage> {
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(48.8566, 2.3522);
  LatLng? _pinLatLng;
  bool _loading = false;
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.address.latitude != null && widget.address.longitude != null) {
      _pinLatLng = LatLng(widget.address.latitude!, widget.address.longitude!);
      _center = _pinLatLng!;
    } else {
      _geocode();
    }
  }

  Future<void> _geocode() async {
    final query = widget.address.fullAddress;
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final place = await NominatimService.geocodeSingle(query);
      if (!mounted) return;
      if (place == null) return;
      setState(() {
        _pinLatLng = place.latLng;
        _center = place.latLng;
      });
      _mapController.move(_center, 14.2);
    } catch (_) {
      // silencieux
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _focusMap() async {
    final target = _pinLatLng ?? _center;
    _mapController.move(target, 15.6);
    await Future.delayed(const Duration(milliseconds: 170));
    if (!mounted) return;
    setState(() => _sheetVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.mapSurface)),
          // ── Carte plein écran ──────────────────────────────────────────
          Positioned.fill(
            child: AppMap.preview(
              latLng: _pinLatLng,
              interactive: true,
              tile: AppMapTile.cartoLight,
              controller: _mapController,
              onTap: _focusMap,
            ),
          ),

          // ── Loader géocodage ──────────────────────────────────────────
          if (_loading)
            const Center(
              child: Card(
                child: Padding(
                  padding: AppInsets.a16,
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    stops: const [0.0, 0.22, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: topPadding + 8,
            left: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: context.colors.textTertiary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            bottom: _sheetVisible ? 0 : -220,
            left: 0,
            right: 0,
            child: _AddressCard(address: widget.address.fullAddress),
          ),
        ],
      ),
    );
  }
}

// ── Carte adresse ──────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final String address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 28,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.mapPin,
                  size: 18,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lieu d'intervention",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
