import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/venue.dart';
import '../models/location.dart';
import '../models/hotpepper/shop.dart';

class HotpepperApi {
  final String _apiKey;
  final String _baseUrl = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
  final http.Client _client;
  
  HotpepperApi({String? apiKey, http.Client? client}) 
    : _apiKey = apiKey ?? Env.hotpepperApiKey,
      _client = client ?? http.Client();

  Future<List<Venue>> searchByKeyword(String keyword) async {
    final params = <String, String>{
      'key': _apiKey,
      'keyword': keyword,
      'format': 'json',
    };

    try {
      final response = await _get('', params);
      print('Raw API response: $response');

      if (response['results'] == null) {
        print('No results field in response');
        return [];
      }

      if (response['results']['shop'] == null) {
        print('No shop field in results');
        return [];
      }

      final shops = Shop.listFromJson(response['results']['shop']);
      print('Parsed ${shops.length} shops');
      
      final venues = shops.map((shop) => shop.toVenue()).toList();
      print('Converted to ${venues.length} venues');
      
      return venues;
    } catch (e, stackTrace) {
      print('Error in searchByKeyword: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Venue>> searchByFilters({
    String? keyword,
    String? name,
    String? address,
    String? area,
    List<String>? genres,
    int? partyCapacity,
    String? smoking,
    bool? privateRoom,
    bool? freeDrink,
    String? open,
    String? budget,
    double? latitude,
    double? longitude,
    String? range,
  }) async {
    final Map<String, String> params = {
      'key': _apiKey,
      'format': 'json',
    };

    void addStringParam(String key, String? value) {
      if (value?.isNotEmpty == true) {
        params[key] = value!;
      }
    }

    void addNumericParam(String key, num? value, {int? precision}) {
      if (value != null) {
        params[key] = precision != null 
            ? value.toStringAsFixed(precision)
            : value.toString();
      }
    }

    void addBoolParam(String key, bool? value, {String trueValue = '1'}) {
      if (value == true) {
        params[key] = trueValue;
      }
    }

    if (keyword?.isNotEmpty == true) {
      if (RegExp(r'^\d+$').hasMatch(keyword!)) {
        addStringParam('address', keyword);
      } else if (keyword.contains('駅')) {
        addStringParam('address', keyword);
      } else {
        addStringParam('keyword', keyword);
      }
    }

    addStringParam('name', name);
    addStringParam('address', address);
    addStringParam('small_area', area);
    if (genres?.isNotEmpty == true) {
      params['genre'] = genres!.join(',');
    }
    addNumericParam('party_capacity', partyCapacity);
    addStringParam('smoking', smoking);
    addBoolParam('private_room', privateRoom);
    addBoolParam('free_drink', freeDrink);
    addStringParam('open', open);
    addStringParam('budget', budget);
    addNumericParam('lat', latitude, precision: 6);
    addNumericParam('lng', longitude, precision: 6);
    addStringParam('range', range);

    print('Search parameters: $params');

    final response = await _get('', params);
    if (response['results']?['shop'] == null) {
      print('No results found in API response');
      return [];
    }
    final shops = Shop.listFromJson(response['results']['shop']);
    return shops.map((shop) => shop.toVenue()).toList();
  }

  Future<Venue?> getShopDetail(String id) async {
    final params = {
      'key': _apiKey,
      'format': 'json',
      'id': id,
    };

    final response = await _get('', params);
    final shops = Shop.listFromJson(response['results']['shop']);
    return shops.isEmpty ? null : shops.first.toVenue();
  }

  Future<List<Map<String, String>>> getGenres() async {
    final params = {
      'key': _apiKey,
      'format': 'json',
    };

    final response = await _get('genre/v1/', params);
    final genres = response['results']['genre'] as List;
    return genres.map((genre) => {
      'code': genre['code'] as String,
      'name': genre['name'] as String,
    }).toList();
  }

  Future<List<Map<String, String>>> getAreas() async {
    final params = {
      'key': _apiKey,
      'format': 'json',
    };

    final response = await _get('small_area/v1/', params);
    final areas = response['results']['small_area'] as List;
    return areas.map((area) => {
      'code': area['code'] as String,
      'name': area['name'] as String,
    }).toList();
  }

  Future<Map<String, dynamic>> _get(String path, Map<String, String> params) async {
    final uri = Uri.parse(_baseUrl + path).replace(queryParameters: params);
    
    try {
      print('API Request URL: $uri');
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        print('API Response: ${decodedResponse['results']['results_available']} results found');
        return decodedResponse;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      throw Exception('Network error: $e');
    }
  }
} 