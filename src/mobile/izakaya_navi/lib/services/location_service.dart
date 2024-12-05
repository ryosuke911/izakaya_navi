import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location.dart';

class LocationService {
  /// 現在位置の取得
  Future<Location> getCurrentLocation() async {
    try {
      // 位置情報の権限を確認
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: '位置情報の取得が許可されていません。',
          );
        }
      }

      // 位置情報を取得
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw PlatformException(
        code: 'LOCATION_ERROR',
        message: '位置情報の取得に失敗しました: $e',
      );
    }
  }

  /// 2地点間の距離を計算（メートル単位）
  Future<double> calculateDistance(Location start, Location end) async {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
} 