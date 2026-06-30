import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/design/app_design_system.dart';
import '../../core/location/nominatim_service.dart';
import 'location_app_bar.dart' show LocationData;

enum LocationType { current, other }

class _NominatimResult {
  final String displayName;
  final String shortName;
  final double lat;
  final double lon;

  _NominatimResult({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lon,
  });

  factory _NominatimResult.fromPlace(NominatimPlace place) {
    final parts = place.displayName.split(',');
    return _NominatimResult(
      displayName: place.displayName,
      shortName: parts.first.trim(),
      lat: place.lat,
      lon: place.lon,
    );
  }
}

class LocationSearchPage extends StatefulWidget {
  final String currentCity;
  final LocationType initialType;
  final String? initialOtherAddress;

  const LocationSearchPage({
    super.key,
    required this.currentCity,
    this.initialType = LocationType.current,
    this.initialOtherAddress,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MapController _mapCtrl = MapController();

  LatLng _center = const LatLng(46.6034, 1.8883);
  LatLng? _pin;

  bool _isSearching = false;
  bool _loadingResults = false;
  bool _loadingLocation = false;
  List<_NominatimResult> _results = [];
  Timer? _debounce;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  late LocationType _selected;
  String? _otherAddress;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialType;
    _otherAddress = widget.initialOtherAddress;
    _searchCtrl.addListener(_onQueryChanged);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _mapCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _searchCtrl.text.trim();
    setState(() => _isSearching = q.isNotEmpty);
    _debounce?.cancel();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String query) async {
    setState(() => _loadingResults = true);
    try {
      final places = await NominatimService.search(query, limit: 6);
      if (!mounted) return;
      setState(() =>
          _results = places.map(_NominatimResult.fromPlace).toList(growable: false));
      if (_results.isNotEmpty) {
        final first = _results.first;
        final latlng = LatLng(first.lat, first.lon);
        setState(() {
          _pin = latlng;
          _center = latlng;
        });
        _mapCtrl.move(latlng, 12);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingResults = false);
    }
  }

  void _selectResult(_NominatimResult r) {
    final latlng = LatLng(r.lat, r.lon);
    final subtitle = r.displayName.split(',').skip(1).take(2).join(',').trim();
    setState(() {
      _pin = latlng;
      _center = latlng;
      _otherAddress =
          '${r.shortName}${subtitle.isNotEmpty ? ', $subtitle' : ''}';
      _selected = LocationType.other;
    });
    _mapCtrl.move(latlng, 13);
    Navigator.pop(
      context,
      LocationData(
        icon: Icons.location_on_rounded,
        label: r.shortName,
        subtitle: subtitle,
      ),
    );
  }

  Future<void> _selectCurrentPosition() async {
    setState(() {
      _selected = LocationType.current;
      _loadingLocation = true;
    });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        Navigator.pop(
          context,
          const LocationData(
            icon: Icons.my_location_rounded,
            label: 'Position actuelle',
            subtitle: '',
          ),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;

      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pin = latlng;
        _center = latlng;
      });
      _mapCtrl.move(latlng, 14);

      String city = 'Position actuelle';
      String subtitle = '';
      try {
        final place = await NominatimService.reverse(latlng);
        if (place != null && place.displayName.isNotEmpty) {
          final parts = place.displayName
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false);
          city = parts.isNotEmpty ? parts.first : city;
          subtitle = parts.length > 2
              ? parts.skip(1).take(2).join(', ')
              : parts.skip(1).join(', ');
        }
      } catch (_) {}

