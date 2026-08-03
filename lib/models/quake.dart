import 'package:hive/hive.dart';

class Quake {
  final String id;
  final double magnitude;
  final String place;
  final DateTime time;
  final double lat;
  final double lon;
  final double depth;
  final String url;
  final bool isPossibleAftershock;

  Quake({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.lat,
    required this.lon,
    required this.depth,
    required this.url,
    this.isPossibleAftershock = false,
  });

  factory Quake.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('properties')) {
      // USGS GeoJSON feature format
      final properties = json['properties'] as Map<String, dynamic>? ?? {};
      final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
      final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

      final double lon = coordinates.isNotEmpty ? (coordinates[0] as num).toDouble() : 0.0;
      final double lat = coordinates.length > 1 ? (coordinates[1] as num).toDouble() : 0.0;
      final double depth = coordinates.length > 2 ? (coordinates[2] as num).toDouble() : 0.0;

      return Quake(
        id: json['id'] as String? ?? '',
        magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
        place: properties['place'] as String? ?? '',
        time: DateTime.fromMillisecondsSinceEpoch(properties['time'] as int? ?? 0),
        lat: lat,
        lon: lon,
        depth: depth,
        url: properties['url'] as String? ?? '',
        isPossibleAftershock: json['isPossibleAftershock'] as bool? ?? false,
      );
    } else {
      // Local caching / standard JSON format
      return Quake(
        id: json['id'] as String? ?? '',
        magnitude: (json['magnitude'] as num?)?.toDouble() ?? 0.0,
        place: json['place'] as String? ?? '',
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int? ?? 0),
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
        depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
        url: json['url'] as String? ?? '',
        isPossibleAftershock: json['isPossibleAftershock'] as bool? ?? false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'magnitude': magnitude,
      'place': place,
      'time': time.millisecondsSinceEpoch,
      'lat': lat,
      'lon': lon,
      'depth': depth,
      'url': url,
      'isPossibleAftershock': isPossibleAftershock,
    };
  }

  Quake copyWith({
    String? id,
    double? magnitude,
    String? place,
    DateTime? time,
    double? lat,
    double? lon,
    double? depth,
    String? url,
    bool? isPossibleAftershock,
  }) {
    return Quake(
      id: id ?? this.id,
      magnitude: magnitude ?? this.magnitude,
      place: place ?? this.place,
      time: time ?? this.time,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      depth: depth ?? this.depth,
      url: url ?? this.url,
      isPossibleAftershock: isPossibleAftershock ?? this.isPossibleAftershock,
    );
  }
}

class QuakeAdapter extends TypeAdapter<Quake> {
  @override
  final int typeId = 0;

  @override
  Quake read(BinaryReader reader) {
    return Quake(
      id: reader.readString(),
      magnitude: reader.readDouble(),
      place: reader.readString(),
      time: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      lat: reader.readDouble(),
      lon: reader.readDouble(),
      depth: reader.readDouble(),
      url: reader.readString(),
      isPossibleAftershock: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Quake obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.magnitude);
    writer.writeString(obj.place);
    writer.writeInt(obj.time.millisecondsSinceEpoch);
    writer.writeDouble(obj.lat);
    writer.writeDouble(obj.lon);
    writer.writeDouble(obj.depth);
    writer.writeString(obj.url);
    writer.writeBool(obj.isPossibleAftershock);
  }
}
