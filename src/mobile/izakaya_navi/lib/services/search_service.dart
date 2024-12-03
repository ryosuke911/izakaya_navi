import '../api/places_api.dart';
import '../models/venue.dart';
import '../models/location.dart';

class SearchService {
  final PlacesApi _placesApi;

  SearchService({PlacesApi? placesApi}) : _placesApi = placesApi ?? PlacesApi();

  // カテゴリをGoogle Places APIのタイプにマッピング
  List<String> _convertCategories(List<String> categories) {
    final Map<String, List<String>> categoryMapping = {
      '焼き鳥': ['restaurant', 'yakitori', 'food'],
      '海鮮': ['restaurant', 'seafood_restaurant', 'food'],
      '揚げ物': ['restaurant', 'food', 'tempura'],
      'おでん': ['restaurant', 'food', 'japanese_restaurant'],
      '創作料理': ['restaurant', 'japanese_restaurant', 'food'],
      '餃子': ['restaurant', 'food', 'chinese_restaurant'],
    };

    final Set<String> apiTypes = {'restaurant'};  // 基本タイプは常に含める
    
    for (var category in categories) {
      if (categoryMapping.containsKey(category)) {
        apiTypes.addAll(categoryMapping[category]!);
      }
    }

    print('Converting categories: $categories');
    print('To API types: ${apiTypes.toList()}');
    
    return apiTypes.toList();
  }

