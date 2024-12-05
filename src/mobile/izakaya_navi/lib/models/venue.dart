import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

@freezed
class Venue with _$Venue {
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
    Map<String, dynamic>? additionalDetails,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  factory Venue.fromHotpepper(Map<String, dynamic> json) {
    try {
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
          if (json['photo']?['pc']?['l'] != null)
            json['photo']['pc']['l'] as String,
        ],
        phoneNumber: json['tel'] as String?,
        address: json['address'] as String?,
        additionalDetails: json,
      );
    } catch (e, stackTrace) {
      print('Error in Venue.fromHotpepper: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 