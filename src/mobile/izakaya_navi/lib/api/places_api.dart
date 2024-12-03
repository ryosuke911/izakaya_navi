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
    print('API Key being used: $_apiKey');
    print('API Key last 4 chars: ${_apiKey.substring(_apiKey.length - 4)}');

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
        print('API Error Message: ${data['error_message']}');
        throw Exception('Places API error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
      }

      final results = data['results'] as List;
      print('Number of results: ${results.length}');

      if (results.isNotEmpty) {
        print('First result: ${json.encode(results.first)}');
      }

      return results.map((place) {
        try {
          return Venue.fromPlacesApi(place as Map<String, dynamic>);
        } catch (e, stackTrace) {
          print('Error parsing venue: $e');
          print('Venue data: ${json.encode(place)}');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      print('Error in searchByText: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 写真の取得
  Future<Uint8List> getPlacePhoto(String photoReference, {int maxWidth = 800}) async {
    final url = Uri.parse(
      '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey',
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