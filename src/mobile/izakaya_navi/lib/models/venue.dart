import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';
import 'package:geolocator/geolocator.dart';
import 'hotpepper/area.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

@freezed
class Venue with _$Venue {
  const Venue._();

  const factory Venue({
    required String id,
    required String name,
    required Location location,
    @Default([]) List<String> genres,
    double? rating,
    int? reviewCount,
    String? budget,
    String? access,
    String? open,
    String? close,
    @Default([]) List<String> photos,
    String? phoneNumber,
    String? address,
    @JsonKey(fromJson: MiddleArea.fromJson, toJson: _areaToJson) MiddleArea? area,
    Map<String, dynamic>? additionalDetails,
    double? distanceInMeters,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  factory Venue.fromHotpepper(Map<String, dynamic> json) {
    try {
      final middleArea = json['middle_area'] as Map<String, dynamic>?;
      
      return Venue(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        location: Location(
          latitude: double.tryParse(json['lat'] ?? '') ?? 0.0,
          longitude: double.tryParse(json['lng'] ?? '') ?? 0.0,
        ),
        genres: [
          if (json['genre']?['name'] != null)
            json['genre']['name'] as String,
          if (json['sub_genre']?['name'] != null)
            json['sub_genre']['name'] as String,
        ],
        budget: json['budget']?['name'] as String?,
        access: json['access'] as String?,
        open: json['open'] as String?,
        close: json['close'] as String?,
        photos: [
          if (json['photo']?['mobile']?['l'] != null)
            (json['photo']['mobile']['l'] as String).replaceFirst('https://160.17.98.51', 'https://imgfp.hotp.jp'),
        ],
        phoneNumber: json['tel'] as String?,
        address: json['address'] as String?,
        area: middleArea != null ? MiddleArea.fromJson(middleArea) : null,
        additionalDetails: json,
      );
    } catch (e, stackTrace) {
      print('Error in Venue.fromHotpepper: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Venue withDistance(Position currentPosition) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      location.latitude,
      location.longitude,
    );
    return copyWith(distanceInMeters: distance);
  }

  String get distanceText {
    if (distanceInMeters == null) return '';
    
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.round()}m';
    } else {
      final km = (distanceInMeters! / 1000).toStringAsFixed(1);
      return '${km}km';
    }
  }
}

Map<String, dynamic>? _areaToJson(MiddleArea? area) => area?.toJson(); 