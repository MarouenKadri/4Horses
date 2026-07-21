sealed class MessageContent {
  const MessageContent();
}

final class TextContent extends MessageContent {
  final String text;
  const TextContent(this.text);
}

final class LocationContent extends MessageContent {
  final double lat;
  final double lng;

  const LocationContent({required this.lat, required this.lng});

  static LocationContent? tryParse(String raw) {
    if (!raw.startsWith('📍 ')) return null;
    final coords = raw.substring(3).split(',');
    if (coords.length != 2) return null;
    final lat = double.tryParse(coords[0].trim());
    final lng = double.tryParse(coords[1].trim());
    if (lat == null || lng == null) return null;
    return LocationContent(lat: lat, lng: lng);
  }

  String get rawValue => '📍 $lat,$lng';
}

final class SystemContent extends MessageContent {
  final String text;
  const SystemContent(this.text);
}
