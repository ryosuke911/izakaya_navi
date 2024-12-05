import '../models/venue.dart';
import '../services/location_service.dart';
import '../api/hotpepper_api.dart';

class SearchService {
  final LocationService _locationService;
  final HotpepperApi _hotpepperApi;

  SearchService(this._locationService, {HotpepperApi? hotpepperApi})
      : _hotpepperApi = hotpepperApi ?? HotpepperApi();

  Future<List<Venue>> searchByKeyword(String keyword) async {
    return _hotpepperApi.searchByKeyword(keyword.trim());
  }

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
    final venues = await _hotpepperApi.searchByFilters(
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

    return venues;
  }

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

  /// ジャンルマスタ情報の取得
  Future<List<Map<String, String>>> getGenres() async {
    return _hotpepperApi.getGenres();
  }

  /// エリアマスタ情報の取得
  Future<List<Map<String, String>>> getAreas() async {
    return _hotpepperApi.getAreas();
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
}

class _VenueWithDistance {
  final Venue venue;
  final double distance;

  _VenueWithDistance(this.venue, this.distance);
} 