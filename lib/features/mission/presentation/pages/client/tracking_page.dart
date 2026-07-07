import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission.dart';
import '../../widgets/shared/mission_shared_widgets.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TrackingPage (Client) — carte temps réel synchronisée avec le freelancer
/// via Supabase Realtime broadcast channel `tracking:{missionId}`
/// ═══════════════════════════════════════════════════════════════════════════

class TrackingPage extends StatefulWidget {
  final Mission mission;
  const TrackingPage({super.key, required this.mission});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  LatLng? _freelancerPosition;
  LatLng? _destinationLatLng;

  double? _distanceKm;
  int _etaMinutes = 0;

  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
    _subscribeBroadcast();
    _geocodeDestination();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  // ── Dernière position persistée ───────────────────────────────

  Future<void> _loadLastPosition() async {
    try {
      final data = await Supabase.instance.client
          .from('missions')
          .select('tracking_lat, tracking_lng')
          .eq('id', widget.mission.id)
          .maybeSingle();
      if (!mounted || data == null) return;
      final lat = data['tracking_lat'];
      final lng = data['tracking_lng'];
      if (lat == null || lng == null) return;
      _applyPosition(LatLng((lat as num).toDouble(), (lng as num).toDouble()));
    } catch (_) {}
  }

  // ── Supabase Realtime ─────────────────────────────────────────

  void _subscribeBroadcast() {
    _channel =
        Supabase.instance.client
            .channel('db-tracking-${widget.mission.id}')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'missions',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: widget.mission.id,
              ),
              callback: (payload) {
                final data = payload.newRecord;
                final lat = data['tracking_lat'];
                final lng = data['tracking_lng'];
                if (lat == null || lng == null) return;
                _applyPosition(
                  LatLng((lat as num).toDouble(), (lng as num).toDouble()),
                );
              },
            )
          ..subscribe();
  }

  void _applyPosition(LatLng pos) {
    if (!mounted) return;
    setState(() => _freelancerPosition = pos);
    if (_destinationLatLng != null) _updateEta(pos);
  }

  // ── Géocodage destination ─────────────────────────────────────

  Future<void> _geocodeDestination() async {
    try {
      final place = await NominatimService.geocodeSingle(
        widget.mission.address.fullAddress,
      );
      if (!mounted || place == null) return;
      setState(() => _destinationLatLng = place.latLng);
      if (_freelancerPosition != null) _updateEta(_freelancerPosition!);
    } catch (_) {}
  }

  // ── ETA ───────────────────────────────────────────────────────

  void _updateEta(LatLng freelancer) {
    if (_destinationLatLng == null) return;
    final meters = const Distance()(freelancer, _destinationLatLng!);
    final km = meters / 1000;
    setState(() {
      _distanceKm = km;
      _etaMinutes = (km / 30 * 60).ceil().clamp(1, 999);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final isOnTheWay = widget.mission.status == MissionStatus.onTheWay;

    return Scaffold(
      body: Stack(
        children: [
          // ── Carte ─────────────────────────────────────────────
          Positioned.fill(
            child: AppMap.tracking(
              freelancerPosition: _freelancerPosition,
              destination: _destinationLatLng,
              waitingText: 'En attente de la position du prestataire…',
            ),
          ),

          // ── Bouton retour ─────────────────────────────────────
          Positioned(
            top: topPadding + 4,
            left: 4,
            child: Padding(
              padding: AppInsets.a8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDesign.radiusFull),
                  onTap: () => Navigator.pop(context),
                  child: AppIconCircle(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 42,
                    iconSize: 18,
                    backgroundColor: context.colors.surface,
                    iconColor: context.colors.textPrimary,
                    boxShadow: AppShadows.button,
                  ),
                ),
              ),
            ),
          ),

          // ── Titre ─────────────────────────────────────────────
          Positioned(
            top: topPadding + 12,
            left: 60,
            right: 60,
            child: Center(
              child: AppSurfaceCard(
                padding: AppInsets.h16v8,
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppDesign.radius20),
                boxShadow: AppShadows.card,
                child: Text(
                  isOnTheWay ? 'Prestataire en route' : 'Mission en cours',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // ── Carte ETA flottante ───────────────────────────────
          if (_distanceKm != null)
            Positioned(
              bottom: screenHeight * 0.35,
              left: 20,
              right: 20,
              child: _EtaCard(
                etaMinutes: _etaMinutes,
                distanceKm: _distanceKm!,
                color: isOnTheWay ? AppColors.secondary : AppColors.primary,
                label: isOnTheWay ? 'Arrivée estimée' : 'Mission en cours',
              ),
            ),

          // ── Panneau bas ───────────────────────────────────────
          AppScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (_, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              children: [_ClientTrackingPanel(mission: widget.mission)],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panneau inférieur client ─────────────────────────────────────────────────

class _ClientTrackingPanel extends StatelessWidget {
  final Mission mission;

  const _ClientTrackingPanel({required this.mission});

  @override
  Widget build(BuildContext context) {
    final presta = mission.assignedPresta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (presta != null) ...[
              UserAvatar(
                imageUrl: presta.avatarUrl,
                radius: 28,
                showVerified: presta.isVerified,
              ),
              AppGap.w14,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presta?.name ?? 'Prestataire',
                    style: context.text.titleLarge,
                  ),
                  AppGap.h2,
                  Row(
                    children: [
                      MissionStatusBadge(status: mission.status, compact: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (mission.status == MissionStatus.inProgress) ...[
          AppGap.h16,
          AppSurfaceCard(
            padding: AppInsets.a14,
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(AppDesign.radius14),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppGap.w10,
                Text(
                  'Mission en cours',
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        AppGap.h16,
        const Divider(height: 1),
        AppGap.h12,
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: AppColors.error,
            ),
            AppGap.w6,
            Expanded(
              child: Text(
                mission.address.fullAddress,
                style: context.text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Carte ETA flottante ──────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  final int etaMinutes;
  final double distanceKm;
  final Color color;
  final String label;

  const _EtaCard({
    required this.etaMinutes,
    required this.distanceKm,
    required this.color,
    required this.label,
  });

  String get _timeLabel {
    if (etaMinutes >= 60) return '${etaMinutes ~/ 60}h ${etaMinutes % 60}min';
    return '$etaMinutes min';
  }

  String get _distLabel => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule_rounded, color: color, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                AppGap.h2,
                Text(
                  _timeLabel,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _distLabel,
              style: context.text.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
