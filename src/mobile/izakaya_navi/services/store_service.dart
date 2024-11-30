import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../backend/supabase/store_queries.dart';
import '../../izakaya-connect/services/location_service.dart';

class StoreService {
  final StoreQueries _storeQueries;
  final LocationService _locationService;

  StoreService({
    required StoreQueries storeQueries,
    required LocationService locationService,
  })  : _storeQueries = storeQueries,
        _locationService = locationService;

  /// 近くの店舗を取得
  Future<List<Store>> getNearbyStores({
    required double radius,
    int limit = 20,
  }) async {
    final currentLocation = await _locationService.getCurrentLocation();
    return _storeQueries.getNearbyStores(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
      radius: radius,
      limit: limit,
    );
  }

  /// 店舗の詳細情報を取得
  Future<Store?> getStoreDetails(String storeId) async {
    return _storeQueries.getStoreById(storeId);
  }

  /// 店舗を検索
  Future<List<Store>> searchStores({
    String? keyword,
    List<String>? categories,
    PriceRange? priceRange,
    bool? isOpenNow,
  }) async {
    return _storeQueries.searchStores(
      keyword: keyword,
      categories: categories,
      priceRange: priceRange,
      isOpenNow: isOpenNow,
    );
  }

  /// お気に入り店舗を取得
  Future<List<Store>> getFavoriteStores(String userId) async {
    return _storeQueries.getFavoriteStores(userId);
  }

  /// お気に入り登録/解除
  Future<void> toggleFavorite({
    required String userId,
    required String storeId,
  }) async {
    await _storeQueries.toggleFavorite(
      userId: userId,
      storeId: storeId,
    );
  }
}

/// 店舗情報モデル
class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final String? description;
  final PriceRange priceRange;
  final BusinessHours businessHours;
  final String? phoneNumber;
  final List<String> photos;
  final double rating;
  final int reviewCount;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.description,
    required this.priceRange,
    required this.businessHours,
    this.phoneNumber,
    required this.photos,
    required this.rating,
    required this.reviewCount,
  });
}

/// 価格帯
enum PriceRange {
  low,
  medium,
  high,
  veryHigh,
}

/// 営業時間
class BusinessHours {
  final Map<String, OpeningHours> weeklySchedule;

  BusinessHours({required this.weeklySchedule});

  bool isOpenNow() {
    // 現在の営業状態を確認するロジック
    final now = DateTime.now();
    final today = _getDayOfWeek(now.weekday);
    final currentHours = weeklySchedule[today];
    
    if (currentHours == null) return false;
    
    return currentHours.isOpenAt(TimeOfDay.fromDateTime(now));
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: throw ArgumentError('Invalid weekday');
    }
  }
}

/// 営業時間帯
class OpeningHours {
  final TimeOfDay open;
  final TimeOfDay close;

  OpeningHours({
    required this.open,
    required this.close,
  });

  bool isOpenAt(TimeOfDay time) {
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;
    final currentMinutes = time.hour * 60 + time.minute;

    if (closeMinutes < openMinutes) {
      // 深夜営業の場合
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    } else {
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    }
  }
}