      if (!mounted) return;
      Navigator.pop(
        context,
        LocationData(
          icon: Icons.my_location_rounded,
          label: city,
          subtitle: subtitle,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(
        context,
        const LocationData(
          icon: Icons.my_location_rounded,
          label: 'Position actuelle',
          subtitle: '',
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _selectOtherAddress(String address) {
    setState(() => _selected = LocationType.other);
    Navigator.pop(
      context,
      LocationData(
        icon: Icons.location_on_rounded,
        label: address.split(',').first.trim(),
        subtitle: address.contains(',')
            ? address.split(',').skip(1).join(',').trim()
            : '',
      ),
    );
  }

  InputDecoration _searchDecoration(BuildContext context) =>
      AppInputDecorations.formField(
        context,
        hintText: 'Rechercher...',
        hintStyle: context.text.bodyMedium?.copyWith(
          fontSize: AppFontSize.body,
          fontWeight: FontWeight.w400,
          color: context.colors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search_outlined,
          color: context.colors.textSecondary,
          size: 19,
        ),
        suffixIcon: _isSearching
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: context.colors.textSecondary,
                  size: 18,
                ),
                onPressed: () {
                  _searchCtrl.clear();
                  _focusNode.requestFocus();
                },
              )
            : null,
        fillColor: context.colors.surface.withValues(alpha: 0.42),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        radius: 24,
        noBorder: true,
      );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.9, 0.0, 0.0, 0.0, 10,
                    0.0, 0.9, 0.0, 0.0, 10,
                    0.0, 0.0, 0.9, 0.0, 10,
                    0.0, 0.0, 0.0, 1.0, 0,
                  ]),
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(initialCenter: _center, initialZoom: 6),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.inkern',
                      ),
                      if (_pin != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: _pin!,
                            width: 44,
                            height: 52,
                            child: const AppMapPin(),
                          ),
                        ]),
                    ],
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
                            context.colors.surface.withValues(alpha: 0.87),
                            context.colors.surface.withValues(alpha: 0.0),
                            context.colors.surface.withValues(alpha: 0.08),
                          ],
                          stops: const [0.0, 0.18, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: top + 76,
                        color: context.colors.surface.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: top + AppBarMetrics.mapTopInset,
                  left: AppBarMetrics.mapSideInset,
                  child: AppBarActionCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                    size: AppBarMetrics.mapBackButtonSize,
                    iconSize: AppBarMetrics.mapBackButtonIconSize,
                    backgroundColor:
                        context.colors.surface.withValues(alpha: 0.72),
                    iconColor: context.colors.textPrimary,
                    border: Border.all(
                        color: context.colors.border.withValues(alpha: 0.65)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppBarSheetSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppBottomSheetHandle(),
                AppGap.h8,
                Text(
                  'Lieu',
                  style: context.appBarPanelTitleStyle.copyWith(
                    fontSize: AppFontSize.h2Lg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h14,
                Padding(
                  padding: AppInsets.h16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.85),
                          offset: const Offset(-2, -2),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: context.colors.textPrimary.withValues(alpha: 0.05),
                          offset: const Offset(2, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: context.text.bodyLarge?.copyWith(
                        fontSize: AppFontSize.body,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textPrimary,
                      ),
                      decoration: _searchDecoration(context),
                    ),
                  ),
                ),
                AppGap.h12,
                if (!_isSearching) _buildRecentPlaces(context),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.30,
                  ),
                  child: _isSearching ? _buildResults() : _buildAddressList(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Fermer',
                      style: context.appBarSheetActionStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loadingResults) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: AppBarMetrics.emptyStateIconSize,
              color: context.colors.border,
            ),
            AppGap.h10,
            Text('Aucun résultat', style: context.appBarEmptyStateStyle),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: AppInsets.h16v4,
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, thickness: 1, color: context.colors.divider),
      itemBuilder: (_, i) {
        final r = _results[i];
        return AppBarOptionTile(
          onTap: () => _selectResult(r),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Icon(Icons.place_outlined,
              size: 20, color: context.colors.textSecondary),
          title: r.shortName,
          subtitle: r.displayName,
          trailing: Icon(Icons.chevron_right_rounded,
              color: context.colors.textHint, size: 18),
        );
      },
    );
  }

  Widget _buildAddressList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AddrItem(
            icon: Icons.my_location_outlined,
            label: 'Position actuelle',
            isSelected: _selected == LocationType.current,
            isLoading: _loadingLocation,
            teal: context.colors.textPrimary,
            tealLight: Colors.transparent,
            pulse: _pulseScale,
            onTap: _loadingLocation ? null : _selectCurrentPosition,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: context.colors.divider.withValues(alpha: 0.6),
            indent: 16,
            endIndent: 16,
          ),
          _AddrItem(
            icon: Icons.place_outlined,
            label: 'Autre',
            subtitle: _otherAddress,
            isSelected: _selected == LocationType.other,
            teal: context.colors.textPrimary,
            tealLight: Colors.transparent,
            onTap: _otherAddress != null
                ? () => _selectOtherAddress(_otherAddress!)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaces(BuildContext context) {
    const places = ['Maison', 'Paris 11e', 'Bureau'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lieux récents',
            style: context.appBarSectionLabelStyle.copyWith(
              fontSize: AppFontSize.sm,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          AppGap.h10,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: places
                  .map(
                    (place) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _selectOtherAddress(place),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surface.withValues(alpha: 0.56),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: context.colors.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            place,
                            style: context.sheetActionTitleStyle.copyWith(
                              fontSize: AppFontSize.md,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class _AddrItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isLoading;
  final Color teal;
  final Color tealLight;
  final Animation<double>? pulse;
  final VoidCallback? onTap;

  const _AddrItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.isLoading = false,
    required this.teal,
    required this.tealLight,
    this.pulse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final leadingIcon = Icon(
      icon,
      size: 20,
      color: isSelected ? teal : context.colors.textSecondary,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.surfaceAlt.withValues(alpha: 0.82)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppBarOptionTile(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        leading: pulse != null
            ? ScaleTransition(scale: pulse!, child: leadingIcon)
            : leadingIcon,
        title: label,
        subtitle: subtitle,
        trailing: isLoading
            ? AppLoadingIndicator(
                size: AppBarMetrics.trailingIndicatorSize, color: teal)
            : AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : 0,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.textHint,
                ),
              ),
      ),
    );
  }
}
