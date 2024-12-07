import '../api/hotpepper_api.dart';
import '../models/venue.dart';
import '../models/location.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/izakaya_category.dart';
import '../services/location_service.dart';
import '../config/env.dart';

class StoreService {
  static const String IZAKAYA_GENRE_CODE = 'G001';
  final HotpepperApi _hotpepperApi;
  final LocationService _locationService;

  StoreService({
    HotpepperApi? hotpepperApi,
    required LocationService locationService,
  })  : _hotpepperApi = hotpepperApi ?? HotpepperApi(),
        _locationService = locationService;

  /// キーワードで店舗を検索（常に居酒屋ジャンルで検索）
  Future<List<Venue>> searchByKeyword(String keyword) async {
    try {
      final params = {
        'keyword': keyword.trim(),
        'genre': IZAKAYA_GENRE_CODE,
      };
      return await _hotpepperApi.searchByFilters(params: params);
    } catch (e) {
      throw StoreServiceException('キーワード検索中にエラーが発生しました: $e');
    }
  }

  /// 詳細条件で店舗を検索（常に居酒屋ジャンルで検索）
  Future<List<Venue>> searchByFilters(SearchParams params) async {
    try {
      final apiParams = params.toApiParameters();
      
      // 常に居酒屋ジャ��ルを指定
      apiParams['genre'] = IZAKAYA_GENRE_CODE;

      // エリアが指定されていない場合のみ、現在位置を使用
      if (params.area == null) {
        try {
          final currentLocation = await _locationService.getCurrentLocation();
          if (currentLocation != null) {
            apiParams['lat'] = currentLocation.latitude.toString();
            apiParams['lng'] = currentLocation.longitude.toString();
            // デフォルトの検索範囲を設定（3km）
            apiParams['range'] = '5';
          }
        } catch (e) {
          print('位置情報の取得をスキップしました: $e');
        }
      }

      // APIを呼び出して検索を実行
      final venues = await _hotpepperApi.searchByFilters(params: apiParams);
      return await _sortByDistance(venues);
    } catch (e) {
      throw StoreServiceException('詳細検索中にエラーが発生しました: $e');
    }
  }

  /// カテゴリによる検索
  Future<List<Venue>> searchByCategories(List<IzakayaCategory> categories) async {
    final params = SearchParams(categories: categories);
    return searchByFilters(params);
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
    List<IzakayaCategory>? categories,
  }) async {
    try {
      // 現在位置を取得
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation == null) {
        throw StoreServiceException('現在位置を取得できませんでした');
      }

      // 検索パラメータの構築
      final params = SearchParams(
        keyword: keyword,
        categories: categories ?? [],
      ).toApiParameters();

      params['lat'] = currentLocation.latitude.toString();
      params['lng'] = currentLocation.longitude.toString();
      params['range'] = _convertRadiusToRange(radius ?? 3000); // デフォルト3km
      params['genre'] = IZAKAYA_GENRE_CODE;

      // 検索実行
      final venues = await _hotpepperApi.searchByFilters(params: params);

      // 正確な距離でフィルタリング（必要な場合）
      return radius != null
          ? await _filterByDistance(venues, currentLocation, radius)
          : venues;
    } catch (e) {
      throw StoreServiceException('周辺店舗の検索中にエラー��発生しました: $e');
    }
  }

  /// エリア一覧の取得
  Future<List<Area>> getAreas() async {
    try {
      return await _hotpepperApi.getAreas();
    } catch (e) {
      throw StoreServiceException('エリア情報の取得中にエラーが発生しました: $e');
    }
  }

  /// 検索結果を距離順にソート
  Future<List<Venue>> _sortByDistance(List<Venue> venues) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation == null) return venues;

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
  Future<List<Venue>> _filterByDistance(
    List<Venue> venues,
    Location currentLocation,
    double radius,
  ) async {
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