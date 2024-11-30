import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../izakaya-connect/services/maps_service.dart';

class LocationService {
  final MapsService _mapsService;
  
  LocationService({MapsService? mapsService}) 
      : _mapsService = mapsService ?? MapsService();

  /// 現在位置の取得
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await _checkLocationPermission();
      if (!permission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
      return null;
    }
  }

  /// 位置情報の権限チェック
  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.location.request();
    return result.isGranted;
  }

  /// 2点間の距離を計算（メートル単位）
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// 指定した範囲内にいるかチェック
  bool isWithinRange(Position userLocation, double targetLat, double targetLng, double rangeInMeters) {
    final distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      targetLat,
      targetLng
    );
    return distance <= rangeInMeters;
  }

  /// 住所から緯度経度を取得
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final coordinates = await _mapsService.geocodeAddress(address);
      return coordinates;
    } catch (e) {
      print('住所からの座標変換に失敗しました: $e');
      return null;
    }
  }

  /// 位置情報の監視を開始
  Stream<Position> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}