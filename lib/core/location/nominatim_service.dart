import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimPlace {
  final String displayName;
  final String shortAddress;
  final double lat;
  final double lon;

  const NominatimPlace({
    required this.displayName,
    required this.shortAddress,
    required this.lat,
    required this.lon,
  });

  LatLng get latLng => LatLng(lat, lon);

  factory NominatimPlace.fromSearchJson(Map<String, dynamic> json) {
    final displayName = json['display_name'] as String? ?? '';
    return NominatimPlace(
      displayName: displayName,
      shortAddress: _shortAddress(displayName),
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }

  factory NominatimPlace.fromReverseJson(
    Map<String, dynamic> json, {
    required LatLng latLng,
  }) {
    final displayName = json['display_name'] as String? ?? '';
    return NominatimPlace(
      displayName: displayName,
      shortAddress: _shortAddress(displayName),
      lat: latLng.latitude,
      lon: latLng.longitude,
    );
  }

  static String _shortAddress(String displayName) =>
      displayName.split(',').take(3).join(',').trim();
}

class NominatimService {
  const NominatimService._();

  static const _userAgent = 'InkernApp/1.0';

  static Map<String, String> _headers({String language = 'fr'}) => {
    'Accept-Language': language,
    'User-Agent': _userAgent,
  };

  static Future<List<NominatimPlace>> search(
    String query, {
    int limit = 5,
    String language = 'fr',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(trimmed)}&format=json&limit=$limit&addressdetails=1',
    );
    final response = await http.get(uri, headers: _headers(language: language));

    if (response.statusCode != 200) return const [];

    final data = jsonDecode(response.body) as List;
    return data
        .map(
          (entry) =>
              NominatimPlace.fromSearchJson(entry as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  static Future<NominatimPlace?> reverse(
    LatLng latLng, {
    String language = 'fr',
  }) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${latLng.latitude}&lon=${latLng.longitude}&format=json',
    );
    final response = await http.get(uri, headers: _headers(language: language));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return NominatimPlace.fromReverseJson(data, latLng: latLng);
  }

  static Future<NominatimPlace?> geocodeSingle(
    String query, {
    String language = 'fr',
  }) async {
    final results = await search(query, limit: 1, language: language);
    if (results.isEmpty) return null;
    return results.first;
  }
}
