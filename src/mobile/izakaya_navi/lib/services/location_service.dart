import 'package:geolocator/geolocator.dart';
import '../models/location.dart';

class LocationService {
  /// 位置情報の権限を確認し、必要に応じて要求する
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// 現在位置を取得する（Positionオブジェクトとして）
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// 現在位置を取得する（Locationオブジェクトとして）
  Future<Location?> getCurrentLocation() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// 2点間の距離を計算する（メートル単位）
  Future<double> calculateDistance(Location from, Location to) async {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }
} 