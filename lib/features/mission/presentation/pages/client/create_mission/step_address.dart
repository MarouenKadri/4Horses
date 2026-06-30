import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../../../core/location/nominatim_service.dart';
import 'mission_step_ui.dart';

/// ─────────────────────────────────────────────────────────────
/// 📍 Step 4 — Adresse avec carte dynamique
/// ─────────────────────────────────────────────────────────────
class StepAddress extends StatefulWidget {
  final String address;
  final Function(String) onAddressChanged;

  const StepAddress({
    super.key,
    required this.address,
    required this.onAddressChanged,
  });

  @override
  State<StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<StepAddress> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final MapController _mapController = MapController();

  LatLng _mapCenter = const LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _selectedLatLng;
  List<NominatimPlace> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.address;
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _showSuggestions = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Géocodage Nominatim ───────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);

    try {
      final results = await NominatimService.search(query, limit: 5);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } catch (_) {
      // Erreur réseau silencieuse
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectPlace(NominatimPlace place) {
    _ctrl.text = place.displayName;
    widget.onAddressChanged(place.displayName);
    _focus.unfocus();

    setState(() {
      _selectedLatLng = place.latLng;
      _mapCenter = _selectedLatLng!;
      _showSuggestions = false;
      _suggestions = [];
    });

    _mapController.move(_selectedLatLng!, 15);
  }

  void _clearSelection() {
    _ctrl.clear();
    widget.onAddressChanged('');
    setState(() {
      _selectedLatLng = null;
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _useCurrentLocation() {
    const current = LatLng(48.8566, 2.3522);
    _ctrl.text = 'Paris, France';
    widget.onAddressChanged(_ctrl.text);
    _focus.unfocus();
    setState(() {
      _selectedLatLng = current;
      _mapCenter = current;
      _showSuggestions = false;
      _suggestions = [];
    });
    _mapController.move(current, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Carte ─────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 13,
            onTap: (_, __) {
              _focus.unfocus();
              setState(() => _showSuggestions = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.homservice',
            ),
            if (_selectedLatLng != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng!,
                    width: 44,
                    height: 52,
                    child: const AppMapPin(),
                  ),
                ],
              ),
          ],
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.white.withValues(alpha: 0.14), Colors.transparent],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),

        // ── Barre de recherche (flottante en haut) ────────────
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              _SearchBar(
                controller: _ctrl,
                focusNode: _focus,
                isSearching: _isSearching,
                hasValue: _ctrl.text.isNotEmpty,
                onChanged: (v) {
                  widget.onAddressChanged(v);
                  _search(v);
                  setState(() => _showSuggestions = v.isNotEmpty);
                },
                onClear: _clearSelection,
              ),

              // ── Suggestions ───────────────────────────────
              if (_showSuggestions && _suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _suggestions.asMap().entries.map((e) {
                        final i = e.key;
                        final place = e.value;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _selectPlace(place),
                              child: Padding(
                                padding: AppInsets.h16v12,
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 18,
                                        color: AppColors.primary),
                                    AppGap.w12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.displayName
                                                .split(',')
                                                .first
                                                .trim(),
                                            style: TextStyle(fontSize: AppFontSize.baseHalf, fontWeight: FontWeight.w600, color: AppColors.inkDark),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            place.displayName
                                                .split(',')
                                                .skip(1)
                                                .take(2)
                                                .join(',')
                                                .trim(),
                                            style: context.text.labelMedium?.copyWith(color: context.colors.textTertiary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < _suggestions.length - 1)
                              Divider(
                                  height: 1, color: context.colors.divider),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          left: 16,
          right: 16,
          bottom: _selectedLatLng != null && !_showSuggestions ? 96 : 30,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AppButton(
              label: 'Utiliser ma position actuelle',
              onPressed: _useCurrentLocation,
              variant: ButtonVariant.outline,
              icon: Icons.my_location_outlined,
              iconTrailing: false,
              height: 48,
              width: null,
            ),
          ),
        ),

        if (_selectedLatLng != null && !_showSuggestions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SelectedAddressCard(
              address: _ctrl.text,
              onEdit: () => _focus.requestFocus(),
            ),
          ),
      ],
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final bool hasValue;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.hasValue,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: AppInputDecorations.profileField(
        context,
        hintText: 'Rechercher une adresse...',
        radius: 18,
        prefixIcon: isSearching
            ? Padding(
                padding: AppInsets.a14,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Icon(
                Icons.search_outlined,
                color: context.colors.textHint,
                size: 18,
              ),
        suffixIcon: hasValue
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: context.colors.textHint,
                  size: 18,
                ),
                onPressed: onClear,
              )
            : null,
      ).copyWith(
        labelText: 'Adresse de la mission',
        contentPadding: AppInsets.h16v16,
        errorStyle: context.profileErrorStyle,
      ),
    );
  }
}


class _SelectedAddressCard extends StatelessWidget {
  final String address;
  final VoidCallback onEdit;

  const _SelectedAddressCard({
    required this.address,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: AppInsets.a16,
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: AppInsets.a10,
            decoration: BoxDecoration(
              color: AppColors.inkDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 18),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MissionSectionLabel(label: 'Adresse sélectionnée'),
                AppGap.h2,
                Text(
                  address,
                  style: TextStyle(
                    fontSize: AppFontSize.baseHalf,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded,
                size: 18, color: context.colors.textSecondary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

