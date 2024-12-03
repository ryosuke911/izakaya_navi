import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

@freezed
class Venue with _$Venue {
  const factory Venue({
    required String placeId,
    required String name,
    required Location location,
    @Default([]) List<String> types,
    double? rating,
    int? userRatingsTotal,
    int? priceLevel,
    String? businessStatus,
    OpeningHours? openingHours,
    List<Photo>? photos,
    String? formattedPhoneNumber,
    String? website,
    String? vicinity,
    Map<String, dynamic>? additionalDetails,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  factory Venue.fromPlacesApi(Map<String, dynamic> json) {
    try {
      print('Converting place data to Venue: ${json['place_id']}'); // デバッグ用
      return Venue(
        placeId: json['place_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        location: Location.fromPlacesApi(json),
        types: (json['types'] as List?)?.map((e) => e as String).toList() ?? [],
        rating: (json['rating'] is int) 
            ? (json['rating'] as int).toDouble() 
            : json['rating'] as double?,
        userRatingsTotal: json['user_ratings_total'] as int?,
        priceLevel: json['price_level'] as int?,
        businessStatus: json['business_status'] as String?,
        openingHours: json['opening_hours'] != null
            ? OpeningHours(
                openNow: json['opening_hours']['open_now'] as bool? ?? false,
                periods: null,
                weekdayText: null,
              )
            : null,
        photos: (json['photos'] as List?)?.map((photo) {
          return Photo(
            photoReference: photo['photo_reference'] as String? ?? '',
            height: photo['height'] as int? ?? 0,
            width: photo['width'] as int? ?? 0,
            htmlAttributions: (photo['html_attributions'] as List?)
                ?.map((e) => e as String)
                .toList() ?? [],
          );
        }).toList(),
        formattedPhoneNumber: json['formatted_phone_number'] as String?,
        website: json['website'] as String?,
        vicinity: json['vicinity'] as String?,
        additionalDetails: json['additionalDetails'] as Map<String, dynamic>?,
      );
    } catch (e, stackTrace) {
      print('Error in Venue.fromPlacesApi: $e'); // デバッグ用
      print('JSON data: $json'); // デバッグ用
      print('Stack trace: $stackTrace'); // デバッグ用
      rethrow;
    }
  }
}

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    required bool openNow,
    List<Period>? periods,
    List<String>? weekdayText,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

@freezed
class Period with _$Period {
  const factory Period({
    required DayTime open,
    required DayTime close,
  }) = _Period;

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
}

@freezed
class DayTime with _$DayTime {
  const factory DayTime({
    required int day,
    required String time,
  }) = _DayTime;

  factory DayTime.fromJson(Map<String, dynamic> json) => _$DayTimeFromJson(json);
}

@freezed
class Photo with _$Photo {
  const factory Photo({
    required String photoReference,
    required int height,
    required int width,
    List<String>? htmlAttributions,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
} 