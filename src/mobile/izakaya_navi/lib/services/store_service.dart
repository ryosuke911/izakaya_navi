import 'package:geolocator/geolocator.dart';
import '../api/hotpepper_api.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/search_params.dart';
import '../models/venue.dart';
import '../models/location.dart';
import '../models/hotpepper/izakaya_category.dart';
import '../services/location_service.dart';

class StoreService {
  static const String IZAKAYA_GENRE_CODE = 'G001';
  final HotpepperApi _hotpepperApi;
  final LocationService _locationService;
  MiddleAreaList? _areaList;

  StoreService({
    HotpepperApi? hotpepperApi,
    required LocationService locationService,
  })  : _hotpepperApi = hotpepperApi ?? HotpepperApi(),
        _locationService = locationService;

  /// アプリ起動時に中エリアデータを取得
  Future<void> initialize() async {
    try {
      _areaList = await _hotpepperApi.getMiddleAreas();
      print('中エリアデータの初期化が完了しました');
      print('エリア数: ${_areaList?.areas.length}');
      print('エリア一覧:');
      _areaList?.areas.forEach((area) {
        print('- ${area.name}');
      });
    } catch (e) {
      print('中エリアデータの初期化に失敗しました: $e');
      rethrow;
    }
  }

  /// 詳細条件で店舗を検索（常に居酒屋ジャンルで検索）
  Future<List<Venue>> searchByFilters(SearchParams params) async {
    try {
      // 現在地の取得（必要な場合）
      Position? currentPosition;
      if (params.useCurrentLocation) {
        currentPosition = await _locationService.getCurrentPosition();
      }

      // 検索パラメータの構築
      final apiParams = params.toApiParameters();
      apiParams['genre'] = IZAKAYA_GENRE_CODE;

      if (currentPosition != null) {
        apiParams['lat'] = currentPosition.latitude.toString();
        apiParams['lng'] = currentPosition.longitude.toString();
        apiParams['range'] = _convertRadiusToRange(3000); // デフォルト3km
      }

      // エリアコードが指定されている場合は店舗検索APIを呼び出し
      if (params.areaCode != null) {
        final venues = await _hotpepperApi.searchByArea(
          params.areaCode!,
          additionalParams: apiParams,
        );

        // 現在地からの距離でソート（現在地情報がある場合）
        if (currentPosition != null) {
          return venues.map((venue) => venue.withDistance(currentPosition!)).toList()
            ..sort((a, b) => (a.distanceInMeters ?? double.infinity)
                .compareTo(b.distanceInMeters ?? double.infinity));
        }

        return venues;
      }

      throw StoreServiceException('エリアコードが指定されていません');
    } catch (e) {
      print('Error in searchByFilters: $e');
      rethrow;
    }
  }

  /// 店舗の詳細情報を取得
  Future<Venue?> getStoreDetails(String storeId) async {
    try {
      final venues = await _hotpepperApi.searchByArea(storeId);
      return venues.isNotEmpty ? venues.first : null;
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
      final currentPosition = await _locationService.getCurrentPosition();
      if (currentPosition == null) {
        throw StoreServiceException('現在位置を取得できませんでした');
      }

      // 検索パラメータの構築
      final params = SearchParams(
        keyword: keyword,
        categories: categories ?? [],
        useCurrentLocation: true,
      );

      // 検索実行
      final venues = await searchByFilters(params);

      // 指定された半径でフィルタリング（指定がある場合）
      if (radius != null) {
        return venues.where((venue) => 
          (venue.distanceInMeters ?? double.infinity) <= radius
        ).toList();
      }

      return venues;
    } catch (e) {
      throw StoreServiceException('周辺店舗検索中にエラーが発生しました: $e');
    }
  }

  /// 半径をホットペッパーAPIの範囲パラメータに変換
  String _convertRadiusToRange(double radiusInMeters) {
    if (radiusInMeters <= 300) return '1';
    if (radiusInMeters <= 500) return '2';
    if (radiusInMeters <= 1000) return '3';
    if (radiusInMeters <= 2000) return '4';
    if (radiusInMeters <= 3000) return '5';
    return '5'; // 最大3km
  }

  /// エリアのサジェスト機能（ローカル検索）
  Future<List<MiddleArea>> suggestAreas(String keyword) async {
    if (keyword.isEmpty) return [];

    try {
      print('=== Area Search ===');
      print('Keyword: $keyword');
      print('Area List Initialized: ${_areaList != null}');
      
      // エリアデータが初期化されていない場合は初期化
      if (_areaList == null) {
        print('Initializing area list...');
        await initialize();
      }

      // キーワードでローカル検索を実行
      final results = _areaList?.search(keyword) ?? [];
      print('Search Results: ${results.length} areas found');
      results.forEach((area) {
        print('- ${area.name}');
      });
      
      return results;
    } catch (e) {
      print('Error in suggestAreas: $e');
      return [];
    }
  }
}

class StoreServiceException implements Exception {
  final String message;
  StoreServiceException(this.message);

  @override
  String toString() => message;
} 