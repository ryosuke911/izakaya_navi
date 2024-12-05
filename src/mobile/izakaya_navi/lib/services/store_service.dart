import '../api/hotpepper_api.dart';
import '../models/venue.dart';
import '../models/location.dart';
import '../services/location_service.dart';
import '../config/env.dart';

class StoreService {
  final HotpepperApi _hotpepperApi;
  final LocationService _locationService;

  StoreService({
    HotpepperApi? hotpepperApi,
    required LocationService locationService,
  })  : _hotpepperApi = hotpepperApi ?? HotpepperApi(),
        _locationService = locationService;

  /// キーワードで店舗を検索
  Future<List<Venue>> searchByKeyword(String keyword) async {
    try {
      return await _hotpepperApi.searchByKeyword(keyword.trim());
    } catch (e) {
      throw StoreServiceException('キーワード検索中にエラーが発生しました: $e');
    }
  }

  /// 詳細条件で店舗を検索
  Future<List<Venue>> searchByFilters({
    String? keyword,
    String? area,
    List<String>? genres,
    int? personCount,
    String? smoking,
    bool? hasNomihodai,
    bool? hasPrivateRoom,
    String? businessHours,
    double? budgetMin,
    double? budgetMax,
  }) async {
    try {
      // 予算コードの変換
      String? budgetCode;
      if (budgetMin != null || budgetMax != null) {
        budgetCode = _convertBudget({
          'min': budgetMin?.toInt() ?? 0,
          'max': budgetMax?.toInt() ?? 999999,
        });
      }

      // 営業時間の変換
      final openCode = businessHours != null ? _convertOpen(businessHours) : null;

      // 喫煙状況の変換
      final smokingCode = smoking != null ? _convertSmoking(smoking) : null;

      // APIを呼び出して検索を実行
      return await _hotpepperApi.searchByFilters(
        keyword: keyword?.trim(),
        area: area?.trim(),
        genres: genres,
        partyCapacity: personCount,
        smoking: smokingCode,
        freeDrink: hasNomihodai,
        privateRoom: hasPrivateRoom,
        open: openCode,
        budget: budgetCode,
      );
    } catch (e) {
      throw StoreServiceException('詳細検索中にエラーが発生しました: $e');
    }
  }

  /// 店舗の詳細情報を取得
  Future<Venue?> getStoreDetails(String storeId) async {
    try {
      return await _hotpepperApi.getShopDetail(storeId);
    } catch (e) {
      throw StoreServiceException('店舗詳細の取得中にエラーが発生しました: $e');
    }
  }

  /// 現在地周辺の店舗を検索
  Future<List<Venue>> searchNearbyStores({
    double? radius,
    String? keyword,
    List<String>? genres,
  }) async {
    try {
      // 現在位置を取得
      final currentLocation = await _locationService.getCurrentLocation();
      
      // 位置情報を含めて検索
      final venues = await _hotpepperApi.searchByFilters(
        keyword: keyword,
        genres: genres,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        range: _convertRadiusToRange(radius ?? 3000), // デフォルト3km
      );

      if (radius == null) {
        return venues;
      }

      // APIの検索範囲は概算なので、正確な距離で再フィルタリング
      return _filterByDistance(venues, currentLocation, radius);
    } catch (e) {
      throw StoreServiceException('店舗の検索中にエラーが発生しました: $e');
    }
  }

  /// ジャンルマスタ情報の取得
  Future<List<Map<String, String>>> getGenres() async {
    try {
      return await _hotpepperApi.getGenres();
    } catch (e) {
      throw StoreServiceException('ジャンル情報の取得中にエラーが発生しました: $e');
    }
  }

  /// エリアマスタ情報の取得
  Future<List<Map<String, String>>> getAreas() async {
    try {
      return await _hotpepperApi.getAreas();
    } catch (e) {
      throw StoreServiceException('エリア情報の取得中にエラーが発生しました: $e');
    }
  }

  /// 検索結果を距離順にソート
  Future<List<Venue>> sortVenues(List<Venue> venues, String sortBy) async {
    switch (sortBy) {
      case 'distance':
        return _sortByDistance(venues);
      default:
        return venues;  // デフォルトはAPIの順序を維持
    }
  }

  /// 距離でソート
  Future<List<Venue>> _sortByDistance(List<Venue> venues) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();
      final venuesWithDistance = await Future.wait(
        venues.map((venue) async {
          final distance = await _locationService.calculateDistance(
            currentLocation,
            venue.location,
          );
          return _VenueWithDistance(venue, distance);
        }),
      );

      venuesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      return venuesWithDistance.map((v) => v.venue).toList();
    } catch (e) {
      // 位置情報の取得に失敗した場合は元の順序を維持
      return venues;
    }
  }

  /// 距離でフィルタリング
  Future<List<Venue>> _filterByDistance(List<Venue> venues, Location currentLocation, double radius) async {
    final filteredVenues = await Future.wait(
      venues.map((venue) async {
        final distance = await _locationService.calculateDistance(
          currentLocation,
          venue.location,
        );
        return _VenueWithDistance(venue, distance);
      }),
    );

    return filteredVenues
        .where((v) => v.distance <= radius)
        .map((v) => v.venue)
        .toList();
  }

  /// 半径をホットペッパーAPIの範囲パラメータに変換
  String _convertRadiusToRange(double radiusInMeters) {
    if (radiusInMeters <= 300) return '1';
    if (radiusInMeters <= 500) return '2';
    if (radiusInMeters <= 1000) return '3';
    if (radiusInMeters <= 2000) return '4';
    if (radiusInMeters <= 3000) return '5';
    return '5'; // 最大3000m
  }

  /// 喫煙状況をAPIパラメータに変換
  String _convertSmoking(String value) {
    switch (value) {
      case '喫煙可':
        return '1';
      case '禁煙':
        return '3';
      default:
        return '0';  // 指定なし
    }
  }

  /// 営業時間をAPIパラメータに変換
  String _convertOpen(String value) {
    switch (value) {
      case '今営業中':
        return 'now';
      case '深夜営業あり':
        return 'late';
      default:
        return '';  // 指定なし
    }
  }

  /// 予算をAPIパラメータに変換
  String _convertBudget(Map<String, int> budget) {
    final min = budget['min'] ?? 0;
    final max = budget['max'] ?? 999999;

    if (max <= 2000) return 'B009';  // 〜2000円
    if (max <= 3000) return 'B010';  // 2001〜3000円
    if (max <= 4000) return 'B011';  // 3001〜4000円
    if (max <= 5000) return 'B001';  // 4001〜5000円
    if (max <= 7000) return 'B002';  // 5001〜7000円
    if (max <= 10000) return 'B003'; // 7001〜10000円
    return 'B008';                   // 10001円〜
  }
}

class _VenueWithDistance {
  final Venue venue;
  final double distance;

  _VenueWithDistance(this.venue, this.distance);
}

class StoreServiceException implements Exception {
  final String message;
  StoreServiceException(this.message);

  @override
  String toString() => message;
} 