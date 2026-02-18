import 'package:freezed_annotation/freezed_annotation.dart';

part 'GpsLocation.freezed.dart';
part 'GpsLocation.g.dart';

/// GPS location data model
@freezed
abstract class GpsLocation with _$GpsLocation {
  const factory GpsLocation({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    @Default(0.0) double altitude,
    @Default(0.0) double speed,
    @Default(0.0) double heading,
    @Default(0.0) double accuracy,
    @Default(0.0) double speedAccuracy,
    @Default(0.0) double headingAccuracy,
  }) = _GpsLocation;

  factory GpsLocation.fromJson(Map<String, dynamic> json) =>
      _$GpsLocationFromJson(json);
}

/// Extension methods for GpsLocation
extension GpsLocationExtension on GpsLocation {
  /// Format latitude for display
  String get formattedLatitude => '${latitude.toStringAsFixed(6)}°';

  /// Format longitude for display
  String get formattedLongitude => '${longitude.toStringAsFixed(6)}°';

  /// Format altitude for display
  String get formattedAltitude => '${altitude.toStringAsFixed(1)} m';

  /// Format speed for display (m/s to km/h)
  String get formattedSpeed => '${(speed * 3.6).toStringAsFixed(1)} km/h';

  /// Format heading for display
  String get formattedHeading => '${heading.toStringAsFixed(0)}°';

  /// Get cardinal direction from heading
  String get cardinalDirection {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    if (heading >= 292.5 && heading < 337.5) return 'NW';
    return 'N';
  }
}
