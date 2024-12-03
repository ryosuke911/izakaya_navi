import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/venue.dart';
import '../models/location.dart';

class PlacesApi {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String _apiKey;

  PlacesApi({String? apiKey}) : _apiKey = apiKey ?? Env.googlePlacesApiKey;

  // テキスト検索
  Future<List<Venue>> searchByText(String query, {String? language = 'ja'}) async {
    final url = Uri.parse(
      '$_baseUrl/textsearch/json?query=$query&type=restaurant&language=$language&key=$_apiKey',
    );

    print('API Request URL: $url');

    try {
      final response = await http.get(url);
      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
        throw Exception('Failed to search places: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      print('API Response Status: ${data['status']}');

      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        throw Exception('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
      }

      final results = data['results'] as List;
      return results.map((place) => Venue.fromPlacesApi(place as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      print('Error in searchByText: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 詳細検索
  Future<List<Venue>> searchByFilters({
    required String area,
    List<String>? types,
    int? minPrice,
    int? maxPrice,
    bool? openNow,
    String? rankBy,
    Location? location,
    int radius = 1500,
    String language = 'ja',
  }) async {
    print('Places API searchByFilters called with:');
    print('Area: $area');
    print('Types: $types');
    print('Price range: $minPrice - $maxPrice');
    print('Open now: $openNow');
    print('Rank by: $rankBy');

    var queryParams = {
      'query': '$area 居酒屋',
      'language': language,
      'key': _apiKey,
    };

    if (types != null && types.isNotEmpty) {
      queryParams['type'] = types.join('|');
    }
    if (minPrice != null) {
      queryParams['minprice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxprice'] = maxPrice.toString();
    }
    if (openNow == true) {
      queryParams['opennow'] = 'true';
    }
    if (location != null) {
      queryParams['location'] = '${location.lat},${location.lng}';
      queryParams['radius'] = radius.toString();
    }
    if (rankBy != null) {
      queryParams['rankby'] = rankBy;
    }

    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      queryParams,
    );

    try {
      print('Detailed Search API Request URL: $url');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
        throw Exception('Failed to search places: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        throw Exception('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
      }

      final results = data['results'] as List;
      var venues = results.map((place) => Venue.fromPlacesApi(place as Map<String, dynamic>)).toList();
      print('Initial search results count: ${venues.length}');

      // 詳細情報の取得
      venues = await Future.wait(
        venues.map((venue) => _enrichVenueWithDetails(venue)),
      );
      print('Venues enriched with details: ${venues.length}');

      return venues;
    } catch (e, stackTrace) {
      print('Error in searchByFilters: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 店舗詳細情報の取得
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&language=ja&fields=name,formatted_phone_number,opening_hours,photos,price_level,rating,user_ratings_total,website,business_status,types,vicinity&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to get place details: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        throw Exception('Place details API error: ${data['status']}');
      }

      return data['result'] as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching place details: $e');
      rethrow;
    }
  }

  // 店舗情報に詳細データを追加
  Future<Venue> _enrichVenueWithDetails(Venue venue) async {
    try {
      final details = await getPlaceDetails(venue.placeId);
      
      // 基本情報の更新
      var enrichedData = {
        ...venue.toJson(),
        ...details,
        'additionalDetails': {
          'smoking_status': _extractSmokingStatus(details),
          'has_private_room': _extractPrivateRoomInfo(details),
          'has_nomihodai': _extractNomihodaiInfo(details),
          'capacity': _extractCapacity(details),
        },
      };

      return Venue.fromPlacesApi(enrichedData);
    } catch (e) {
      print('Error enriching venue details: $e');
      return venue;
    }
  }

  // 喫煙状況の抽出（APIの応答から推測）
  String? _extractSmokingStatus(Map<String, dynamic> details) {
    final description = details['editorial_summary']?['overview'] as String? ?? '';
    final attributes = details['attributes'] as Map<String, dynamic>? ?? {};
    
    if (description.toLowerCase().contains('禁煙') || 
        attributes['smoking'] == 'NO_SMOKING') {
      return '禁煙';
    } else if (description.toLowerCase().contains('喫煙可') || 
               attributes['smoking'] == 'SMOKING_ALLOWED') {
      return '喫煙可';
    }
    return null;
  }

  // 個室情報の抽出（APIの応答から推測）
  bool? _extractPrivateRoomInfo(Map<String, dynamic> details) {
    final description = details['editorial_summary']?['overview'] as String? ?? '';
    final attributes = details['attributes'] as Map<String, dynamic>? ?? {};
    
    return description.toLowerCase().contains('個室') || 
           attributes['private_room'] == true;
  }

  // 飲み放題情報の抽出（APIの応答から推測）
  bool? _extractNomihodaiInfo(Map<String, dynamic> details) {
    final description = details['editorial_summary']?['overview'] as String? ?? '';
    final attributes = details['attributes'] as Map<String, dynamic>? ?? {};
    
    return description.toLowerCase().contains('飲み放題') || 
           attributes['all_you_can_drink'] == true;
  }

  // 収容人数の抽出（APIの応答から推測）
  int? _extractCapacity(Map<String, dynamic> details) {
    final attributes = details['attributes'] as Map<String, dynamic>? ?? {};
    return attributes['seating_capacity'] as int?;
  }

  // 写真の取得
  Future<Uint8List> getPlacePhoto(String photoReference) async {
    final url = Uri.parse(
      '$_baseUrl/photo?maxwidth=400&photo_reference=$photoReference&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch photo: ${response.statusCode}');
      }

      return response.bodyBytes;
    } catch (e) {
      print('Error fetching photo: $e');
      rethrow;
    }
  }
} 