  // 詳細検索
  Future<List<Venue>> searchByFilters({
    required String area,
    List<String>? categories,
    int? personCount,
    String? smokingStatus,
    bool? hasNomihodai,
    bool? hasPrivateRoom,
    String? businessHours,
    double? minBudget,
    double? maxBudget,
    Location? location,
    String? sortBy,
  }) async {
    print('Starting search with filters:');
    print('Area: $area');
    print('Categories: $categories');
    print('Person count: $personCount');
    print('Smoking status: $smokingStatus');
    print('Has nomihodai: $hasNomihodai');
    print('Has private room: $hasPrivateRoom');
    print('Business hours: $businessHours');
    print('Budget range: $minBudget - $maxBudget');

    try {
      // カテゴリをAPIタイプに変換
      final apiTypes = categories != null && categories.isNotEmpty
          ? _convertCategories(categories)
          : ['restaurant'];  // デフォルトは'restaurant'

      // 予算をGoogle Places APIの価格レベルに変換
      int? minPriceLevel;
      int? maxPriceLevel;
      if (minBudget != null) {
        minPriceLevel = _convertBudgetToPriceLevel(minBudget);
        print('Converted min budget to price level: $minPriceLevel');
      }
      if (maxBudget != null) {
        maxPriceLevel = _convertBudgetToPriceLevel(maxBudget);
        print('Converted max budget to price level: $maxPriceLevel');
      }

      // 営業時間の条件を変換
      bool? openNow;
      if (businessHours == '今営業中') {
        openNow = true;
        print('Setting openNow filter to true');
      }

      // Places APIで検索を実行
      print('Executing Places API search with types: $apiTypes');
      var venues = await _placesApi.searchByFilters(
        area: area,
        types: apiTypes,
        minPrice: minPriceLevel,
        maxPrice: maxPriceLevel,
        openNow: openNow,
        rankBy: sortBy,
        location: location,
      );
      print('Initial search results count: ${venues.length}');

      // 詳細フィルタリングの適用
      if (personCount != null || smokingStatus != null || hasNomihodai == true || 
          hasPrivateRoom == true || businessHours == '深夜営業あり') {
        print('Applying detailed filters...');
        
        // 収容人数でのフィルタリング
        if (personCount != null) {
          venues = await _filterByCapacity(venues, personCount);
          print('After capacity filter: ${venues.length} venues');
        }

        // 設備（喫煙・個室など）でのフィルタリング
        venues = await _filterByFacilities(
          venues,
          smokingStatus: smokingStatus,
          hasNomihodai: hasNomihodai,
          hasPrivateRoom: hasPrivateRoom,
        );
        print('After facilities filter: ${venues.length} venues');

        // 営業時間でのフィルタリング
        if (businessHours == '深夜営業あり') {
          venues = _filterByBusinessHours(venues);
          print('After business hours filter: ${venues.length} venues');
        }
      }

      // 検索結果のソート
      if (sortBy != null) {
        venues = _sortVenues(venues, sortBy);
        print('Results sorted by: $sortBy');
      }

      print('Final results count: ${venues.length}');
      return venues;
    } catch (e, stackTrace) {
      print('Error in searchByFilters: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 予算を価格レベルに変換（Google Places APIの0-4のレベルに）
  int _convertBudgetToPriceLevel(double budget) {
    if (budget <= 2000) return 0;      // ¥0-2000
    if (budget <= 4000) return 1;      // ¥2001-4000
    if (budget <= 6000) return 2;      // ¥4001-6000
    if (budget <= 8000) return 3;      // ¥6001-8000
    return 4;                          // ¥8001+
  }

  // 収容人数による詳細フィルタリング
  Future<List<Venue>> _filterByCapacity(List<Venue> venues, int personCount) async {
    final filteredVenues = <Venue>[];
    
    for (var venue in venues) {
      try {
        // 詳細情報を取得して収容人数をチェック
        final details = await _placesApi.getPlaceDetails(venue.placeId);
        // 収容人数の情報がない場合は含める（フィルタリングしない）
        if (details['capacity'] == null || details['capacity'] >= personCount) {
          filteredVenues.add(venue);
        }
      } catch (e) {
        print('Error getting capacity details for venue ${venue.placeId}: $e');
        // エラーの場合は含める（フィルタリングしない）
        filteredVenues.add(venue);
      }
    }
    
    return filteredVenues;
  }

  // 設備による詳細フィルタリング
  Future<List<Venue>> _filterByFacilities(
    List<Venue> venues, {
    String? smokingStatus,
    bool? hasNomihodai,
    bool? hasPrivateRoom,
  }) async {
    final filteredVenues = <Venue>[];
    
    for (var venue in venues) {
      try {
        final details = await _placesApi.getPlaceDetails(venue.placeId);
        var includeVenue = true;
        
        // 喫煙状況のチェック
        if (smokingStatus != null && smokingStatus != '指定なし') {
          final venueSmokingStatus = details['smoking_status'];
          if (venueSmokingStatus != null && venueSmokingStatus != smokingStatus) {
            includeVenue = false;
          }
        }
        
        // 飲み放題のチェック
        if (hasNomihodai == true) {
          final hasNomihodaiService = details['has_nomihodai'] ?? false;
          if (!hasNomihodaiService) {
            includeVenue = false;
          }
        }
        
        // 個室のチェック
        if (hasPrivateRoom == true) {
          final hasPrivateRoomFacility = details['has_private_room'] ?? false;
          if (!hasPrivateRoomFacility) {
            includeVenue = false;
          }
        }
        
        if (includeVenue) {
          filteredVenues.add(venue);
        }
      } catch (e) {
        print('Error getting facility details for venue ${venue.placeId}: $e');
        // エラーの場合は含める（フィルタリングしない）
        filteredVenues.add(venue);
      }
    }
    
    return filteredVenues;
  }

  // 営業時間による詳細フィルタリング
  List<Venue> _filterByBusinessHours(List<Venue> venues) {
    return venues.where((venue) {
      // 深夜営業のフィルタリング
      if (venue.openingHours?.periods == null) return true;
      
      // 深夜営業（22時以降）をチェック
      final hasLateNight = venue.openingHours!.periods!.any((period) {
        if (period.close == null) return false;
        final closeHour = int.tryParse(period.close!.time.substring(0, 2));
        return closeHour != null && (closeHour >= 22 || closeHour <= 5);
      });
      
      return hasLateNight;
    }).toList();
  }

  // 検索結果のソート
  List<Venue> _sortVenues(List<Venue> venues, String sortBy) {
    switch (sortBy) {
      case 'rating':
        return venues..sort((a, b) => 
          ((b.rating ?? 0) * (b.userRatingsTotal ?? 0))
          .compareTo((a.rating ?? 0) * (a.userRatingsTotal ?? 0))
        );
      case 'distance':
        if (venues.every((venue) => venue.location != null)) {
          return venues..sort((a, b) {
            final distanceA = _calculateDistance(a.location!);
            final distanceB = _calculateDistance(b.location!);
            return distanceA.compareTo(distanceB);
          });
        }
        return venues;
      default:
        return venues;
    }
  }

  // 現在地からの距離を計算（実装は省略、location_serviceを使用予定）
  double _calculateDistance(Location location) {
    // TODO: 現在地からの距離を計算する実装
    return 0.0;
  }
} 