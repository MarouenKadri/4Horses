import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../../../core/location/nominatim_service.dart';
import 'mission_step_ui.dart';

/// ─────────────────────────────────────────────────────────────
/// 📍 Step 4 — Adresse directe (recherche + suggestions, sans carte)
/// La carte n'apportait rien : seule l'adresse texte est conservée,
/// et le détail mission offre déjà « Voir sur la carte ».
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

  List<NominatimPlace> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _showSuggestions = false;
  bool _hasSelection = false;
  bool _noResults = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.address;
    _hasSelection = widget.address.trim().isNotEmpty;
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _showSuggestions = false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ── Géocodage Nominatim ───────────────────────────────────
  // Debounce obligatoire : Nominatim limite à ~1 requête/seconde,
  // une requête par frappe se fait refuser en silence.
  void _scheduleSearch(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
        _noResults = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final results = await NominatimService.search(query, limit: 5);
      if (!mounted) return;
      // Ignore les réponses obsolètes (l'utilisateur a continué à taper)
      if (query != _ctrl.text) return;
      setState(() {
        _suggestions = results;
        _showSuggestions = _suggestions.isNotEmpty;
        _noResults = results.isEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => _noResults = true);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectPlace(NominatimPlace place) {
    _ctrl.text = place.displayName;
    widget.onAddressChanged(place.displayName);
    _focus.unfocus();

    _debounce?.cancel();
    setState(() {
      _hasSelection = true;
      _showSuggestions = false;
      _suggestions = [];
      _noResults = false;
      _isSearching = false;
    });
  }

  void _clearSelection() {
    _ctrl.clear();
    widget.onAddressChanged('');
    _debounce?.cancel();
    setState(() {
      _hasSelection = false;
      _showSuggestions = false;
      _suggestions = [];
      _noResults = false;
      _isSearching = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    _focus.unfocus();
    setState(() => _isLocating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          'Autorisez la localisation pour utiliser votre position.',
          type: SnackBarType.error,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final place = await NominatimService.reverse(
        LatLng(pos.latitude, pos.longitude),
      );
      if (!mounted) return;
      if (place == null) {
        showAppSnackBar(
          context,
          'Adresse introuvable pour votre position. Saisissez-la manuellement.',
          type: SnackBarType.error,
        );
        return;
      }

      _ctrl.text = place.displayName;
      widget.onAddressChanged(place.displayName);
      _debounce?.cancel();
      setState(() {
        _hasSelection = true;
        _showSuggestions = false;
        _suggestions = [];
        _noResults = false;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Position indisponible. Vérifiez le GPS et réessayez.',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionStepHeader(
            title: 'Où se déroule la mission ?',
            subtitle:
                'L\'adresse exacte ne sera partagée qu\'au prestataire confirmé.',
          ),
          AppGap.h24,
          _SearchBar(
            controller: _ctrl,
            focusNode: _focus,
            isSearching: _isSearching,
            hasValue: _ctrl.text.isNotEmpty,
            onChanged: (v) {
              widget.onAddressChanged(v);
              setState(() => _hasSelection = false);
              _scheduleSearch(v);
            },
            onClear: _clearSelection,
          ),
          if (_showSuggestions && _suggestions.isNotEmpty) ...[
            AppGap.h8,
            _SuggestionsList(
              suggestions: _suggestions,
              onSelected: _selectPlace,
            ),
          ] else if (_noResults && !_isSearching && !_hasSelection) ...[
            AppGap.h12,
            Row(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                AppGap.w8,
                Text(
                  'Aucune adresse trouvée — précisez la ville',
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
          AppGap.h16,
          // ── Position actuelle — action texte, comme le détail ──────
          InkWell(
            onTap: _useCurrentLocation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (_isLocating)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.my_location_outlined,
                      size: 18,
                      color: context.colors.textSecondary,
                    ),
                  AppGap.w10,
                  Text(
                    _isLocating
                        ? 'Localisation en cours...'
                        : 'Utiliser ma position actuelle',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_hasSelection && !_showSuggestions) ...[
            AppGap.h20,
            Divider(height: 1, color: context.colors.divider),
            AppGap.h16,
            _SelectedAddressRow(
              address: _ctrl.text,
              onEdit: () => _focus.requestFocus(),
            ),
          ],
        ],
      ),
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
      decoration:
          AppInputDecorations.profileField(
            context,
            hintText: 'Rechercher une adresse...',
            radius: AppDesign.radius12,
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

class _SuggestionsList extends StatelessWidget {
  final List<NominatimPlace> suggestions;
  final ValueChanged<NominatimPlace> onSelected;

  const _SuggestionsList({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: context.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.asMap().entries.map((e) {
            final i = e.key;
            final place = e.value;
            return Column(
              children: [
                InkWell(
                  onTap: () => onSelected(place),
                  child: Padding(
                    padding: AppInsets.h16v12,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: context.colors.textTertiary,
                        ),
                        AppGap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.displayName.split(',').first.trim(),
                                style: context.text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
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
                                style: context.text.labelMedium?.copyWith(
                                  color: context.colors.textTertiary,
                                ),
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
                if (i < suggestions.length - 1)
                  Divider(height: 1, indent: 46, color: context.colors.divider),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SelectedAddressRow extends StatelessWidget {
  final String address;
  final VoidCallback onEdit;

  const _SelectedAddressRow({required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.colors.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MissionSectionLabel(label: 'Adresse sélectionnée'),
              AppGap.h4,
              Text(
                address,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit_rounded,
            size: 18,
            color: context.colors.textSecondary,
          ),
          onPressed: onEdit,
        ),
      ],
    );
  }
}
