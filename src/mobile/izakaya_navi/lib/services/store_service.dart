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
      return await _hotpepperApi.searchByFilters(
        keyword: keyword,
      );
    } catch (e) {
      throw StoreServiceException('キーワード検索中にエラーが発生しました: $e');
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
    } catch (e) {
      throw StoreServiceException('店舗の検索中にエラーが発生しました: $e');
    }
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