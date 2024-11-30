import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../backend/supabase/search_queries.dart';
import '../../izakaya-connect/services/location_service.dart';

class SearchService {
  final SearchQueries _searchQueries;
  final LocationService _locationService;

  SearchService({
    required SearchQueries searchQueries,
    required LocationService locationService,
  })  : _searchQueries = searchQueries,
        _locationService = locationService;

  /// 居酒屋を検索する
  Future<List<Map<String, dynamic>>> searchIzakaya({
    String? keyword,
    double? maxPrice,
    double? minRating,
    double? maxDistance,
    List<String>? categories,
    bool useCurrentLocation = false,
  }) async {
    try {
      var searchParams = <String, dynamic>{
        if (keyword != null) 'keyword': keyword,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minRating != null) 'min_rating': minRating,
        if (categories != null && categories.isNotEmpty) 
          'categories': categories,
      };

      // 現在位置を使用する場合は位置情報を取得
      if (useCurrentLocation && maxDistance != null) {
        final currentLocation = await _locationService.getCurrentLocation();
        if (currentLocation != null) {
          searchParams['latitude'] = currentLocation.latitude;
          searchParams['longitude'] = currentLocation.longitude;
          searchParams['max_distance'] = maxDistance;
        }
      }

      final results = await _searchQueries.executeSearch(searchParams);
      return _processSearchResults(results);
    } catch (e) {
      throw SearchException('検索中にエラーが発生しました: $e');
    }
  }

  /// 人気の居酒屋を取得
  Future<List<Map<String, dynamic>>> getPopularIzakaya({
    int limit = 10,
  }) async {
    try {
      final results = await _searchQueries.getPopularIzakaya(limit);
      return _processSearchResults(results);
    } catch (e) {
      throw SearchException('人気店の取得中にエラーが発生しました: $e');
    }
  }

  /// おすすめの居酒屋を取得
  Future<List<Map<String, dynamic>>> getRecommendedIzakaya({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final results = await _searchQueries.getRecommendedIzakaya(userId, limit);
      return _processSearchResults(results);
    } catch (e) {
      throw SearchException('おすすめ店の取得中にエラーが発生しました: $e');
    }
  }

  /// 検索結果の処理
  List<Map<String, dynamic>> _processSearchResults(
    List<Map<String, dynamic>> results,
  ) {
    return results.map((result) {
      return {
        'id': result['id'],
        'name': result['name'],
        'address': result['address'],
        'rating': result['rating'],
        'price_range': result['price_range'],
        'image_url': result['image_url'],
        'categories': List<String>.from(result['categories'] ?? []),
        if (result['distance'] != null) 'distance': result['distance'],
      };
    }).toList();
  }
}

class SearchException implements Exception {
  final String message;
  SearchException(this.message);

  @override
  String toString() => message;
}