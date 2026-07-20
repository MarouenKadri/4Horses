import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/location/nominatim_service.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';
import '../../../../../features/notifications/notification_provider.dart';

class FreelancerTrackingPage extends StatefulWidget {
  final Mission mission;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const FreelancerTrackingPage({
    super.key,
    required this.mission,
    this.onCall,
    this.onChat,
  });

  @override
  State<FreelancerTrackingPage> createState() => _FreelancerTrackingPageState();
}

class _FreelancerTrackingPageState extends State<FreelancerTrackingPage> {
  late Mission _mission;

  // GPS
  StreamSubscription<Position>? _positionSub;
  LatLng? _currentPosition;
  LatLng? _startPosition;
  bool _locationError = false;
  bool _autoOnTheWayTriggered = false;

  /// Distance parcourue depuis la position initiale qui vaut départ pour la
  /// mission — au-delà, on considère que le freelancer est réellement en
  /// route et on bascule le statut sans action manuelle.
  static const _autoOnTheWayDistanceMeters = 150;

  // Destination
  LatLng? _destinationLatLng;

  // ETA / distance
  double? _distanceKm;
  int _etaMinutes = 0;

  RealtimeChannel? _broadcastChannel;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _initBroadcastChannel();
    _startLocationTracking();
    _geocodeDestination();
  }

  void _initBroadcastChannel() {
    _broadcastChannel = Supabase.instance.client.channel(
      'tracking:${_mission.id}',
    )..subscribe();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _broadcastChannel?.unsubscribe();
    super.dispose();
  }

  // ── GPS ──────────────────────────────────────────────────────

  Future<void> _startLocationTracking() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationError = true);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      _onNewPosition(LatLng(pos.latitude, pos.longitude), moveMap: true);
    } catch (_) {}

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((pos) {
          if (!mounted) return;
          _onNewPosition(LatLng(pos.latitude, pos.longitude));
        });
  }

  void _onNewPosition(LatLng latlng, {bool moveMap = false}) {
    setState(() => _currentPosition = latlng);
    _startPosition ??= latlng;
    _updateDistanceEta(latlng);
    _broadcastPosition(latlng);
    _maybeAutoTriggerOnTheWay(latlng);
  }

  /// Bascule automatiquement `confirmed` → `onTheWay` dès qu'un déplacement
  /// significatif est détecté depuis la position initiale — évite d'exiger
  /// un clic manuel "Je suis en route" quand le GPS le sait déjà.
  Future<void> _maybeAutoTriggerOnTheWay(LatLng current) async {
    if (_autoOnTheWayTriggered) return;
    if (_mission.status != MissionStatus.confirmed) return;
    final start = _startPosition;
    if (start == null) return;
    final movedMeters = const Distance()(start, current);
    if (movedMeters < _autoOnTheWayDistanceMeters) return;
    _autoOnTheWayTriggered = true;
    final before = _mission.status;
    await _updateStatus(MissionStatus.onTheWay);
    if (mounted && _mission.status == before) {
      // L'update a échoué (voir _updateStatus) — autoriser un nouvel essai
      // au prochain déplacement plutôt que de rester bloqué silencieusement.
      _autoOnTheWayTriggered = false;
    }
  }

  void _broadcastPosition(LatLng latlng) {
    _broadcastChannel?.sendBroadcastMessage(
      event: 'position',
      payload: {'lat': latlng.latitude, 'lng': latlng.longitude},
    );
    Supabase.instance.client
        .from('missions')
        .update({
          'tracking_lat': latlng.latitude,
          'tracking_lng': latlng.longitude,
          'tracking_updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', _mission.id)
        .then((_) {})
        .catchError((_) {});
  }

  // ── Géocodage ────────────────────────────────────────────────

  Future<void> _geocodeDestination() async {
    try {
      final place = await NominatimService.geocodeSingle(
        _mission.address.fullAddress,
      );
      if (!mounted || place == null) return;
      setState(() => _destinationLatLng = place.latLng);
      if (_currentPosition != null) _updateDistanceEta(_currentPosition!);
    } catch (_) {}
  }

  // ── ETA & distance ───────────────────────────────────────────

  void _updateDistanceEta(LatLng current) {
    if (_destinationLatLng == null) return;
    final meters = const Distance()(current, _destinationLatLng!);
    final km = meters / 1000;
    setState(() {
      _distanceKm = km;
      _etaMinutes = (km / 30 * 60).ceil().clamp(1, 999);
    });
  }

  // ── Recentrage ───────────────────────────────────────────────

  // ── Statut mission ───────────────────────────────────────────

  Future<void> _updateStatus(MissionStatus newStatus) async {
    try {
      await context.read<MissionProvider>().updateMissionStatus(
        _mission.id,
        newStatus,
      );
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Impossible de mettre à jour le statut. Vérifiez votre connexion et réessayez.',
          icon: Icons.error_outline_rounded,
        );
      }
      return;
    }
    if (!mounted) return;

    final notifProvider = context.read<NotificationProvider>();
    final (title, body) = switch (newStatus) {
      MissionStatus.onTheWay => (
        'Prestataire en route',
        '${_mission.assignedPresta?.name ?? 'Votre prestataire'} est en route pour "${_mission.title}"',
      ),
      MissionStatus.inProgress => (
        'Mission démarrée',
        '"${_mission.title}" est maintenant en cours',
      ),
      MissionStatus.completionRequested => (
        'Fin de mission signalée',
        '"${_mission.title}" attend maintenant la réponse du client',
      ),
      _ => ('', ''),
    };

    // Notifier le client via Supabase Realtime
    if (title.isNotEmpty && _mission.client != null) {
      notifProvider.sendNotification(
        _mission.client!.id,
        type: NotifType.mission,
        targetRole: NotifTargetRole.client,
        title: title,
        body: body,
      );
    }

    setState(() => _mission = _mission.copyWith(status: newStatus));
  }

  Future<void> _startMission() async {
    final ok = await context.read<MissionProvider>().startMission(_mission.id);
    if (!mounted) return;
    if (ok) {
      showAppSnackBar(
        context,
        'Mission démarrée.',
        icon: Icons.check_circle_rounded,
      );
    } else {
      showAppSnackBar(
        context,
        'Impossible de démarrer la mission. Réessayez.',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  String get _headline => switch (_mission.status) {
    MissionStatus.confirmed => 'Prêt pour le départ',
    MissionStatus.onTheWay => 'En route vers le client',
    MissionStatus.inProgress => 'Mission en cours',
    MissionStatus.completionRequested => 'Fin signalée',
    MissionStatus.awaitingRelease => 'Mission terminée',
    _ => 'Suivi de mission',
  };

  IconData get _headlineIcon => switch (_mission.status) {
    MissionStatus.confirmed => Icons.schedule_rounded,
    MissionStatus.onTheWay => Icons.directions_run_rounded,
    MissionStatus.inProgress => Icons.handyman_rounded,
    MissionStatus.completionRequested => Icons.task_alt_rounded,
    _ => Icons.location_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final liveMissions = context.watch<MissionProvider>().freelancerMissions;
    final live = liveMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => _mission,
    );
    if (live.status != _mission.status) _mission = live;

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
            if (_locationError)
              AppSurfaceCard(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: context.colors.errorLight,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        'Localisation non disponible. Vérifiez les permissions.',
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Statut narratif + ETA ──────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _headlineIcon,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  AppGap.h14,
                  Text(
                    _headline,
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_distanceKm != null &&
                      _mission.status == MissionStatus.onTheWay) ...[
                    AppGap.h6,
                    Text(
                      'Distance jusqu\'au client',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      _etaMinutes >= 60
                          ? '${_etaMinutes ~/ 60}h ${_etaMinutes % 60}min'
                          : '$_etaMinutes min',
                      style: context.text.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _distanceKm! < 1
                          ? '${(_distanceKm! * 1000).round()} m'
                          : '${_distanceKm!.toStringAsFixed(1)} km',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h28,
            StatusTimeline(status: _mission.status),
            AppGap.h20,

            // ── Mini carte ──────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radius16),
              child: SizedBox(
                height: 140,
                child: AppMap.tracking(
                  freelancerPosition: _currentPosition,
                  destination: _destinationLatLng,
                  freelancerMarker: const AppMapPuck(),
                  showWaiting: !_locationError,
                  waitingText: 'Localisation en cours…',
                  compact: true,
                ),
              ),
            ),
            AppGap.h20,

            // ── Infos + actions ──────────────────────────────────
            _FreelancerTrackingPanel(
              mission: _mission,
              onCall: widget.onCall,
              onChat: widget.onChat,
              onStartRoute: _mission.status == MissionStatus.confirmed
                  ? () => _updateStatus(MissionStatus.onTheWay)
                  : null,
              onStartMission:
                  _mission.status == MissionStatus.confirmed ||
                      _mission.status == MissionStatus.onTheWay
                  ? _startMission
                  : null,
              onFinishMission: _mission.status == MissionStatus.inProgress
                  ? () => _updateStatus(MissionStatus.completionRequested)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panneau de suivi freelancer ──────────────────────────────────────────────

class _FreelancerTrackingPanel extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onStartRoute;
  final VoidCallback? onStartMission;
  final VoidCallback? onFinishMission;

  const _FreelancerTrackingPanel({
    required this.mission,
    this.onCall,
    this.onChat,
    this.onStartRoute,
    this.onStartMission,
    this.onFinishMission,
  });

  @override
  Widget build(BuildContext context) {
    final client = mission.client;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (client != null) ...[
              UserAvatar(
                imageUrl: client.avatarUrl,
                radius: 28,
                showVerified: client.isVerified,
              ),
              AppGap.w14,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client?.name ?? mission.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        AppGap.h6,
        Text(
          mission.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppGap.h16,
        AppSurfaceCard(
          padding: AppInsets.a14,
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDesign.radius14),
          child: Row(
            children: [
              Icon(
                mission.status == MissionStatus.inProgress
                    ? Icons.handyman_rounded
                    : Icons.directions_walk_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              AppGap.w10,
              Expanded(
                child: Text(
                  switch (mission.status) {
                    MissionStatus.confirmed =>
                      'Partez vers le client — votre trajet est détecté automatiquement. Une fois arrivé, démarrez la mission.',
                    MissionStatus.onTheWay =>
                      'Une fois arrivé chez le client, démarrez la mission.',
                    MissionStatus.inProgress =>
                      'La mission est en cours. Terminez-la ici à la fin de l\'intervention.',
                    MissionStatus.completionRequested =>
                      'Vous avez signalé la fin. Le client a 8h pour confirmer ou contester, sinon le paiement vous est versé automatiquement.',
                    _ => 'Le suivi de mission est terminé.',
                  },
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppGap.h16,
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 16,
              color: context.colors.textSecondary,
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
        AppGap.h18,
        if (onStartRoute != null)
          _TrackingPrimaryButton(
            label: 'Marquer comme en route',
            icon: Icons.navigation_rounded,
            onTap: onStartRoute!,
          ),
        if (onStartMission != null) ...[
          if (onStartRoute != null) AppGap.h10,
          _TrackingPrimaryButton(
            label: 'Commencer la mission',
            icon: Icons.play_circle_rounded,
            onTap: onStartMission!,
          ),
        ],
        if (onFinishMission != null) ...[
          AppGap.h10,
          _TrackingPrimaryButton(
            label: 'J\'ai terminé',
            icon: Icons.check_circle_rounded,
            onTap: onFinishMission!,
          ),
        ],
      ],
    );
  }
}

// ─── Bouton action principal ──────────────────────────────────────────────────

class _TrackingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TrackingPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onTap,
      variant: ButtonVariant.black,
      icon: icon,
      iconTrailing: false,
      height: 54,
    );
  }
}
