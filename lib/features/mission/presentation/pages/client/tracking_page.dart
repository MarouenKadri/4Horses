import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../shared/tracking_map_page.dart';
import 'client_mission_detail_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TrackingPage (Client) — statut + ETA en premier plan, carte réduite en
/// second plan. Statut synchronisé en direct via MissionProvider (souscription
/// Realtime déjà active), position via broadcast `missions.tracking_lat/lng`.
/// ═══════════════════════════════════════════════════════════════════════════

class TrackingPage extends StatefulWidget {
  final Mission mission;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const TrackingPage({
    super.key,
    required this.mission,
    this.onCall,
    this.onChat,
  });

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

  String _prestaName(Mission mission) =>
      mission.assignedPresta?.name ?? 'Votre prestataire';

  String _headline(Mission mission) => switch (mission.status) {
    MissionStatus.confirmed => '${_prestaName(mission)} arrive bientôt',
    MissionStatus.onTheWay => '${_prestaName(mission)} est en route',
    MissionStatus.inProgress => 'Mission en cours',
    MissionStatus.completionRequested => 'Fin de mission signalée',
    _ => 'Suivi de mission',
  };

  IconData _headlineIcon(MissionStatus status) => switch (status) {
    MissionStatus.confirmed => Icons.schedule_rounded,
    MissionStatus.onTheWay => Icons.directions_run_rounded,
    MissionStatus.inProgress => Icons.handyman_rounded,
    MissionStatus.completionRequested => Icons.task_alt_rounded,
    _ => Icons.location_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final liveMissions = context.watch<MissionProvider>().clientMissions;
    final mission = liveMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => widget.mission,
    );
    final status = mission.status;
    final hasLivePosition = _freelancerPosition != null;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Suivi de mission',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ── Statut narratif + ETA ──────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _headlineIcon(status),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    _headline(mission),
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_distanceKm != null && hasLivePosition) ...[
                    AppGap.h4,
                    Text(
                      status == MissionStatus.onTheWay
                          ? 'Arrivée estimée'
                          : 'Position en direct',
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                    Text(
                      _etaMinutes >= 60
                          ? '${_etaMinutes ~/ 60}h ${_etaMinutes % 60}min'
                          : '$_etaMinutes min',
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _distanceKm! < 1
                          ? '${(_distanceKm! * 1000).round()} m'
                          : '${_distanceKm!.toStringAsFixed(1)} km',
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h14,
            StatusTimeline(status: status),
            AppGap.h14,

            // ── Mini carte ──────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radius16),
              child: SizedBox(
                height: 150,
                child: AppMap.tracking(
                  freelancerPosition: _freelancerPosition,
                  destination: _destinationLatLng,
                  showWaiting: status != MissionStatus.confirmed,
                  waitingText: 'En attente de la position…',
                  compact: true,
                  initialZoom: 12,
                  interactive: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackingMapPage(
                        freelancerPosition: _freelancerPosition,
                        destination: _destinationLatLng,
                        address: mission.address.fullAddress,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AppGap.h8,
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                AppGap.w6,
                Expanded(
                  child: Text(
                    mission.address.fullAddress,
                    style: context.text.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppGap.h14,

            // ── Infos mission ────────────────────────────────────
            _ClientTrackingPanel(
              mission: mission,
              onCall: widget.onCall,
              onChat: widget.onChat,
            ),
            AppGap.h14,

            // ── Photo mission + titre ────────────────────────────
            MissionTrackingPreviewImage(
              mission: mission,
              height: 100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientMissionDetailPage(mission: mission),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panneau inférieur client ─────────────────────────────────────────────────

class _ClientTrackingPanel extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const _ClientTrackingPanel({required this.mission, this.onCall, this.onChat});

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
                radius: 22,
                showVerified: presta.isVerified,
              ),
              AppGap.w12,
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
                  MissionStatusBadge(status: mission.status, compact: true),
                ],
              ),
            ),
            if (onCall != null) ...[
              AppGap.w8,
              TrackingContactIconButton(
                icon: Icons.call_rounded,
                onTap: onCall!,
              ),
            ],
            if (onChat != null) ...[
              AppGap.w8,
              TrackingContactIconButton(
                icon: Icons.chat_bubble_rounded,
                onTap: onChat!,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
