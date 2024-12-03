import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required double lat,
    required double lng,
    String? formattedAddress,
    List<AddressComponent>? addressComponents,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
      
  factory Location.fromPlacesApi(Map<String, dynamic> json) {
    try {
      print('Converting geometry data to Location'); // デバッグ用
      final geometry = json['geometry'] as Map<String, dynamic>?;
      if (geometry == null) {
        print('Geometry is null in JSON: $json'); // デバッグ用
        throw Exception('Geometry data is missing');
      }

      final location = geometry['location'] as Map<String, dynamic>?;
      if (location == null) {
        print('Location is null in geometry: $geometry'); // デバッグ用
        throw Exception('Location data is missing');
      }

      final lat = location['lat'];
      final lng = location['lng'];

      if (lat == null || lng == null) {
        print('Lat or lng is null in location: $location'); // デバッグ用
        throw Exception('Latitude or longitude is missing');
      }

      return Location(
        lat: (lat is int) ? lat.toDouble() : lat as double,
        lng: (lng is int) ? lng.toDouble() : lng as double,
        formattedAddress: json['formatted_address'] as String?,
        addressComponents: json['address_components'] != null
            ? (json['address_components'] as List)
                .map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );
    } catch (e, stackTrace) {
      print('Error in Location.fromPlacesApi: $e'); // デバッグ用
      print('JSON data: $json'); // デバッグ用
      print('Stack trace: $stackTrace'); // デバッグ用
      rethrow;
    }
  }
}

@freezed
class AddressComponent with _$AddressComponent {
  const factory AddressComponent({
    required String longName,
    required String shortName,
    required List<String> types,
  }) = _AddressComponent;

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);
} 