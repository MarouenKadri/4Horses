import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_design_system.dart';
import '../../location/nominatim_service.dart';

// ─── Tile source ──────────────────────────────────────────────────────────────

enum AppMapTile {
  /// CartoDB sans labels — épuré, pour pickers et previews.
  cartoLight,
  /// CartoDB avec labels de rues — pour le tracking (navigation).
  cartoLightAll,
  osm;

  String get _url => switch (this) {
        AppMapTile.cartoLight =>
          'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
        AppMapTile.cartoLightAll =>
          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
        AppMapTile.osm =>
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      };

  List<String> get _subdomains => this == AppMapTile.osm
      ? const []
      : const ['a', 'b', 'c', 'd'];
}

TileLayer _buildTile(AppMapTile t) => TileLayer(
      urlTemplate: t._url,
      subdomains: t._subdomains,
      userAgentPackageName: 'com.example.inkern',
    );

// ─── Shared result type (picker) ──────────────────────────────────────────────

class AppMapSelection {
  final LatLng latLng;
  final String address;
  const AppMapSelection({required this.latLng, required this.address});
}

// ─── Shared pin widget ────────────────────────────────────────────────────────

class AppMapPin extends StatelessWidget {
  final Color color;
  final double size;

  const AppMapPin({
    super.key,
    this.color = AppColors.mapPin,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
        ),
        CustomPaint(
          size: const Size(12, 10),
          painter: _PinTailPainter(color),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

// ─── Facade ───────────────────────────────────────────────────────────────────

/// Unified map entry point. Use the named static factories:
///
/// * [AppMap.picker]   — interactive location picker with search
/// * [AppMap.preview]  — read-only preview, geocodes address if needed
/// * [AppMap.tracking] — real-time dual-marker + polyline map
abstract final class AppMap {
  static Widget picker({
    Key? key,
    LatLng? initialLatLng,
    String initialAddress = '',
    required ValueChanged<AppMapSelection> onChanged,
    double height = 220,
    String searchHint = 'Rechercher une adresse…',
    String emptyLabel = 'Aucune localisation définie',
    String tapHint = 'Appuyez pour poser le pin',
  }) =>
      _AppMapPicker(
        key: key,
        initialLatLng: initialLatLng,
        initialAddress: initialAddress,
        onChanged: onChanged,
        height: height,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
        tapHint: tapHint,
      );

  /// [latLng] takes priority over [address].
  /// If [interactive] is true, pinch-zoom and drag are enabled.
  /// Pass [controller] when the parent needs to animate the camera.
  static Widget preview({
    Key? key,
    LatLng? latLng,
    String? address,
    double? height,
    bool interactive = false,
    AppMapTile tile = AppMapTile.cartoLight,
    VoidCallback? onTap,
    MapController? controller,
  }) =>
      _AppMapPreview(
        key: key,
        latLng: latLng,
        address: address,
        height: height,
        interactive: interactive,
        tile: tile,
        onTap: onTap,
        controller: controller,
      );

  /// Dual-marker tracking map. The parent manages position streams and
  /// calls setState; [didUpdateWidget] moves the camera automatically.
  static Widget tracking({
    Key? key,
    required LatLng? freelancerPosition,
    required LatLng? destination,
    Widget? freelancerMarker,
    Widget? destinationMarker,
    AppMapTile tile = AppMapTile.cartoLightAll,
    bool showWaiting = true,
    String waitingText = 'En attente de la position…',
  }) =>
      _AppMapTracking(
        key: key,
        freelancerPosition: freelancerPosition,
        destination: destination,
        freelancerMarker: freelancerMarker ??
            const AppMapPin(color: AppColors.primary),
        destinationMarker: destinationMarker ??
            const AppMapPin(color: AppColors.inkDark),
        tile: tile,
        showWaiting: showWaiting,
        waitingText: waitingText,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Picker — interactive, search bar + tap-to-pin + reverse geocoding
// ═══════════════════════════════════════════════════════════════════════════════

class _AppMapPicker extends StatefulWidget {
  final LatLng? initialLatLng;
  final String initialAddress;
  final ValueChanged<AppMapSelection> onChanged;
  final double height;
  final String searchHint;
  final String emptyLabel;
  final String tapHint;

  const _AppMapPicker({
    super.key,
    required this.initialLatLng,
    required this.initialAddress,
    required this.onChanged,
    required this.height,
    required this.searchHint,
    required this.emptyLabel,
    required this.tapHint,
  });

  @override
  State<_AppMapPicker> createState() => _AppMapPickerState();
}

class _AppMapPickerState extends State<_AppMapPicker> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  LatLng _center = const LatLng(48.8566, 2.3522);
  LatLng? _pin;
  String _displayAddress = '';
  bool _isSearching = false;
  bool _isReversing = false;
  List<NominatimPlace> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void didUpdateWidget(covariant _AppMapPicker old) {
    super.didUpdateWidget(old);
    if (old.initialLatLng != widget.initialLatLng ||
        old.initialAddress != widget.initialAddress) {
      _hydrate();
    }
  }

  void _hydrate() {
    _pin = widget.initialLatLng;
    _center = widget.initialLatLng ?? const LatLng(48.8566, 2.3522);
    _displayAddress = widget.initialAddress;
    _searchCtrl.text = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = const [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await NominatimService.search(query, limit: 5);
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {
      if (mounted) setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(NominatimPlace place) {
    setState(() {
      _pin = place.latLng;
      _center = place.latLng;
      _displayAddress = place.shortAddress;
      _suggestions = const [];
      _searchCtrl.text = place.shortAddress;
    });
    _mapCtrl.move(place.latLng, 14);
    _searchFocus.unfocus();
    widget.onChanged(AppMapSelection(latLng: place.latLng, address: place.shortAddress));
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _isReversing = true);
    try {
      final place = await NominatimService.reverse(latLng);
      if (!mounted || place == null) return;
      setState(() {
        _displayAddress = place.shortAddress;
        _searchCtrl.text = place.shortAddress;
      });
      widget.onChanged(AppMapSelection(latLng: latLng, address: place.shortAddress));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isReversing = false);
    }
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    setState(() {
      _pin = latLng;
      _center = latLng;
      _suggestions = const [];
    });
    _searchFocus.unfocus();
    _reverseGeocode(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchBar(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          hintText: widget.searchHint,
          isSearching: _isSearching,
          suggestions: _suggestions,
          onChanged: _search,
          onClear: () {
            _searchCtrl.clear();
            setState(() => _suggestions = const []);
          },
          onSelectSuggestion: _selectSuggestion,
        ),
        AppGap.h12,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _pin != null ? 13 : 11,
                    onTap: _onMapTap,
                  ),
                  children: [
                    _buildTile(AppMapTile.cartoLight),
                    if (_pin != null)
                      MarkerLayer(
                        markers: [
                          Marker(point: _pin!, width: 44, height: 52, child: const AppMapPin()),
                        ],
                      ),
                  ],
                ),
                if (_pin == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: AppInsets.h14v8,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app_rounded, size: 16, color: Colors.white),
                              AppGap.w6,
                              Text(
                                widget.tapHint,
                                style: context.text.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isReversing)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: AppInsets.a8,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppGap.h10,
        _AddressBadge(address: _displayAddress, emptyLabel: widget.emptyLabel),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Preview — read-only, geocodes address when no LatLng is provided
// ═══════════════════════════════════════════════════════════════════════════════

class _AppMapPreview extends StatefulWidget {
  final LatLng? latLng;
  final String? address;
  final double? height;
  final bool interactive;
  final AppMapTile tile;
  final VoidCallback? onTap;
  final MapController? controller;

  const _AppMapPreview({
    super.key,
    this.latLng,
    this.address,
    this.height,
    required this.interactive,
    required this.tile,
    this.onTap,
    this.controller,
  });

  @override
  State<_AppMapPreview> createState() => _AppMapPreviewState();
}

class _AppMapPreviewState extends State<_AppMapPreview> {
  static const _defaultCenter = LatLng(48.8566, 2.3522);

  late final MapController _ctrl;
  bool _ownsCtrl = false;
  LatLng? _pin;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = MapController();
      _ownsCtrl = true;
    }
    if (widget.latLng != null) {
      _pin = widget.latLng;
    } else {
      _geocode();
    }
  }

  @override
  void didUpdateWidget(covariant _AppMapPreview old) {
    super.didUpdateWidget(old);
    if (widget.latLng != null && widget.latLng != old.latLng) {
      setState(() => _pin = widget.latLng);
    }
  }

  @override
  void dispose() {
    if (_ownsCtrl) _ctrl.dispose();
    super.dispose();
  }

  Future<void> _geocode() async {
    final q = widget.address?.trim() ?? '';
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final place = await NominatimService.geocodeSingle(q);
      if (!mounted || place == null) return;
      setState(() => _pin = place.latLng);
      _ctrl.move(place.latLng, 14);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _pin ?? _defaultCenter;
    final flags = widget.interactive
        ? InteractiveFlag.pinchZoom | InteractiveFlag.drag
        : InteractiveFlag.none;

    final map = FlutterMap(
      mapController: _ctrl,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        onTap: widget.onTap != null ? (_, __) => widget.onTap!() : null,
        interactionOptions: InteractionOptions(flags: flags),
      ),
      children: [
        _buildTile(widget.tile),
        if (_pin != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _pin!,
                width: 44,
                height: 52,
                child: const AppMapPin(),
              ),
            ],
          ),
      ],
    );

    Widget child = _loading
        ? Stack(
            children: [
              map,
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          )
        : map;

    if (widget.height != null) {
      child = SizedBox(height: widget.height, child: child);
    }
    return child;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tracking — dual markers + polyline, auto-following camera
// ═══════════════════════════════════════════════════════════════════════════════

class _AppMapTracking extends StatefulWidget {
  final LatLng? freelancerPosition;
  final LatLng? destination;
  final Widget freelancerMarker;
  final Widget destinationMarker;
  final AppMapTile tile;
  final bool showWaiting;
  final String waitingText;

  const _AppMapTracking({
    super.key,
    required this.freelancerPosition,
    required this.destination,
    required this.freelancerMarker,
    required this.destinationMarker,
    required this.tile,
    required this.showWaiting,
    required this.waitingText,
  });

  @override
  State<_AppMapTracking> createState() => _AppMapTrackingState();
}

class _AppMapTrackingState extends State<_AppMapTracking> {
  static const _defaultCenter = LatLng(46.6034, 1.8883);

  final _mapCtrl = MapController();
  bool _following = true;

  @override
  void didUpdateWidget(covariant _AppMapTracking old) {
    super.didUpdateWidget(old);
    final pos = widget.freelancerPosition;
    final oldPos = old.freelancerPosition;
    if (pos != null && _following) {
      final changed = oldPos == null ||
          pos.latitude != oldPos.latitude ||
          pos.longitude != oldPos.longitude;
      if (changed) _mapCtrl.move(pos, 15);
    }
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  void _recenter() {
    if (widget.freelancerPosition == null) return;
    setState(() => _following = true);
    _mapCtrl.move(widget.freelancerPosition!, 15);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final center = widget.freelancerPosition ??
        widget.destination ??
        _defaultCenter;

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFFF0EDE8))),
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: widget.freelancerPosition != null ? 15 : 14,
              onMapEvent: (event) {
                if (event is MapEventMoveStart &&
                    event.source != MapEventSource.mapController &&
                    _following) {
                  setState(() => _following = false);
                }
              },
            ),
            children: [
              _buildTile(widget.tile),
              if (widget.freelancerPosition != null && widget.destination != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [widget.freelancerPosition!, widget.destination!],
                      color: AppColors.secondary.withValues(alpha: 0.70),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (widget.destination != null)
                    Marker(
                      point: widget.destination!,
                      width: 36,
                      height: 36,
                      child: widget.destinationMarker,
                    ),
                  if (widget.freelancerPosition != null)
                    Marker(
                      point: widget.freelancerPosition!,
                      width: 36,
                      height: 36,
                      child: widget.freelancerMarker,
                    ),
                ],
              ),
            ],
          ),
        ),
        if (!_following && widget.freelancerPosition != null)
          Positioned(
            bottom: screenHeight * 0.42,
            right: 16,
            child: GestureDetector(
              onTap: _recenter,
              child: AppIconCircle(
                icon: Icons.my_location_rounded,
                size: 44,
                iconSize: 20,
                backgroundColor: Colors.white,
                iconColor: AppColors.secondary,
                boxShadow: AppShadows.card,
              ),
            ),
          ),
        if (widget.showWaiting && widget.freelancerPosition == null)
          Positioned(
            top: topPadding + 64,
            left: 0,
            right: 0,
            child: Center(
              child: AppSurfaceCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: AppShadows.card,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppGap.w8,
                    Text(widget.waitingText, style: context.text.labelMedium),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Private sub-widgets shared by picker
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isSearching;
  final List<NominatimPlace> suggestions;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<NominatimPlace> onSelectSuggestion;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isSearching,
    required this.suggestions,
    required this.onChanged,
    required this.onClear,
    required this.onSelectSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: focusNode.hasFocus ? AppColors.primary : context.colors.border,
              width: focusNode.hasFocus ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: AppInsets.h12,
                child: Icon(Icons.search_rounded, size: 20, color: context.colors.textTertiary),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: context.text.bodyMedium?.copyWith(color: context.colors.textPrimary),
                  decoration: AppInputDecorations.formField(
                    context,
                    hintText: hintText,
                    hintStyle: context.text.bodySmall?.copyWith(color: context.colors.textHint),
                    contentPadding: AppInsets.v13,
                    noBorder: true,
                    fillColor: Colors.transparent,
                  ).copyWith(isDense: true),
                  onChanged: onChanged,
                ),
              ),
              if (isSearching)
                const Padding(
                  padding: AppInsets.h12,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              else if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: AppInsets.h12,
                    child: Icon(Icons.close_rounded, size: 18, color: context.colors.textHint),
                  ),
                ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: suggestions.asMap().entries.map((entry) {
                final i = entry.key;
                final place = entry.value;
                final short = place.shortAddress.split(',').first.trim();
                final rest = place.shortAddress.split(',').skip(1).join(',').trim();
                return Column(
                  children: [
                    InkWell(
                      onTap: () => onSelectSuggestion(place),
                      child: Padding(
                        padding: AppInsets.h12v10,
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                            AppGap.w10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    short,
                                    style: context.text.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (rest.isNotEmpty)
                                    Text(rest, style: context.text.labelSmall, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < suggestions.length - 1)
                      Divider(height: 1, color: context.colors.divider),
                  ],
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddressBadge extends StatelessWidget {
  final String address;
  final String emptyLabel;

  const _AddressBadge({required this.address, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    final hasAddress = address.isNotEmpty;
    return Container(
      padding: AppInsets.a12,
      decoration: BoxDecoration(
        color: hasAddress ? AppColors.secondary : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: hasAddress
              ? AppColors.primary.withValues(alpha: 0.25)
              : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasAddress ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 16,
            color: hasAddress ? AppColors.primary : context.colors.textHint,
          ),
          AppGap.w8,
          Expanded(
            child: Text(
              hasAddress ? address : emptyLabel,
              style: context.text.bodySmall?.copyWith(
                fontWeight: hasAddress ? FontWeight.w600 : FontWeight.w400,
                color: hasAddress ? AppColors.primary : context.colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
