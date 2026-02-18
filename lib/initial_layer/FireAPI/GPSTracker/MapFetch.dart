import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'MapFetch.g.dart';

/// Retrofit API service for OpenStreetMap tile and geocoding services
///
/// This service provides methods to interact with OpenStreetMap APIs:
/// - Nominatim for geocoding (address ↔ coordinates)
/// - Overpass API for querying map data
/// - Tile server information
@RestApi()
abstract class OpenStreetMapApi {
  factory OpenStreetMapApi(Dio dio, {String baseUrl}) = _OpenStreetMapApi;

  /// Search for locations by query string (Nominatim)
  ///
  /// [query] - Search query (e.g., "Eiffel Tower, Paris")
  /// [limit] - Maximum number of results (default: 10)
  /// [format] - Response format (default: json)
  @GET('https://nominatim.openstreetmap.org/search')
  Future<List<NominatimResult>> searchLocation({
    @Query('q') required String query,
    @Query('format') String format = 'json',
    @Query('limit') int limit = 10,
  });

  /// Reverse geocoding - get address from coordinates (Nominatim)
  ///
  /// [lat] - Latitude
  /// [lon] - Longitude
  /// [format] - Response format (default: json)
  @GET('https://nominatim.openstreetmap.org/reverse')
  Future<NominatimResult> reverseGeocode({
    @Query('lat') required double lat,
    @Query('lon') required double lon,
    @Query('format') String format = 'json',
  });

  /// Get place details by OSM ID (Nominatim)
  ///
  /// [osmType] - Type: 'N' (node), 'W' (way), 'R' (relation)
  /// [osmId] - OpenStreetMap ID
  @GET('https://nominatim.openstreetmap.org/lookup')
  Future<List<NominatimResult>> getPlaceDetails({
    @Query('osm_ids') required String osmIds,
    @Query('format') String format = 'json',
  });
}

/// Nominatim geocoding result model
class NominatimResult {
  @JsonKey(name: 'place_id')
  final int? placeId;

  @JsonKey(name: 'osm_type')
  final String? osmType;

  @JsonKey(name: 'osm_id')
  final int? osmId;

  final String? lat;
  final String? lon;

  @JsonKey(name: 'display_name')
  final String? displayName;

  final String? name;
  final String? type;
  final String? category;

  final Map<String, dynamic>? address;
  final List<String>? boundingbox;

  NominatimResult({
    this.placeId,
    this.osmType,
    this.osmId,
    this.lat,
    this.lon,
    this.displayName,
    this.name,
    this.type,
    this.category,
    this.address,
    this.boundingbox,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      placeId: json['place_id'] as int?,
      osmType: json['osm_type'] as String?,
      osmId: json['osm_id'] as int?,
      lat: json['lat'] as String?,
      lon: json['lon'] as String?,
      displayName: json['display_name'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      address: json['address'] as Map<String, dynamic>?,
      boundingbox: (json['boundingbox'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'osm_type': osmType,
      'osm_id': osmId,
      'lat': lat,
      'lon': lon,
      'display_name': displayName,
      'name': name,
      'type': type,
      'category': category,
      'address': address,
      'boundingbox': boundingbox,
    };
  }

  /// Get latitude as double
  double? get latitude => lat != null ? double.tryParse(lat!) : null;

  /// Get longitude as double
  double? get longitude => lon != null ? double.tryParse(lon!) : null;

  /// Get formatted address
  String get formattedAddress => displayName ?? 'Unknown location';

  /// Get city name from address
  String? get city =>
      address?['city'] ??
      address?['town'] ??
      address?['village'] ??
      address?['municipality'];

  /// Get country from address
  String? get country => address?['country'];

  /// Get postal code from address
  String? get postalCode => address?['postcode'];
}

/// Helper class for OpenStreetMap API client
class OpenStreetMapClient {
  late final Dio _dio;
  late final OpenStreetMapApi _api;

  OpenStreetMapClient({Duration? connectTimeout, Duration? receiveTimeout}) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'User-Agent': 'FlutterApp/1.0', // Required by Nominatim
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[OSM API] $obj'),
      ),
    );

    _api = OpenStreetMapApi(_dio);
  }

  /// Get the API instance
  OpenStreetMapApi get api => _api;

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Search for a location by name
  Future<List<NominatimResult>> searchLocation(
    String query, {
    int limit = 10,
  }) async {
    return await _api.searchLocation(query: query, limit: limit);
  }

  /// Get address from coordinates
  Future<NominatimResult> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    return await _api.reverseGeocode(lat: latitude, lon: longitude);
  }

  /// Get place details by OSM ID
  Future<List<NominatimResult>> getPlaceDetails(
    String osmType,
    int osmId,
  ) async {
    final osmIds = '$osmType$osmId';
    return await _api.getPlaceDetails(osmIds: osmIds);
  }
}

/// OpenStreetMap tile server configuration
class OSMTileServer {
  /// Standard OpenStreetMap tile server
  static const String standard =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// OpenStreetMap Humanitarian style
  static const String humanitarian =
      'https://tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  /// OpenTopoMap (topographic style)
  static const String topo = 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';

  /// CyclOSM (cycling-focused)
  static const String cycle =
      'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png';

  /// Transport map
  static const String transport =
      'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png';

  /// Satellite imagery (requires API key for some providers)
  static const String satellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  /// Dark mode
  static const String dark =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';

  /// Get subdomains for tile servers that support them
  static List<String> get subdomains => ['a', 'b', 'c'];

  /// Get attribution text for OpenStreetMap
  static const String attribution = '© OpenStreetMap contributors';
}
